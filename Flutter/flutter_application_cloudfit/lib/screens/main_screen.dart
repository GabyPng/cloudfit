import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/custom_bottom_nav.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola Marié', style: TextStyle(color: lightPurple, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Es hora de ejercitar!', style: TextStyle(color: textGray, fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.search, color: lightPurple, size: 20),
                      const SizedBox(width: 15),
                      const Icon(Icons.notifications, color: lightPurple, size: 20),
                      const SizedBox(width: 15),
                      const CircleAvatar(radius: 12, backgroundColor: lightPurple, child: Icon(Icons.person, size: 16, color: bgColor)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),

              // Categorías
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryIcon(Icons.fitness_center, 'Ejercicio', neonGreen),
                  _buildCategoryIcon(Icons.assignment, 'Progreso', textGray),
                  _buildCategoryIcon(Icons.food_bank, 'Nutrición', textGray),
                  _buildCategoryIcon(Icons.people, 'Coach', textGray),
                ],
              ),
              const SizedBox(height: 30),

              // Calendario
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.chevron_left, color: textGray),
                  _buildDateItem('LUN', '17', false),
                  _buildDateItem('MAR', '18', false),
                  _buildDateItem('MIE', '19', false),
                  _buildDateItem('JUE', '20', true), 
                  _buildDateItem('VIE', '21', false),
                  _buildDateItem('SÁB', '22', false), 
                  const Icon(Icons.chevron_right, color: textGray),
                ],
              ),
              const SizedBox(height: 30),

              // Tarjeta de Rutina
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RUTINA DE HOY', style: TextStyle(color: neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text('PECHO Y TRÍCEPS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('EJERCICIOS', '8'),
                        _buildStat('SETS TOTALES', '24'),
                        _buildStat('TIEMPO ESTIMADO \n EN MINUTOS', '55'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/exercise'),
                        child: const Text('INICIAR ENTRENAMIENTO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Logros
              const Text('LOGROS RECIENTES', style: TextStyle(color: neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAchievement(Icons.local_fire_department, '7 Días\nConsecutivos'),
                  _buildAchievement(Icons.access_time, '30 Rutinas\nCompletadas'),
                  _buildAchievement(Icons.emoji_events, 'Meta Mensual\nAlcanzada'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildDateItem(String day, String date, bool isSelected) {
    return Column(
      children: [
        Text(day, style: TextStyle(color: isSelected ? neonGreen : textGray, fontSize: 10)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? neonGreen : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(date, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        )
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: textGray, fontSize: 10)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAchievement(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: cardColor, shape: BoxShape.circle),
          child: Icon(icon, color: neonGreen, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: textGray, fontSize: 10)),
      ],
    );
  }
}