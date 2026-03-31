import 'package:flutter/material.dart';

class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/api';
}

class AppColors {
  // Colores Base
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardGrey = Color(0xFF2C2C2C);

  // Colores de Acento (Basados en tus fotos)
  static const Color neonGreen = Color(0xFFD0FD3E);
  static const Color electricPurple = Color(0xFF6366F1);
  static const Color coralOrange = Color(0xFFFF6B6B);
  
  // Gradientes para los Containers de la Foto 1
  static const LinearGradient greenGradient = LinearGradient(
    colors: [neonGreen, Color(0xFF9DC41A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [electricPurple, Color(0xFF4338CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}