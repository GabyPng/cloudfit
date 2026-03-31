import 'package:flutter/material.dart';
import '../../core/user_role.dart';
import 'role_index_shell.dart';

class CoachIndexScreen extends StatelessWidget {
  const CoachIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleIndexShell(
      role: UserRole.coach,
      title: 'Panel Coach',
      subtitle: 'Da seguimiento a tus clientes y crea planes de entrenamiento.',
      accent: Color(0xFF3B82F6),
    );
  }
}
