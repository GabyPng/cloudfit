import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color de fondo de las pantallas
    scaffoldBackgroundColor: AppColors.background,
    
    // Color principal (el verde neón del diseño)
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neonGreen,
      surface: AppColors.surface,
    ),

    // Configuración de los Textos
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    ),

    // Estilo de las Cards (para los contenedores de métricas)
    cardTheme: const CardThemeData(
      color: AppColors.cardGrey,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );
}