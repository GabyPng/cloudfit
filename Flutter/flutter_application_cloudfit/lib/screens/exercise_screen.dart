import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/custom_bottom_nav.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

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
                  const Text('PECHO Y TRÍCEPS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

              // Vide
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                child: const Center(
                  child: Icon(Icons.play_arrow, color: neonGreen, size: 80),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Presiona para ver la técnica', style: TextStyle(color: textGray, fontSize: 12)),
              const SizedBox(height: 30),

              // Título del ejercicio actual
              const Center(
                child: Text('PRESS BANCA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 20),

              const Text('Ejercicio 1 de 8', style: TextStyle(color: textGray, fontSize: 12)),
              const SizedBox(height: 10),

              // 4 Sets 
              _buildSetInput(1),
              const SizedBox(height: 10),
              _buildSetInput(2),
              const SizedBox(height: 10),
              _buildSetInput(3),
              const SizedBox(height: 10),
              _buildSetInput(4),
              
              const SizedBox(height: 30),

              // Boton de Terminado
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/reward'),
                  child: const Text('TERMINADO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetInput(int setNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Text('SET $setNumber', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          Container(
            width: 90, 
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: const TextField(
              keyboardType: TextInputType.number, 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Peso Kg',
                hintStyle: TextStyle(color: textGray, fontSize: 14, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        ],
      ),
    );
  }
}