import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/api_config.dart';
import '../../sections/nutrition/models/nutrition_model.dart';

class NutritionService {
  static final _supabase = Supabase.instance.client;

  static Future<String?> _token() async =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  /// Returns pending diet change requests for the logged-in client.
  static Future<List<Map<String, dynamic>>> getDietChanges() async {
    final token = await _token();
    if (token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cliente/cambios-dieta'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List? ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .where((d) => d['status'] == 'pending')
        .toList();
  }

  /// Accepts or rejects a diet change proposal.
  /// [status] must be 'approved' or 'rejected'.
  static Future<bool> responderCambioDieta(
      int id, String status, {String? response}) async {
    final token = await _token();
    if (token == null) return false;
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/cliente/cambios-dieta/$id/responder'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
        if (response != null && response.isNotEmpty) 'client_response': response,
      }),
    );
    return res.statusCode == 200;
  }

  /// Returns the active nutrition plan assigned to the logged-in client,
  /// or null if none exists. Queries Supabase directly — no server needed.
  static Future<NutritionPlanModel?> getAssignedPlan() async {
    final authId = _supabase.auth.currentUser?.id;
    if (authId == null) return null;

    final userRow = await _supabase
        .from('users')
        .select('user_id')
        .eq('supabase_id', authId)
        .maybeSingle();
    if (userRow == null) return null;
    final clientId = userRow['user_id'] as int;

    final assignment = await _supabase
        .from('nutrition_plan_assignments')
        .select(
          'nutrition_plan_id,'
          'nutrition_plans('
            'id,title,description,goal,daily_calories,macro_targets,'
            'is_active,starts_at,ends_at,'
            'nutrition_plan_meals('
              'id,meal_type,name,portion,calories,'
              'protein_g,carbs_g,fat_g,notes,position'
            ')'
          ')',
        )
        .eq('client_id', clientId)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (assignment == null) return null;

    final planData = assignment['nutrition_plans'] as Map<String, dynamic>?;
    if (planData == null) return null;

    // NutritionPlanModel.fromMap expects key 'meals'; Supabase returns the
    // nested relation under the table name 'nutrition_plan_meals'.
    final reshaped = Map<String, dynamic>.from(planData)
      ..['meals'] = planData['nutrition_plan_meals'] ?? [];

    return NutritionPlanModel.fromMap(reshaped);
  }
}
