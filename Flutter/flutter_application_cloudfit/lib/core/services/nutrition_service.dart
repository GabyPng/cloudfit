import 'package:supabase_flutter/supabase_flutter.dart';
import '../../sections/nutrition/models/nutrition_model.dart';

class NutritionService {
  static final _supabase = Supabase.instance.client;

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
