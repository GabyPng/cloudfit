import 'dart:ui';

class NutritionPlanModel {
  final int id;
  final String title;
  final String? goal;
  final int? dailyCalories;
  final List<MealModel> meals;

  NutritionPlanModel({
    required this.id,
    required this.title,
    this.goal,
    this.dailyCalories,
    required this.meals,
  });

  factory NutritionPlanModel.fromMap(Map<String, dynamic> map) {
    final rawMeals = map['meals'] as List<dynamic>? ?? [];
    return NutritionPlanModel(
      id: (map['id'] as num).toInt(),
      title: map['title']?.toString() ?? 'Plan Nutricional',
      goal: map['goal']?.toString(),
      dailyCalories: (map['daily_calories'] as num?)?.toInt(),
      meals: rawMeals
          .cast<Map<String, dynamic>>()
          .map(MealModel.fromMap)
          .toList(),
    );
  }

  // Macros totales calculados desde las comidas
  int get totalProtein => meals.fold(0, (s, m) => s + m.protein);
  int get totalCarbs => meals.fold(0, (s, m) => s + m.carbs);
  int get totalFats => meals.fold(0, (s, m) => s + m.fats);
  int get totalCaloriesFromMeals =>
      totalProtein * 4 + totalCarbs * 4 + totalFats * 9;

  double get proteinPct {
    final t = totalCaloriesFromMeals;
    return t > 0 ? (totalProtein * 4) / t : 0.0;
  }

  double get carbsPct {
    final t = totalCaloriesFromMeals;
    return t > 0 ? (totalCarbs * 4) / t : 0.0;
  }

  double get fatsPct {
    final t = totalCaloriesFromMeals;
    return t > 0 ? (totalFats * 9) / t : 0.0;
  }
}

class MacroModel {
  final String name;
  final String amount;
  final double percentage;
  final Color color;

  MacroModel({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class MealModel {
  final String title;
  final String description;
  final String time;
  final String calories;
  final String? imageUrl;
  final int protein;
  final int carbs;
  final int fats;

  MealModel({
    required this.title,
    required this.description,
    required this.time,
    required this.calories,
    this.imageUrl,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory MealModel.fromMap(Map<String, dynamic> map) {
    final cal = (map['calories'] as num?)?.toInt() ?? 0;
    final rawTime = map['time']?.toString() ?? '';
    return MealModel(
      title: _mealTypeLabel(map['meal_type']?.toString()) ??
          map['name']?.toString() ??
          'Comida',
      description: map['description']?.toString() ??
          map['name']?.toString() ??
          '',
      time: rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime,
      calories: '$cal kcal',
      imageUrl: map['image_url']?.toString(),
      protein: (map['protein'] as num?)?.toInt() ?? 0,
      carbs: (map['carbs'] as num?)?.toInt() ?? 0,
      fats: (map['fats'] as num?)?.toInt() ?? 0,
    );
  }

  static String? _mealTypeLabel(String? type) {
    switch (type) {
      case 'breakfast':
        return 'Desayuno';
      case 'lunch':
        return 'Almuerzo';
      case 'dinner':
        return 'Cena';
      case 'snack':
        return 'Snack';
      case 'pre_workout':
        return 'Pre-entreno';
      case 'post_workout':
        return 'Post-entreno';
      default:
        return null;
    }
  }
}
