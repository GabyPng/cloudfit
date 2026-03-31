import 'package:flutter/material.dart';
import '../../core/user_role.dart';
import 'role_index_shell.dart';

class NutriologoIndexScreen extends StatelessWidget {
  const NutriologoIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleIndexShell(
      role: UserRole.nutriologo,
      title: 'Panel Nutriólogo',
      subtitle: 'Administra planes nutricionales y progreso de tus pacientes.',
      accent: Color(0xFF10B981),
    );
  }
}
