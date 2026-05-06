import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_role.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static Future<AuthResponse> login(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> register(
    String email,
    String password, {
    Map<String, dynamic>? metadata,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }

  static Future<void> logout() => _client.auth.signOut();

  static Future<String?> getIdToken() async {
    return _client.auth.currentSession?.accessToken;
  }

  static String? get accessToken => _client.auth.currentSession?.accessToken;

  static String? _localRoleOverride;

  static UserRole get currentRole {
    if (_localRoleOverride != null) {
      return parseUserRole(_localRoleOverride);
    }
    final user = _client.auth.currentUser;
    final roleFromMetadata = user?.userMetadata?['role'] as String?;
    final roleFromAppMetadata = user?.appMetadata['role'] as String?;

    return parseUserRole(roleFromMetadata ?? roleFromAppMetadata);
  }

  static String get homeRouteForCurrentUser => roleHomeRoute(currentRole);

  /// Reads the role from the `users` table and sets _localRoleOverride.
  /// Call this on login and on app startup (splash) instead of syncCurrentUser.
  static Future<void> loadRole() async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) return;

    final row = await _client
        .from('users')
        .select('roles(name)')
        .eq('supabase_id', authId)
        .maybeSingle();

    if (row == null) return;
    final roleName = (row['roles'] as Map?)?['name'] as String?;
    if (roleName == null) return;

    _localRoleOverride = roleName;
    await _client.auth.updateUser(UserAttributes(data: {'role': roleName}));
  }

  static Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    await _client.auth.updateUser(UserAttributes(data: metadata));
  }

  /// Syncs the authenticated Supabase user directly into the PostgreSQL tables
  /// (users, coaches / clients / nutriologos) without going through Laravel.
  /// Also stamps user_metadata.role in Supabase Auth so the JWT reflects it.
  static Future<String?> syncCurrentUser({
    String? name,
    String? role,
    Map<String, dynamic>? profile,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final supabaseId = user.id;
    final email = user.email ?? '';
    final normalizedRole = role ?? 'cliente';

    // Resolve role_id from the roles table
    final roleRow = await _client
        .from('roles')
        .select('role_id')
        .eq('name', normalizedRole)
        .maybeSingle();
    if (roleRow == null) return null;
    final roleId = roleRow['role_id'] as int;

    final userName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : email.split('@').first;

    // Check if the user already exists to avoid overwriting an existing role
    final existing = await _client
        .from('users')
        .select('user_id, role_id')
        .eq('supabase_id', supabaseId)
        .maybeSingle();

    int userId;
    if (existing != null) {
      userId = existing['user_id'] as int;
      final updateData = <String, dynamic>{
        'name': userName,
        'email': email,
      };
      if (role != null) updateData['role_id'] = roleId;
      if (profile?['objective'] != null) {
        updateData['objective'] = profile!['objective'];
      }
      await _client.from('users').update(updateData).eq('user_id', userId);
    } else {
      final inserted = await _client
          .from('users')
          .insert({
            'supabase_id': supabaseId,
            'email': email,
            'name': userName,
            'role_id': roleId,
            if (profile?['objective'] != null) 'objective': profile!['objective'],
          })
          .select('user_id')
          .single();
      userId = inserted['user_id'] as int;
    }

    // Create role-specific profile record
    switch (normalizedRole) {
      case 'coach':
        await _client
            .from('coaches')
            .upsert({'user_id': userId}, onConflict: 'user_id');
      case 'cliente':
        await _client
            .from('clients')
            .upsert({'user_id': userId}, onConflict: 'user_id');
      case 'nutriologo':
        final license = (profile?['licenseNumber'] as String?)?.trim();
        final focus = (profile?['focus'] as String?)?.trim();
        await _client.from('nutriologos').upsert(
          {
            'user_id': userId,
            'license_number':
                (license?.isNotEmpty == true) ? license : 'PENDIENTE',
            'focus': (focus?.isNotEmpty == true) ? focus : 'General',
          },
          onConflict: 'user_id',
        );
    }

    // Reflect role in Supabase user_metadata so the JWT carries it
    await _client.auth
        .updateUser(UserAttributes(data: {'role': normalizedRole}));
    await _client.auth.refreshSession();

    _localRoleOverride = normalizedRole;
    return normalizedRole;
  }
}
