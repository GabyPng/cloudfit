import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/services/exercise_service.dart';
import '../../shared/widgets/exercise_card.dart';
import 'models/exercise_model.dart';

class ExerciseScreen extends StatelessWidget {
  static const String name = 'exercise_screen';

  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: StreamBuilder<List<RoutineExercise>>(
              stream: ExerciseService.getExercisesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.neonGreen),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Error cargando ejercicios',
                            style: TextStyle(color: Colors.red[300], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: const TextStyle(color: Colors.white30),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final exercises = snapshot.data ?? [];

                if (exercises.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center_outlined, size: 64, color: Colors.white30),
                          SizedBox(height: 16),
                          Text(
                            'No hay ejercicios disponibles',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ExerciseCard(exercise: exercises[index]),
                    childCount: exercises.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return const SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      title: Text(
        "Catálogo de Ejercicios",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      centerTitle: false,
    );
  }
}