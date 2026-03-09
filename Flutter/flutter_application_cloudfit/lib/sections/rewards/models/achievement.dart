import 'package:flutter/material.dart';

class AchievementModel {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final double progress; // 0.0 a 1.0

  AchievementModel({
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.progress = 0.0,
  });
}