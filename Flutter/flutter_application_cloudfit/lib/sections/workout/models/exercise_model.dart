class RoutineExercise {
  final int id;
  final int routineId;
  final String exerciseName;
  final int sets;
  final String reps;
  final String? restTime;
  final String? notes;
  final int order;

  RoutineExercise({
    required this.id,
    required this.routineId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.restTime,
    this.notes,
    required this.order,
  });

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      id: map['id'] as int,
      routineId: map['routine_id'] as int,
      exerciseName: map['exercise_name'] ?? '',
      sets: map['sets'] as int? ?? 0,
      reps: map['reps']?.toString() ?? '0',
      restTime: map['rest_time'],
      notes: map['notes'],
      order: map['order'] as int? ?? 0,
    );
  }
}