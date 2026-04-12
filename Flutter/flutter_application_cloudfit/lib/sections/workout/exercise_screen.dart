import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/services/exercise_service.dart';
import '../../shared/widgets/exercise_card.dart';
import 'models/exercise_model.dart';

class ExerciseScreen extends StatefulWidget {
  static const String name = 'exercise_screen';

  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late Stream<List<Exercise>> _exercisesStream;

  @override
  void initState() {
    super.initState();
    // Stream de ejercicios en tiempo real desde Supabase
    _exercisesStream = ExerciseService.getExercisesStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: _buildExerciseList(),
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

  /// Construir lista de ejercicios desde Supabase
  Widget _buildExerciseList() {
    return StreamBuilder<List<Exercise>>(
      stream: _exercisesStream,
      builder: (context, snapshot) {
        // Estado: cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.neonGreen,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cargando ejercicios...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }

        // Estado: error
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error cargando ejercicios',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
            ),
          );
        }

        final exercises = snapshot.data ?? [];

        // Estado: sin datos
        if (exercises.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 64,
                    color: Colors.white30,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ejercicios disponibles',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega ejercicios en tu tabla de Supabase',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Estado: datos cargados
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ExerciseCard(
                exercise: exercises[index],
              );
            },
            childCount: exercises.length,
          ),
        );
      },
    );
  }
}
