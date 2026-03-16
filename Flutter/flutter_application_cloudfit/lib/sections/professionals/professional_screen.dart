import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import './models/professional_model.dart';

class ProfessionalsScreen extends StatelessWidget {
  static const String name = 'professionals_screen';

  const ProfessionalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pros = [
      ProfessionalModel(
        name: "Dayana Perez",
        specialty: "Fitness Coach",
        rating: "4.9",
        isOnline: true,
        imageUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200",
      ),
      ProfessionalModel(
        name: "Jonathan Viera",
        specialty: "Nutriólogo Deportivo",
        rating: "4.8",
        isOnline: true,
        imageProvider: const AssetImage("assets/images/Jona.png"), 
      ),
      ProfessionalModel(
        name: "Sofia Martínez",
        specialty: "Entrenadora Personal",
        rating: "4.7",
        isOnline: false,
        imageUrl: "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?q=80&w=200",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Profesionales", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: pros.length,
        itemBuilder: (context, index) => _professionalCard(pros[index]),
      ),
    );
  }

  Widget _professionalCard(ProfessionalModel pro) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 35,
                
                backgroundImage: pro.imageProvider ?? NetworkImage(pro.imageUrl!),
              ),
              if (pro.isOnline)
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardGrey, width: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pro.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(pro.specialty, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(pro.rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.neonGreen),
          ),
        ],
      ),
    );
  }
}