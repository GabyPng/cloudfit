import 'package:flutter/material.dart';
import 'models/nutrition_model.dart';
import '../../../core/constants.dart';

class NutritionScreen extends StatelessWidget {
  static const String name = 'nutrition_screen';

  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            /// TITULO
            const Text(
              "Plan Alimenticio",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              "Objetivo: Definición Muscular",
              style: TextStyle(color: Colors.white38),
            ),

            const SizedBox(height: 30),

            /// MACROS
            _buildMacroSummary(),

            const SizedBox(height: 30),

            /// COMIDAS
            const Text(
              "Comidas de Hoy",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 15),
            _buildMealList(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// MACROS
  /// =======================

  Widget _buildMacroSummary() {
    final macros = [
      MacroModel(
        name: "Carbs",
        amount: "150g",
        percentage: 0.4,
        color: AppColors.neonGreen,
      ),
      MacroModel(
        name: "Proteína",
        amount: "200g",
        percentage: 0.5,
        color: AppColors.electricPurple,
      ),
      MacroModel(
        name: "Grasas",
        amount: "60g",
        percentage: 0.1,
        color: AppColors.coralOrange,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "2,400 kcal",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text("Restantes: 600",
                  style: TextStyle(color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: macros.map((m) => _macroIndicator(m)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _macroIndicator(MacroModel macro) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: macro.percentage,
                strokeWidth: 6,
                backgroundColor: Colors.white10,
                color: macro.color,
              ),
            ),
            Text(
              "${(macro.percentage * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          macro.name,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          macro.amount,
          style: TextStyle(
            color: macro.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// =======================
  /// COMIDAS
  /// =======================

  Widget _buildMealList() {
    final meals = [
      MealModel(
        title: "Desayuno",
        description: "Omelette de claras con espinacas",
        time: "08:00 AM",
        calories: "350 kcal",
        imageUrl:
            "https://images.unsplash.com/photo-1551218808-94e220e084d2",
        protein: 30,
        carbs: 10,
        fats: 5,
      ),
      MealModel(
        title: "Almuerzo",
        description: "Pechuga de pollo con quinoa",
        time: "02:00 PM",
        calories: "650 kcal",
        imageUrl:
            "https://images.unsplash.com/photo-1604908176997-431b3c59e1d1",
        protein: 45,
        carbs: 50,
        fats: 12,
      ),
      MealModel(
        title: "Cena",
        description: "Salmón con espárragos",
        time: "08:00 PM",
        calories: "450 kcal",
        imageUrl:
            "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
        protein: 35,
        carbs: 15,
        fats: 20,
      ),
    ];

    return Column(
      children: meals.map((meal) => _mealCard(meal)).toList(),
    );
  }

  Widget _mealCard(MealModel meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          /// 🔥 IMAGEN
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              meal.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 15),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  meal.description,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 5),

                /// 🔥 MACROS
                Text(
                  "P:${meal.protein} C:${meal.carbs} G:${meal.fats}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          /// DERECHA
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                meal.calories,
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                meal.time,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}