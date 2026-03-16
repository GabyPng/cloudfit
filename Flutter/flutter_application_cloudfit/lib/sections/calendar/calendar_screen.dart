import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import './models/history_model.dart';

class CalendarScreen extends StatelessWidget {
  static const String name = 'calendar_screen';

  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Mi Actividad", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 20),
          _buildCalendarGrid(),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                color: AppColors.cardGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Historial de Sesiones", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Expanded(child: _buildHistoryList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Marzo 2026", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Simulación de una semana resaltada
    final days = ["15", "16", "17", "18", "19", "20", "21"];
    final labels = ["D", "L", "M", "M", "J", "V", "S"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        bool isToday = index == 1; // Lunes 16 de Marzo
        return Column(
          children: [
            Text(labels[index], style: const TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isToday ? AppColors.neonGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: !isToday ? Border.all(color: Colors.white10) : null,
              ),
              child: Text(
                days[index],
                style: TextStyle(
                  color: isToday ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHistoryList() {
    final history = [
      HistoryModel(
        date: DateTime.now(),
        workoutTitle: "Pecho y Tríceps",
        duration: "45 min",
        calories: 340,
        icon: Icons.fitness_center,
      ),
      HistoryModel(
        date: DateTime.now(),
        workoutTitle: "Cardio Hiit",
        duration: "20 min",
        calories: 210,
        icon: Icons.directions_run,
      ),
    ];

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.electricPurple.withOpacity(0.2),
                child: Icon(item.icon, color: AppColors.electricPurple, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.workoutTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${item.duration} • ${item.calories} kcal", 
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        );
      },
    );
  }
}