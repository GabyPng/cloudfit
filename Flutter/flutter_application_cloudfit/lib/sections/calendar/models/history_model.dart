import 'package:flutter/material.dart';

class HistoryModel {
  final DateTime date;
  final String workoutTitle;
  final String duration;
  final int calories;
  final IconData icon;

  HistoryModel({
    required this.date,
    required this.workoutTitle,
    required this.duration,
    required this.calories,
    required this.icon,
  });
}