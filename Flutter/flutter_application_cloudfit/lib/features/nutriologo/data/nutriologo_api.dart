import 'package:supabase_flutter/supabase_flutter.dart';

/// All nutriólogo data access goes directly through Supabase SDK.
/// No Laravel server required.
class NutriologoApi {
  static final _supabase = Supabase.instance.client;

  // Dashboard cache — avoids redundant round-trips when navigating back.
  static Map<String, dynamic>? _dashboardCache;
  static DateTime? _dashboardCachedAt;

  // ── Internal context helper ───────────────────────────────────────────────

  /// Returns the numeric user_id and the nutriologos.id for the current user.
  /// Throws if the user is not authenticated or has no nutriologo profile.
  static Future<_NutriologoCtx> _getCtx() async {
    final authId = _supabase.auth.currentUser?.id;
    if (authId == null) throw Exception('No auth token available.');

    final userRow = await _supabase
        .from('users')
        .select('user_id')
        .eq('supabase_id', authId)
        .maybeSingle();
    if (userRow == null) throw Exception('No auth token available.');
    final userId = userRow['user_id'] as int;

    final nutriologoRow = await _supabase
        .from('nutriologos')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (nutriologoRow == null) throw Exception('No auth token available.');
    final nutriologoId = nutriologoRow['id'] as int;

    return _NutriologoCtx(userId, nutriologoId);
  }

  static String _statusLabel(String? s) => switch (s) {
        'active' => 'Seguimiento activo',
        'paused' => 'Plan pausado',
        'completed' => 'Objetivo cumplido',
        'cancelled' => 'Requiere atención',
        _ => 'Sin plan asignado',
      };

  // ── Dashboard ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboard({bool force = false}) async {
    final cachedAt = _dashboardCachedAt;
    if (!force &&
        _dashboardCache != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt).inSeconds < 60) {
      return _dashboardCache!;
    }

    final ctx = await _getCtx();

    final allAssignments = await _supabase
        .from('nutrition_plan_assignments')
        .select(
          'id,client_id,status,ends_at,assigned_at,created_at,'
          'nutrition_plan_id,nutrition_plans(title)',
        )
        .eq('nutriologo_id', ctx.nutriologoId)
        .order('created_at', ascending: false);

    final assignments = allAssignments as List;
    final total = assignments.length;
    final active =
        assignments.where((a) => a['status'] == 'active').length;
    final uniqueClientIds =
        assignments.map((a) => a['client_id'] as int).toSet();

    final now = DateTime.now();
    final som = DateTime(now.year, now.month);
    final eom = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final newThisMonth = assignments
        .where((a) {
          final raw = a['assigned_at'] ?? a['created_at'];
          final d = raw != null ? DateTime.tryParse(raw.toString()) : null;
          return d != null && d.isAfter(som) && d.isBefore(eom);
        })
        .map((a) => a['client_id'] as int)
        .toSet()
        .length;

    final alerts = assignments.where((a) {
      if (a['status'] == 'paused' || a['status'] == 'cancelled') return true;
      final ea = a['ends_at'];
      return ea != null &&
          (DateTime.tryParse(ea.toString())?.isBefore(now) ?? false);
    }).length;

    final planesData = await _supabase
        .from('nutrition_plans')
        .select('id')
        .eq('nutriologo_id', ctx.nutriologoId)
        .eq('is_active', true);
    final planesActivos = (planesData as List).length;

    // Recent clients
    final recentIds =
        assignments.take(8).map((a) => a['client_id'] as int).toSet().toList();

    List<Map<String, dynamic>> pacientes = [];
    List<Map<String, dynamic>> actividades = [];

    if (recentIds.isNotEmpty) {
      final clientsData = await _supabase
          .from('users')
          .select('user_id,name,avatar_url,objective')
          .inFilter('user_id', recentIds);

      final clientsMap = <int, Map<String, dynamic>>{
        for (final c in clientsData as List)
          c['user_id'] as int: c as Map<String, dynamic>,
      };

      pacientes = assignments.take(8).map((a) {
        final client = clientsMap[a['client_id'] as int];
        final status = a['status'] as String? ?? 'active';
        final ea = a['ends_at'];
        final isAlert = status == 'paused' ||
            status == 'cancelled' ||
            (ea != null &&
                (DateTime.tryParse(ea.toString())?.isBefore(now) ?? false));
        return <String, dynamic>{
          'id': a['client_id'],
          'nombre': client?['name'] ?? 'Paciente sin nombre',
          'avatar_url': client?['avatar_url'],
          'plan_nombre':
              (a['nutrition_plans'] as Map?)?['title'] ?? 'Sin plan asignado',
          'estado': isAlert ? 'alerta' : 'activo',
          'estado_label': _statusLabel(status),
          'objetivo': client?['objective'] ?? 'Sin objetivo registrado',
          'ultimo_registro': 'Reciente',
        };
      }).toList();

      actividades = assignments.take(6).map((a) {
        final status = a['status'] as String? ?? 'active';
        final planTitle =
            (a['nutrition_plans'] as Map?)?['title'] ?? 'nutricional';
        final clientName =
            clientsMap[a['client_id'] as int]?['name'] ?? 'Paciente';
        final (tipo, detalle) = switch (status) {
          'completed' => (
              'objetivo_cumplido',
              'completó su plan $planTitle',
            ),
          'paused' => ('alerta_nutricional', 'tiene su plan en pausa'),
          'cancelled' => (
              'alerta_nutricional',
              'requiere revisión de seguimiento',
            ),
          _ => ('plan_asignado', 'tiene activo el plan $planTitle'),
        };
        return <String, dynamic>{
          'tipo': tipo,
          'cliente_nombre': clientName,
          'detalle': detalle,
          'tiempo_hace': 'Reciente',
        };
      }).toList();
    }

    final result = <String, dynamic>{
      'message': 'Bienvenido al panel de Nutriologo.',
      'section': 'nutriologo',
      'stats': {
        'total_pacientes': uniqueClientIds.length,
        'nuevos_este_mes': newThisMonth,
        'adherencia_promedio':
            total > 0 ? ((active / total) * 100).toInt() : 0,
        'alertas_nutricionales': alerts,
        'planes_activos': planesActivos,
      },
      'pacientes': pacientes,
      'actividades': actividades,
    };

    _dashboardCache = result;
    _dashboardCachedAt = DateTime.now();
    return result;
  }

  // ── Clients ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getClientsPage({
    String search = '',
    int page = 1,
    int perPage = 10,
  }) async {
    final ctx = await _getCtx();

    // Collect client IDs from assignments + clients.nutritionist_id
    final fromAssignments = await _supabase
        .from('nutrition_plan_assignments')
        .select('client_id')
        .eq('nutriologo_id', ctx.nutriologoId);

    final fromClients = await _supabase
        .from('clients')
        .select('user_id')
        .eq('nutritionist_id', ctx.userId);

    final allIds = {
      ...(fromAssignments as List).map((a) => a['client_id'] as int),
      ...(fromClients as List).map((c) => c['user_id'] as int),
    }.toList();

    if (allIds.isEmpty) {
      return _emptyPage(page, perPage);
    }

    var q = _supabase
        .from('users')
        .select('user_id,name,email,avatar_url,objective')
        .inFilter('user_id', allIds);

    if (search.trim().isNotEmpty) {
      q = q.or('name.ilike.%${search.trim()}%,email.ilike.%${search.trim()}%');
    }

    final all = await q.order('name');
    final total = (all as List).length;
    final start = ((page - 1) * perPage).clamp(0, total);
    final end = (start + perPage).clamp(0, total);
    final pageItems = all.sublist(start, end);
    final lastPage = total == 0 ? 1 : (total / perPage).ceil();

    // Latest assignment per client on this page
    final pageIds = pageItems.map((c) => c['user_id'] as int).toList();
    final latestMap = <int, Map<String, dynamic>>{};

    if (pageIds.isNotEmpty) {
      final asgns = await _supabase
          .from('nutrition_plan_assignments')
          .select(
            'id,client_id,status,nutrition_plan_id,nutrition_plans(title)',
          )
          .eq('nutriologo_id', ctx.nutriologoId)
          .inFilter('client_id', pageIds)
          .order('created_at', ascending: false);

      for (final a in asgns as List) {
        final cid = a['client_id'] as int;
        if (!latestMap.containsKey(cid)) latestMap[cid] = a as Map<String, dynamic>;
      }
    }

    final data = pageItems.map((c) {
      final cid = c['user_id'] as int;
      final a = latestMap[cid];
      final status = a?['status'] as String?;
      final isAlert = status == 'paused' || status == 'cancelled';
      return <String, dynamic>{
        'id': cid,
        'name': c['name'],
        'email': c['email'],
        'avatar_url': c['avatar_url'],
        'objective': c['objective'],
        'assignment_id': a?['id'],
        'current_plan': (a?['nutrition_plans'] as Map?)?['title'],
        'current_plan_id': a?['nutrition_plan_id'],
        'status_key': status,
        'status': isAlert ? 'alerta' : (status ?? 'sin_plan'),
        'status_label': _statusLabel(status),
        'last_update': 'Sin seguimiento reciente',
      };
    }).toList();

    return {
      'data': data,
      'meta': {
        'current_page': page,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
        'has_more': page < lastPage,
      },
    };
  }

  // ── Plans ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getPlansPage({
    String search = '',
    int page = 1,
    int perPage = 10,
  }) async {
    final ctx = await _getCtx();

    var q = _supabase
        .from('nutrition_plans')
        .select('id,title,description,goal,daily_calories,is_active,created_at')
        .eq('nutriologo_id', ctx.nutriologoId);

    if (search.trim().isNotEmpty) {
      q = q.or('title.ilike.%${search.trim()}%,goal.ilike.%${search.trim()}%');
    }

    final all = await q.order('created_at', ascending: false);
    final total = (all as List).length;
    final start = ((page - 1) * perPage).clamp(0, total);
    final end = (start + perPage).clamp(0, total);
    final pageItems = all.sublist(start, end);
    final lastPage = total == 0 ? 1 : (total / perPage).ceil();

    final planIds = pageItems.map((p) => p['id'] as int).toList();
    final mealCounts = <int, int>{};
    final assignCounts = <int, int>{};

    if (planIds.isNotEmpty) {
      final meals = await _supabase
          .from('nutrition_plan_meals')
          .select('nutrition_plan_id')
          .inFilter('nutrition_plan_id', planIds);
      for (final m in meals as List) {
        final id = m['nutrition_plan_id'] as int;
        mealCounts[id] = (mealCounts[id] ?? 0) + 1;
      }

      final asgns = await _supabase
          .from('nutrition_plan_assignments')
          .select('nutrition_plan_id')
          .inFilter('nutrition_plan_id', planIds);
      for (final a in asgns) {
        final id = a['nutrition_plan_id'] as int;
        assignCounts[id] = (assignCounts[id] ?? 0) + 1;
      }
    }

    final data = pageItems.map((p) {
      final id = p['id'] as int;
      return <String, dynamic>{
        ...p,
        'meals_count': mealCounts[id] ?? 0,
        'assignments_count': assignCounts[id] ?? 0,
      };
    }).toList();

    return {
      'data': data,
      'meta': {
        'current_page': page,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
        'has_more': page < lastPage,
      },
    };
  }

  static Future<Map<String, dynamic>> getPlanDetail(int planId) async {
    final ctx = await _getCtx();

    final plan = await _supabase
        .from('nutrition_plans')
        .select(
          '*,nutrition_plan_meals('
          'id,meal_type,name,portion,calories,protein_g,carbs_g,fat_g,notes,position'
          ')',
        )
        .eq('id', planId)
        .eq('nutriologo_id', ctx.nutriologoId)
        .single();

    return plan;
  }

  static Future<Map<String, dynamic>> createPlan({
    required String title,
    String? description,
    String? goal,
    int? dailyCalories,
    List<Map<String, dynamic>> meals = const [],
  }) async {
    final ctx = await _getCtx();

    final inserted = await _supabase
        .from('nutrition_plans')
        .insert({
          'nutriologo_id': ctx.nutriologoId,
          'title': title,
          if (description?.isNotEmpty == true) 'description': description,
          if (goal?.isNotEmpty == true) 'goal': goal,
          if (dailyCalories != null) 'daily_calories': dailyCalories,
          'is_active': true,
        })
        .select('id')
        .single();

    final planId = inserted['id'] as int;

    if (meals.isNotEmpty) {
      final mealsData = meals.asMap().entries.map((e) => {
            'nutrition_plan_id': planId,
            ...e.value,
            'position': e.key,
          }).toList();
      await _supabase.from('nutrition_plan_meals').insert(mealsData);
    }

    final plan = await _supabase
        .from('nutrition_plans')
        .select('*,nutrition_plan_meals(*)')
        .eq('id', planId)
        .single();

    return plan;
  }

  static Future<Map<String, dynamic>> assignPlan({
    required int planId,
    required int clientId,
    String? startsAt,
    String? notes,
  }) async {
    final ctx = await _getCtx();

    final assignment = await _supabase
        .from('nutrition_plan_assignments')
        .upsert({
          'nutrition_plan_id': planId,
          'client_id': clientId,
          'nutriologo_id': ctx.nutriologoId,
          'assigned_at': DateTime.now().toIso8601String().split('T').first,
          'status': 'active',
          if (startsAt?.isNotEmpty == true) 'starts_at': startsAt,
          if (notes?.isNotEmpty == true) 'notes': notes,
        })
        .select()
        .single();

    return assignment;
  }

  static Future<Map<String, dynamic>> updatePlan({
    required int planId,
    String? title,
    String? description,
    String? goal,
    int? dailyCalories,
    bool? isActive,
  }) async {
    final ctx = await _getCtx();

    final payload = <String, dynamic>{
      if (title?.isNotEmpty == true) 'title': title,
      if (description != null) 'description': description,
      if (goal != null) 'goal': goal,
      if (dailyCalories != null) 'daily_calories': dailyCalories,
      if (isActive != null) 'is_active': isActive,
    };

    final plan = await _supabase
        .from('nutrition_plans')
        .update(payload)
        .eq('id', planId)
        .eq('nutriologo_id', ctx.nutriologoId)
        .select('*,nutrition_plan_meals(*)')
        .single();

    return plan;
  }

  static Future<void> deletePlan(int planId) async {
    final ctx = await _getCtx();

    await _supabase
        .from('nutrition_plans')
        .delete()
        .eq('id', planId)
        .eq('nutriologo_id', ctx.nutriologoId);
  }

  static Future<Map<String, dynamic>> updateAssignmentStatus({
    required int assignmentId,
    required String status,
  }) async {
    final ctx = await _getCtx();

    final assignment = await _supabase
        .from('nutrition_plan_assignments')
        .update({'status': status})
        .eq('id', assignmentId)
        .eq('nutriologo_id', ctx.nutriologoId)
        .select()
        .single();

    return assignment;
  }

  // ── Seguimiento ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getSeguimientoPacientes() async {
    final ctx = await _getCtx();

    final assignRows = await _supabase
        .from('nutrition_plan_assignments')
        .select('client_id')
        .eq('nutriologo_id', ctx.nutriologoId);

    final clientIds = assignRows
        .map((a) => a['client_id'] as int)
        .toSet()
        .toList();

    if (clientIds.isEmpty) return [];

    final clients = await _supabase
        .from('users')
        .select('user_id,name,email')
        .inFilter('user_id', clientIds);

    // Last progress record per client
    final progressRows = await _supabase
        .from('progress_records')
        .select('client_id,date,weight_kg,adherence_pct')
        .inFilter('client_id', clientIds)
        .order('date', ascending: false);

    final lastRecordMap = <int, Map<String, dynamic>>{};
    for (final r in progressRows) {
      final cid = r['client_id'] as int;
      if (!lastRecordMap.containsKey(cid)) {
        lastRecordMap[cid] = r;
      }
    }

    // Pending diet-change requests per client
    final pendingRows = await _supabase
        .from('diet_change_requests')
        .select('client_id')
        .inFilter('client_id', clientIds)
        .eq('status', 'pending');

    final pendingCountMap = <int, int>{};
    for (final p in pendingRows) {
      final cid = p['client_id'] as int;
      pendingCountMap[cid] = (pendingCountMap[cid] ?? 0) + 1;
    }

    return clients.map((c) {
      final cid = c['user_id'] as int;
      final rec = lastRecordMap[cid];
      return <String, dynamic>{
        'id': cid,
        'name': c['name'],
        'email': c['email'],
        'last_record_date': rec?['date'],
        'last_weight_kg': rec?['weight_kg'],
        'last_adherence': rec?['adherence_pct'],
        'pending_changes': pendingCountMap[cid] ?? 0,
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> getHistorial(int clientId) async {
    final ctx = await _getCtx();

    final progressRows = await _supabase
        .from('progress_records')
        .select(
          'id,date,weight_kg,bmi,body_fat_pct,muscle_mass_kg,'
          'calories_target,adherence_pct,notes,author_role,created_at,'
          'users!author_id(name)',
        )
        .eq('client_id', clientId)
        .order('date', ascending: false)
        .limit(150);

    final dietRows = await _supabase
        .from('diet_change_requests')
        .select(
          'id,date,change_type,previous_value,new_value,reason,'
          'status,client_response,responded_at,created_at,'
          'users!proposed_by(name)',
        )
        .eq('client_id', clientId)
        .order('date', ascending: false)
        .limit(150);

    final assignRows = await _supabase
        .from('nutrition_plan_assignments')
        .select(
          'id,nutrition_plan_id,status,notes,starts_at,ends_at,'
          'assigned_at,created_at,nutrition_plans(title,goal,daily_calories)',
        )
        .eq('client_id', clientId)
        .eq('nutriologo_id', ctx.nutriologoId)
        .order('assigned_at', ascending: false);

    final clientRow = await _supabase
        .from('users')
        .select('user_id,name,email')
        .eq('user_id', clientId)
        .single();

    final progressTimeline = progressRows.map((r) => <String, dynamic>{
          'type': 'progreso',
          'id': r['id'],
          'date': r['date'],
          'author_name': (r['users'] as Map?)?['name'],
          'author_role': r['author_role'],
          'weight_kg': r['weight_kg'],
          'bmi': r['bmi'],
          'body_fat_pct': r['body_fat_pct'],
          'muscle_mass_kg': r['muscle_mass_kg'],
          'calories_target': r['calories_target'],
          'adherence_pct': r['adherence_pct'],
          'notes': r['notes'],
          'created_at': r['created_at'],
        }).toList();

    final dietTimeline = dietRows.map((d) => <String, dynamic>{
          'type': 'cambio_dieta',
          'id': d['id'],
          'date': d['date'],
          'proposed_by': (d['users'] as Map?)?['name'],
          'change_type': d['change_type'],
          'previous_value': d['previous_value'],
          'new_value': d['new_value'],
          'reason': d['reason'],
          'status': d['status'],
          'client_response': d['client_response'],
          'responded_at': d['responded_at'],
          'created_at': d['created_at'],
        }).toList();

    final assignTimeline = assignRows.map((a) => <String, dynamic>{
          'type': 'asignacion_plan',
          'id': a['id'],
          'date': a['assigned_at'] ?? a['created_at'],
          'plan_title': (a['nutrition_plans'] as Map?)?['title'],
          'plan_id': a['nutrition_plan_id'],
          'plan_goal': (a['nutrition_plans'] as Map?)?['goal'],
          'plan_calories': (a['nutrition_plans'] as Map?)?['daily_calories'],
          'status': a['status'],
          'notes': a['notes'],
          'starts_at': a['starts_at'],
          'ends_at': a['ends_at'],
          'created_at': a['created_at'],
        }).toList();

    final timeline = [...progressTimeline, ...dietTimeline, ...assignTimeline]
      ..sort((a, b) {
        final da = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(0);
        final db = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(0);
        return db.compareTo(da);
      });

    return {
      'client': clientRow,
      'timeline': timeline,
    };
  }

  static Future<Map<String, dynamic>> addProgress({
    required int clientId,
    required String date,
    double? weightKg,
    double? bmi,
    double? bodyFatPct,
    double? muscleMassKg,
    int? caloriesTarget,
    int? adherencePct,
    String? notes,
  }) async {
    final ctx = await _getCtx();

    final record = await _supabase
        .from('progress_records')
        .insert({
          'client_id': clientId,
          'author_id': ctx.userId,
          'author_role': 'nutriologo',
          'date': date,
          if (weightKg != null) 'weight_kg': weightKg,
          if (bmi != null) 'bmi': bmi,
          if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
          if (muscleMassKg != null) 'muscle_mass_kg': muscleMassKg,
          if (caloriesTarget != null) 'calories_target': caloriesTarget,
          if (adherencePct != null) 'adherence_pct': adherencePct,
          if (notes?.isNotEmpty == true) 'notes': notes,
        })
        .select()
        .single();

    return record;
  }

  // ── Perfil ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getPerfil() async {
    final ctx = await _getCtx();

    final user = await _supabase
        .from('users')
        .select('user_id,name,email')
        .eq('user_id', ctx.userId)
        .single();

    final nutriologo = await _supabase
        .from('nutriologos')
        .select(
          'id,license_number,focus,bio,specialties,experience_years,'
          'location,consultation_price,profile_visible,social_links,phone',
        )
        .eq('user_id', ctx.userId)
        .single();

    final asgns = await _supabase
        .from('nutrition_plan_assignments')
        .select('client_id,status')
        .eq('nutriologo_id', ctx.nutriologoId);

    final asnList = asgns;
    final totalPatients =
        asnList.map((a) => a['client_id']).toSet().length;
    final activePatients = asnList
        .where((a) => a['status'] == 'active')
        .map((a) => a['client_id'])
        .toSet()
        .length;

    final plans = await _supabase
        .from('nutrition_plans')
        .select('id')
        .eq('nutriologo_id', ctx.nutriologoId);
    final totalPlans = plans.length;

    final pending = await _supabase
        .from('nutriologo_contact_requests')
        .select('id')
        .eq('nutriologo_id', ctx.nutriologoId)
        .eq('status', 'pending');

    return <String, dynamic>{
      'user_id': user['user_id'],
      'name': user['name'],
      'email': user['email'],
      ...nutriologo,
      'specialties': nutriologo['specialties'] ?? [],
      'social_links': nutriologo['social_links'] ?? [],
      'stats': {
        'total_patients': totalPatients,
        'active_patients': activePatients,
        'total_plans': totalPlans,
        'pending_requests': pending.length,
      },
    };
  }

  static Future<Map<String, dynamic>> updatePerfil(
      Map<String, dynamic> data) async {
    final ctx = await _getCtx();

    final updated = await _supabase
        .from('nutriologos')
        .update(data)
        .eq('user_id', ctx.userId)
        .select()
        .single();

    return updated;
  }

  static Future<List<Map<String, dynamic>>> getSolicitudes({
    String status = 'pending',
  }) async {
    final ctx = await _getCtx();

    var q = _supabase
        .from('nutriologo_contact_requests')
        .select(
          'id,client_id,message,status,nutriologo_response,'
          'responded_at,created_at,users!client_id(name,email)',
        )
        .eq('nutriologo_id', ctx.nutriologoId);

    // Filters must come before order() — applying status before transform.
    if (status != 'all') q = q.eq('status', status);

    final rows = await q.order('created_at', ascending: false);
    return rows.map((r) => <String, dynamic>{
          'id': r['id'],
          'client_id': r['client_id'],
          'client_name': (r['users'] as Map?)?['name'],
          'client_email': (r['users'] as Map?)?['email'],
          'message': r['message'],
          'status': r['status'],
          'nutriologo_response': r['nutriologo_response'],
          'responded_at': r['responded_at'],
          'created_at': r['created_at'],
        }).toList();
  }

  static Future<void> responderSolicitud({
    required int id,
    required String status,
    String? response,
  }) async {
    final ctx = await _getCtx();

    await _supabase
        .from('nutriologo_contact_requests')
        .update({
          'status': status,
          if (response?.isNotEmpty == true) 'nutriologo_response': response,
          'responded_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('nutriologo_id', ctx.nutriologoId);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Map<String, dynamic> _emptyPage(int page, int perPage) => {
        'data': <dynamic>[],
        'meta': {
          'current_page': page,
          'last_page': 1,
          'per_page': perPage,
          'total': 0,
          'has_more': false,
        },
      };
}

// Simple context holder — avoids Dart record syntax for broader compatibility.
class _NutriologoCtx {
  final int userId;
  final int nutriologoId;
  const _NutriologoCtx(this.userId, this.nutriologoId);
}
