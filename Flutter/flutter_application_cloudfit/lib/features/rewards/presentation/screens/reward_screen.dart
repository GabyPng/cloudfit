import 'package:flutter/material.dart';
import 'package:flutter_application_cloudfit/features/rewards/data/models/achievement.dart';
import '../../../../core/constants.dart';


class RewardScreen extends StatelessWidget {
  static const String name = 'reward_screen';

  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      AchievementModel(
        title: "Primer Paso",
        description: "Completa tu primer entrenamiento",
        icon: Icons.emoji_events,
        isUnlocked: true,
        progress: 1.0,
      ),
      AchievementModel(
        title: "Racha de Fuego",
        description: "Entrena 7 días seguidos",
        icon: Icons.local_fire_department,
        isUnlocked: false,
        progress: 0.5,
      ),
      AchievementModel(
        title: "Levantador Pro",
        description: "Levanta un total de 1000kg",
        icon: Icons.fitness_center,
        isUnlocked: false,
        progress: 0.2,
      ),
      AchievementModel(
        title: "Madrugador",
        description: "Entrena antes de las 7:00 AM",
        icon: Icons.wb_sunny,
        isUnlocked: true,
        progress: 1.0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Mis Logros", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildLevelProgress(),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) => _achievementCard(achievements[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Nivel 5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              Text("1,250 XP", style: TextStyle(color: Colors.white70)),
            ],
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.white24,
            color: AppColors.neonGreen,
            minHeight: 8,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ],
      ),
    );
  }

  Widget _achievementCard(AchievementModel achievement) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(20),
        border: achievement.isUnlocked 
            ? Border.all(color: AppColors.neonGreen.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            size: 50,
            color: achievement.isUnlocked ? AppColors.neonGreen : Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          if (!achievement.isUnlocked) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: achievement.progress,
                backgroundColor: Colors.black26,
                color: AppColors.electricPurple,
                minHeight: 4,
              ),
            ),
          ]
        ],
      ),
    );
  }
}