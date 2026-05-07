import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApi {
  static final _db = Supabase.instance.client;

  // ── Context ───────────────────────────────────────────────────────────────

  static Future<int?> _adminUserId() async {
    final authId = _db.auth.currentUser?.id;
    if (authId == null) return null;
    final row = await _db
        .from('users')
        .select('user_id')
        .eq('supabase_id', authId)
        .maybeSingle();
    return row?['user_id'] as int?;
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getUsers({
    String search = '',
    String? role,
    int page = 1,
    int perPage = 20,
  }) async {
    var q = _db
        .from('users')
        .select('user_id,name,email,avatar_url,created_at,roles(name)');

    if (search.isNotEmpty) {
      q = q.or('name.ilike.%$search%,email.ilike.%$search%');
    }

    if (role != null && role.isNotEmpty) {
      q = q.eq('roles.name', role);
    }

    final all = await q.order('created_at', ascending: false);
    final total = (all as List).length;
    final start = ((page - 1) * perPage).clamp(0, total);
    final end = (start + perPage).clamp(0, total);

    return {
      'data': all.sublist(start, end),
      'meta': {
        'current_page': page,
        'last_page': total == 0 ? 1 : (total / perPage).ceil(),
        'total': total,
        'has_more': (start + perPage) < total,
      },
    };
  }

  // ── Professional Validation ───────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getProfessionals({
    String? status,
  }) async {
    // Coaches
    var cq = _db.from('coaches').select(
      'user_id,is_verified,verified_at,rejection_reason,'
      'certificate_uploads,bio,specialty,experience_years,created_at,'
      'users!user_id(name,email,avatar_url)',
    );
    if (status == 'verified') cq = cq.eq('is_verified', true);
    if (status == 'pending') {
      cq = cq.eq('is_verified', false).filter('rejection_reason', 'is', null);
    }
    if (status == 'rejected') {
      cq = cq.eq('is_verified', false).not('rejection_reason', 'is', null);
    }

    final coaches = await cq.order('created_at', ascending: false);

    // Nutriologos
    var nq = _db.from('nutriologos').select(
      'user_id,is_verified,verified_at,rejection_reason,'
      'certificate_uploads,bio,focus,experience_years,license_number,created_at,'
      'users!user_id(name,email,avatar_url)',
    );
    if (status == 'verified') nq = nq.eq('is_verified', true);
    if (status == 'pending') {
      nq = nq.eq('is_verified', false).filter('rejection_reason', 'is', null);
    }
    if (status == 'rejected') {
      nq = nq.eq('is_verified', false).not('rejection_reason', 'is', null);
    }

    final nutriologos = await nq.order('created_at', ascending: false);

    final result = <Map<String, dynamic>>[];

    for (final c in coaches as List) {
      final user = c['users'] as Map?;
      result.add({
        'user_id': c['user_id'],
        'type': 'coach',
        'name': user?['name'],
        'email': user?['email'],
        'avatar_url': user?['avatar_url'],
        'is_verified': c['is_verified'] ?? false,
        'verified_at': c['verified_at'],
        'rejection_reason': c['rejection_reason'],
        'certificate_uploads': c['certificate_uploads'] ?? [],
        'bio': c['bio'],
        'specialty': c['specialty'],
        'experience_years': c['experience_years'],
        'created_at': c['created_at'],
      });
    }

    for (final n in nutriologos as List) {
      final user = n['users'] as Map?;
      result.add({
        'user_id': n['user_id'],
        'type': 'nutriologo',
        'name': user?['name'],
        'email': user?['email'],
        'avatar_url': user?['avatar_url'],
        'is_verified': n['is_verified'] ?? false,
        'verified_at': n['verified_at'],
        'rejection_reason': n['rejection_reason'],
        'certificate_uploads': n['certificate_uploads'] ?? [],
        'bio': n['bio'],
        'specialty': n['focus'],
        'experience_years': n['experience_years'],
        'license_number': n['license_number'],
        'created_at': n['created_at'],
      });
    }

    result.sort((a, b) {
      final da = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(0);
      final db = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(0);
      return db.compareTo(da);
    });

    return result;
  }

  static Future<void> verifyProfessional(int userId, String type) async {
    final adminId = await _adminUserId();
    final now = DateTime.now().toIso8601String();
    final table = type == 'coach' ? 'coaches' : 'nutriologos';

    await _db.from(table).update({
      'is_verified': true,
      'verified_at': now,
      'verified_by': adminId,
      'rejection_reason': null,
    }).eq('user_id', userId);
  }

  static Future<void> rejectProfessional(
      int userId, String type, String reason) async {
    final adminId = await _adminUserId();
    final table = type == 'coach' ? 'coaches' : 'nutriologos';

    await _db.from(table).update({
      'is_verified': false,
      'verified_at': null,
      'verified_by': adminId,
      'rejection_reason': reason,
    }).eq('user_id', userId);
  }

  // ── Tickets ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getTickets({
    String? status,
    String? category,
    String? urgency,
  }) async {
    var q = _db.from('tickets').select(
      'ticket_id,subject,status,category,urgency,created_at,user_id,'
      'users!user_id(name,email,avatar_url)',
    );

    if (status != null) q = q.eq('status', status);
    if (category != null) q = q.eq('category', category);
    if (urgency != null) q = q.eq('urgency', urgency);

    final rows = await q.order('created_at', ascending: false);

    return (rows as List).map((t) {
      final user = t['users'] as Map?;
      return <String, dynamic>{
        'ticket_id': t['ticket_id'],
        'subject': t['subject'],
        'status': t['status'],
        'category': t['category'],
        'urgency': t['urgency'],
        'created_at': t['created_at'],
        'user_id': t['user_id'],
        'user_name': user?['name'],
        'user_email': user?['email'],
        'user_avatar': user?['avatar_url'],
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> getTicketDetail(int ticketId) async {
    final ticket = await _db.from('tickets').select(
      'ticket_id,subject,status,category,urgency,created_at,user_id,'
      'users!user_id(name,email,avatar_url)',
    ).eq('ticket_id', ticketId).single();

    final messages = await _db.from('messages').select(
      'message_id,sender_id,content,sent_at,'
      'users!sender_id(name,avatar_url)',
    ).eq('ticket_id', ticketId).order('sent_at');

    final user = ticket['users'] as Map?;
    return {
      'ticket_id': ticket['ticket_id'],
      'subject': ticket['subject'],
      'status': ticket['status'],
      'category': ticket['category'],
      'urgency': ticket['urgency'],
      'created_at': ticket['created_at'],
      'user_name': user?['name'],
      'user_email': user?['email'],
      'messages': (messages as List).map((m) {
        final sender = m['users'] as Map?;
        return {
          'message_id': m['message_id'],
          'sender_id': m['sender_id'],
          'sender_name': sender?['name'],
          'content': m['content'],
          'sent_at': m['sent_at'],
        };
      }).toList(),
    };
  }

  static Future<void> updateTicketStatus(int ticketId, String status) async {
    final update = <String, dynamic>{'status': status};
    if (status == 'resolved' || status == 'closed') {
      update['resolved_at'] = DateTime.now().toIso8601String();
    }
    await _db.from('tickets').update(update).eq('ticket_id', ticketId);
  }

  static Future<void> replyToTicket(int ticketId, String content) async {
    final adminId = await _adminUserId();
    await _db.from('messages').insert({
      'ticket_id': ticketId,
      'sender_id': adminId,
      'content': content,
      'sent_at': DateTime.now().toIso8601String(),
    });
    // Move to in_progress if still open
    await _db
        .from('tickets')
        .update({'status': 'in_progress'})
        .eq('ticket_id', ticketId)
        .eq('status', 'open');
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getOverview() async {
    final sevenDaysAgo =
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

    final results = await Future.wait([
      _db.from('users').select('user_id'),
      _db
          .from('coaches')
          .select('user_id')
          .eq('is_verified', false)
          .filter('rejection_reason', 'is', null),
      _db
          .from('nutriologos')
          .select('user_id')
          .eq('is_verified', false)
          .filter('rejection_reason', 'is', null),
      _db.from('tickets').select('ticket_id').eq('status', 'open'),
      _db.from('users').select('user_id').gte('created_at', sevenDaysAgo),
      _db.from('users').select('roles!role_id(name)'),
    ]);

    final totalUsers = (results[0] as List).length;
    final pendingCoaches = (results[1] as List).length;
    final pendingNutri = (results[2] as List).length;
    final openTickets = (results[3] as List).length;
    final newUsers7d = (results[4] as List).length;

    final roleCounts = <String, int>{};
    for (final r in results[5] as List) {
      final name = (r['roles'] as Map?)?['name'] as String? ?? 'unknown';
      roleCounts[name] = (roleCounts[name] ?? 0) + 1;
    }

    return {
      'total_users': totalUsers,
      'new_users_7d': newUsers7d,
      'pending_verification': pendingCoaches + pendingNutri,
      'open_tickets': openTickets,
      'role_distribution': roleCounts,
    };
  }

  static Future<List<Map<String, dynamic>>> getUserGrowth({int days = 7}) async {
    final from = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final rows = await _db
        .from('users')
        .select('created_at')
        .gte('created_at', from)
        .order('created_at');

    final byDay = <String, int>{};
    for (final r in rows as List) {
      final date = (r['created_at'] as String).substring(0, 10);
      byDay[date] = (byDay[date] ?? 0) + 1;
    }

    return byDay.entries
        .map((e) => {'date': e.key, 'count': e.value})
        .toList();
  }
}
