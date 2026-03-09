import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'models/workout_model.dart';

class ExerciseScreen extends StatelessWidget {
  static const String name = 'exercise_screen';

  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de ejemplo basada en tu diseño
    final workouts = [
      WorkoutModel(
        title: "Cuerpo Superior",
        category: "Fuerza",
        duration: "45 min",
        difficulty: "Intermedio",
        imageUrl: "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=500",
      ),
      WorkoutModel(
        title: "Yoga Flow",
        category: "Flexibilidad",
        duration: "30 min",
        difficulty: "Principiante",
        imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=500",
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _workoutCard(workouts[index]),
                childCount: workouts.length,
              ),
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
      title: Text("Entrenamientos", 
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      centerTitle: false,
    );
  }

  Widget _workoutCard(WorkoutModel workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: NetworkImage(workout.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.neonGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(workout.category, 
                style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Text(workout.title, 
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 5),
                Text(workout.duration, style: const TextStyle(color: Colors.white70)),
                const SizedBox(width: 15),
                const Icon(Icons.bolt, color: AppColors.neonGreen, size: 16),
                const SizedBox(width: 5),
                Text(workout.difficulty, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}