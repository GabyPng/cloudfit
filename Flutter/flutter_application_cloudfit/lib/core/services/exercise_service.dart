import 'package:supabase_flutter/supabase_flutter.dart';
import '../../sections/workout/models/exercise_model.dart';

class ExerciseService {
  static final _supabase = Supabase.instance.client;

  /// Ejercicios de las rutinas activas asignadas al cliente logueado
  static Future<List<RoutineExercise>> getClientExercises() async {
    final authId = _supabase.auth.currentUser?.id;
    if (authId == null) return [];

    final userData = await _supabase
        .from('users')
        .select('user_id')
        .eq('supabase_id', authId)
        .maybeSingle();

    if (userData == null) return [];
    final clientId = userData['user_id'];

    final routinesData = await _supabase
        .from('routines')
        .select('id, name')
        .eq('client_id', clientId)
        .eq('is_active', true);

    final routines = routinesData as List;
    if (routines.isEmpty) return [];

    final routineIds = routines.map((r) => r['id'] as int).toList();
    final routineNames = <int, String>{
      for (final r in routines) r['id'] as int: (r['name'] as String? ?? 'Rutina'),
    };

    final exercisesData = await _supabase
        .from('routine_exercises')
        .select()
        .inFilter('routine_id', routineIds)
        .order('routine_id')
        .order('order');

    return (exercisesData as List).map((e) {
      final ex = RoutineExercise.fromMap(e);
      return ex.copyWith(routineName: routineNames[ex.routineId]);
    }).toList();
  }

  /// Ejercicios de una rutina específica
  static Future<List<RoutineExercise>> getByRoutine(int routineId) async {
    final response = await _supabase
        .from('routine_exercises')
        .select()
        .eq('routine_id', routineId)
        .order('order');

    return (response as List)
        .map((e) => RoutineExercise.fromMap(e))
        .toList();
  }
}