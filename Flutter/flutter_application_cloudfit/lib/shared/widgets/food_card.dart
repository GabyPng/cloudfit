import 'package:flutter/material.dart';
import 'package:flutter_application_cloudfit/sections/nutrition/models/nutrition_model.dart';
import 'package:flutter_application_cloudfit/core/constants.dart';

class FoodCard extends StatelessWidget {
  final MealModel food;

  const FoodCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              food.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  food.description,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                /// 🔥 MACROS
                Text(
                  "P:${food.protein} C:${food.carbs} G:${food.fats}",
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
                food.calories,
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                food.time,
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