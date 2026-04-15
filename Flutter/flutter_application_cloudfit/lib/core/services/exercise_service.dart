import 'package:supabase_flutter/supabase_flutter.dart';
import '../../sections/workout/models/exercise_model.dart';

class ExerciseService {
  static final _supabase = Supabase.instance.client;

  /// Todos los ejercicios ordenados
  static Future<List<RoutineExercise>> getAll() async {
    final response = await _supabase
        .from('routine_exercises')
        .select()
        .order('routine_id')
        .order('order');

    return (response as List)
        .map((e) => RoutineExercise.fromMap(e))
        .toList();
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

  /// Stream en tiempo real (todos los ejercicios)
  static Stream<List<RoutineExercise>> getExercisesStream() {
    return _supabase
        .from('routine_exercises')
        .stream(primaryKey: ['id'])
        .order('order')
        .map((data) => data.map((e) => RoutineExercise.fromMap(e)).toList())
        .asBroadcastStream();
  }
}