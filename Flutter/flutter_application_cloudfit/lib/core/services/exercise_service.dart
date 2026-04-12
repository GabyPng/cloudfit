import 'package:supabase_flutter/supabase_flutter.dart';
import '../../sections/workout/models/exercise_model.dart';

class ExerciseService {
  static final _supabase = Supabase.instance.client;
  
  static List<Exercise> _cachedExercises = [];
  static bool _hasLoadedCache = false;

  /// Obtener todos los ejercicios desde Supabase
  static Future<List<Exercise>> getAllExercises() async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .order('name', ascending: true) as List;

      if (response.isEmpty) {
        return [];
      }

      _cachedExercises = response
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
      
      _hasLoadedCache = true;
      
      return _cachedExercises;
    } catch (e) {
      return [];
    }
  }

  /// Obtener ejercicios por categoría
  static Future<List<Exercise>> getExercisesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .eq('category', category)
          .order('name', ascending: true) as List;

      return response
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener ejercicios por dificultad
  static Future<List<Exercise>> getExercisesByDifficulty(
      String difficulty) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .eq('difficulty', difficulty)
          .order('name', ascending: true) as List;

      return response
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Stream de ejercicios en tiempo real (usando polling)
  static Stream<List<Exercise>> getExercisesStream() async* {
    while (true) {
      try {
        final exercises = await getAllExercises();
        yield exercises;
        // Refrescar cada 30 segundos
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        yield _cachedExercises;
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  /// Obtener todas las categorías únicas
  static Future<List<String>> getCategories() async {
    try {
      final exercises = await getAllExercises();
      final categories = <String>{};
      
      for (var ex in exercises) {
        categories.add(ex.category);
      }
      
      return categories.toList()..sort();
    } catch (e) {
      return [];
    }
  }

  /// Obtener ejercicio por ID
  static Future<Exercise?> getExerciseById(int id) async {
    try {
      // Buscar en caché primero
      for (var ex in _cachedExercises) {
        if (ex.id == id) return ex;
      }

      final response = await _supabase
          .from('exercises')
          .select()
          .eq('id', id)
          .single() as Map<String, dynamic>;

      return Exercise.fromJson(response);
    } catch (e) {
      return null;
    }
  }

 

  /// Limpiar caché
  static void clearCache() {
    _cachedExercises = [];
    _hasLoadedCache = false;
  }

  /// Obtener caché
  static List<Exercise> getCachedExercises() => _cachedExercises;
}
