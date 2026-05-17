import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_service.dart';
import '../../sections/nutrition/models/nutrition_model.dart';

class NutritionService {
  static final _supabase = Supabase.instance.client;

  static Future<int?> _clientId() => AuthService.getNumericUserId();

  /// Returns pending diet change requests for the logged-in client.
  static Future<List<Map<String, dynamic>>> getDietChanges() async {
    final clientId = await _clientId();
    if (clientId == null) return [];

    final rows = await _supabase
        .from('diet_change_requests')
        .select(
          'id, change_type, previous_value, new_value, reason, status,'
          ' client_response, responded_at, date, users!proposed_by(name)',
        )
        .eq('client_id', clientId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (rows as List)
        .map((d) => <String, dynamic>{
              'id': d['id'],
              'proposed_by': (d['users'] as Map?)?['name'],
              'change_type': d['change_type'],
              'previous_value': d['previous_value'],
              'new_value': d['new_value'],
              'reason': d['reason'],
              'status': d['status'],
              'client_response': d['client_response'],
              'responded_at': d['responded_at'],
              'date': d['date'],
            })
        .toList();
  }

  /// Accepts or rejects a diet change proposal.
  /// [status] must be 'approved' or 'rejected'.
  static Future<bool> responderCambioDieta(
      int id, String status, {String? response}) async {
    final clientId = await _clientId();
    if (clientId == null) return false;

    await _supabase
        .from('diet_change_requests')
        .update({
          'status': status,
          'client_response':
              (response?.isNotEmpty == true) ? response : null,
          'responded_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('client_id', clientId)
        .eq('status', 'pending');

    return true;
  }

  /// Returns the active nutrition plan assigned to the logged-in client,
  /// or null if none exists. Queries Supabase directly — no server needed.
  static Future<NutritionPlanModel?> getAssignedPlan() async {
    final clientId = await AuthService.getNumericUserId();
    if (clientId == null) return null;

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

    final reshaped = Map<String, dynamic>.from(planData)
      ..['meals'] = planData['nutrition_plan_meals'] ?? [];

    return NutritionPlanModel.fromMap(reshaped);
  }
}
