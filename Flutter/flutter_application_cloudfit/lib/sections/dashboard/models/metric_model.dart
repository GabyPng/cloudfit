import 'package:flutter/material.dart';

class MetricModel {
  final String title;
  final String value;
  final String unit;
  final Gradient? gradient;
  final IconData icon;

  const MetricModel({
    required this.title,
    required this.value,
    required this.unit,
    this.gradient,
    required this.icon,
  });
}