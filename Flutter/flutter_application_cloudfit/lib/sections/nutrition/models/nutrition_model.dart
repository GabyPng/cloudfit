import 'dart:ui';

class NutritionPlanModel {
  final int id;
  final String title;
  final String? description;
  final String? goal;
  final int? dailyCalories;
  final Map<String, dynamic>? macroTargets;
  final bool isActive;
  final String? startsAt;
  final String? endsAt;
  final List<MealModel> meals;

  NutritionPlanModel({
    required this.id,
    required this.title,
    this.description,
    this.goal,
    this.dailyCalories,
    this.macroTargets,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
    required this.meals,
  });

  factory NutritionPlanModel.fromMap(Map<String, dynamic> map) {
    final rawMeals = map['meals'] as List<dynamic>? ?? [];
    return NutritionPlanModel(
      id: (map['id'] as num).toInt(),
      title: map['title']?.toString() ?? 'Plan Nutricional',
      description: map['description']?.toString(),
      goal: map['goal']?.toString(),
      dailyCalories: (map['daily_calories'] as num?)?.toInt(),
      macroTargets: map['macro_targets'] as Map<String, dynamic>?,
      isActive: map['is_active'] as bool? ?? true,
      startsAt: map['starts_at']?.toString(),
      endsAt: map['ends_at']?.toString(),
      meals: rawMeals
          .cast<Map<String, dynamic>>()
          .map(MealModel.fromMap)
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position)),
    );
  }

  int get totalProtein => meals.fold(0, (s, m) => s + m.protein);
  int get totalCarbs => meals.fold(0, (s, m) => s + m.carbs);
  int get totalFats => meals.fold(0, (s, m) => s + m.fats);
  int get totalCaloriesFromMeals => meals.fold(0, (s, m) => s + m.caloriesInt);

  int get effectiveDailyCalories =>
      dailyCalories ?? totalCaloriesFromMeals;

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
  final int id;
  final String title;
  final String description;
  final String? portion;
  final String? notes;
  final int caloriesInt;
  final int protein;
  final int carbs;
  final int fats;
  final String mealType;
  final int position;

  MealModel({
    required this.id,
    required this.title,
    required this.description,
    this.portion,
    this.notes,
    required this.caloriesInt,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.mealType,
    required this.position,
  });

  String get caloriesLabel => '$caloriesInt kcal';

  factory MealModel.fromMap(Map<String, dynamic> map) {
    final cal = (map['calories'] as num?)?.toInt() ?? 0;
    final mealType = map['meal_type']?.toString() ?? '';
    return MealModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: _mealTypeLabel(mealType) ?? map['name']?.toString() ?? 'Comida',
      description: map['name']?.toString() ?? '',
      portion: map['portion']?.toString(),
      notes: map['notes']?.toString(),
      caloriesInt: cal,
      protein: (map['protein_g'] as num?)?.toInt() ?? 0,
      carbs: (map['carbs_g'] as num?)?.toInt() ?? 0,
      fats: (map['fat_g'] as num?)?.toInt() ?? 0,
      mealType: mealType,
      position: (map['position'] as num?)?.toInt() ?? 0,
    );
  }

  static String? _mealTypeLabel(String? type) {
    switch (type) {
      case 'desayuno':
        return 'Desayuno';
      case 'colacion_1':
        return 'Colación Mañana';
      case 'comida':
        return 'Comida';
      case 'colacion_2':
        return 'Colación Tarde';
      case 'cena':
        return 'Cena';
      // Legacy English types
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
