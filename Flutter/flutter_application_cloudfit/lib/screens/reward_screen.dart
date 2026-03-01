import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/custom_bottom_nav.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            // Botón atrás
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.chevron_left, color: neonGreen, size: 30),
                ),
              ),
            ),
            
            // Trofeo e Ilustración
            const Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 120),
                  ],
                ),
              ),
            ),

            // Tarjeta de Felicitaciones
            Container(
              width: double.infinity,
              color: neonGreen,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: [
                  const Text('Felicitaciones!', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatPill(icon: Icons.access_time, label: '5 Minutos'),
                        _StatPill(icon: Icons.local_fire_department, label: '300 Calories'),
                        _StatPill(icon: Icons.bolt, label: 'Moderado'),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Botón siguiente
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false),
                  child: const Text('Ir al siguiente ejercicio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Icon(icon, color: Colors.black, size: 14),
      ],
    );
  }
}