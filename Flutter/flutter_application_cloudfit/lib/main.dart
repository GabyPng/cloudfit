import 'package:flutter/material.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cloudfit',
      debugShowCheckedModeBanner: false,
      
      // Configuración de navegación con GoRouter
      routerConfig: appRouter,
      
      // Aplicación del tema oscuro y neón generado
      theme: AppTheme().getTheme(),
    );
  }
}