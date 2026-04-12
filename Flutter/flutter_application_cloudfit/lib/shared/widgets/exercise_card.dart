import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../sections/workout/models/exercise_model.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final Function()? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/cliente/exercise-detail'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.cardGrey,
          image: _buildDecorationImage(),
        ),
        child: Stack(
          children: [
            // Fallback cuando no hay imagen
            if (exercise.imageUrl.isEmpty || !_hasValidImage())
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.cardGrey,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricPurple.withValues(alpha: 0.6),
                      AppColors.neonGreen.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 40,
                        color: Colors.white30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sin imagen',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top: Badges de categoría y dificultad
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBadge(
                        exercise.category,
                        AppColors.neonGreen,
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(
                        exercise.difficulty,
                        _getDifficultyColor(exercise.difficulty),
                      ),
                    ],
                  ),

                  // Bottom: Información del ejercicio
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Row con sets, reps y duración
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.repeat,
                            label: '${exercise.sets}x${exercise.reps}',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            icon: Icons.timer_outlined,
                            label: '${exercise.duration}s',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasValidImage() {
    return exercise.imageUrl.isNotEmpty &&
        (exercise.imageUrl.startsWith('assets/') ||
            exercise.imageUrl.startsWith('http'));
  }

  /// Detectar si la imagen es local o remota y cargarla adecuadamente
  DecorationImage? _buildDecorationImage() {
    if (exercise.imageUrl.isEmpty) {
      return null;
    }

    // Si empieza con 'assets/', es local
    if (exercise.imageUrl.startsWith('assets/')) {
      return DecorationImage(
        image: AssetImage(exercise.imageUrl),
        fit: BoxFit.cover,
        alignment: Alignment.center,
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.3),
          BlendMode.darken,
        ),
      );
    }

    // Si empieza con 'http', es remota
    if (exercise.imageUrl.startsWith('http')) {
      return DecorationImage(
        image: NetworkImage(exercise.imageUrl),
        fit: BoxFit.cover,
        alignment: Alignment.center,
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.3),
          BlendMode.darken,
        ),
      );
    }

    return null;
  }

  /// Widget para badges (categoría, dificultad)
  Widget _buildBadge(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Widget para mostrar información pequeña (sets, duración)
  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.neonGreen,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Obtener color según la dificultad
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'facil':
      case 'easy':
        return const Color(0xFF4CAF50); // Verde
      case 'intermedio':
      case 'intermediate':
        return const Color(0xFFFFC107); // Naranja/Amarillo
      case 'difícil':
      case 'dificil':
      case 'hard':
        return const Color(0xFFF44336); // Rojo
      default:
        return AppColors.neonGreen;
    }
  }
}
