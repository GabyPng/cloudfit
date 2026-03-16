import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  static const String name = 'workout_summary';

  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildSuccessHeader(),
              const SizedBox(height: 40),
              _buildMainStats(),
              const SizedBox(height: 30),
              _buildPerformanceChart(),
              const Spacer(),
              _buildDoneButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 80),
        const SizedBox(height: 20),
        const Text("¡ENTRENAMIENTO COMPLETO!", 
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
        Text("Has superado tus límites de hoy", style: TextStyle(color: Colors.white.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildMainStats() {
    return Row(
      children: [
        _statCard("TIEMPO", "45:12", Icons.timer_outlined, AppColors.electricPurple),
        const SizedBox(width: 15),
        _statCard("CALORÍAS", "340", Icons.local_fire_department, AppColors.neonGreen),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("RENDIMIENTO POR SET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 30),
          // Simulación de gráfico de barras minimalista
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(8, (index) {
              double height = [40, 60, 45, 80, 55, 90, 70, 85][index].toDouble();
              return Container(
                width: 15,
                height: height,
                decoration: BoxDecoration(
                  gradient: index % 2 == 0 ? AppColors.greenGradient : AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => context.go('/'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text("VOLVER AL INICIO", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}