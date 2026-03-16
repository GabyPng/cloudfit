import 'dart:ui';

class MacroModel {
  final String name;
  final String amount;
  final double percentage;
  final Color color;

  MacroModel({required this.name, required this.amount, required this.percentage, required this.color});
}

class MealModel {
  final String title;
  final String description;
  final String time;
  final String calories;

  MealModel({required this.title, required this.description, required this.time, required this.calories});
}