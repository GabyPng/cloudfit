import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
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

  static Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    await _client.auth.updateUser(
      UserAttributes(data: metadata),
    );
  }

  static Future<String?> syncCurrentUser({String? name, String? role, Map<String, dynamic>? profile}) async {
  final token = _client.auth.currentSession?.accessToken;
  if (token == null) return null;

  final Map<String, dynamic> body = {};
  if (name != null && name.trim().isNotEmpty) body['name'] = name.trim();
  if (role != null) body['role'] = role;
  if (profile != null) body['profile'] = profile;

  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/sync'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode >= 400) {
    throw Exception('Sync failed: ${response.statusCode} ${response.body}');
  }

  await _client.auth.refreshSession();
  
  try {
    final responseData = jsonDecode(response.body);
    final backendRole = responseData['user']?['role']?['name'] as String?;
    if (backendRole != null) {
      _localRoleOverride = backendRole;
      return backendRole;
    }
  } catch (e) {
    print('Failed to parse role from sync response: $e');
  }
  return null;
}

}
