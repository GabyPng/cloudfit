import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../sections/workout/models/exercise_model.dart';

class ExerciseCard extends StatelessWidget {
  final RoutineExercise exercise;
  final VoidCallback? onTap;

  const ExerciseCard({super.key, required this.exercise, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: nombre + badge de rutina
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildBadge('Rutina ${exercise.routineId}'),
              ],
            ),
            const SizedBox(height: 14),

            // Chips de stats
            Row(
              children: [
                _buildChip(Icons.repeat, '${exercise.sets} series'),
                const SizedBox(width: 10),
                _buildChip(Icons.fitness_center, '${exercise.reps} reps'),
                if (exercise.restTime != null) ...[
                  const SizedBox(width: 10),
                  _buildChip(Icons.timer_outlined, exercise.restTime!),
                ],
              ],
            ),

            // Notas (solo si existen)
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      size: 14, color: AppColors.neonGreen),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      exercise.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.neonGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.neonGreen),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }
}