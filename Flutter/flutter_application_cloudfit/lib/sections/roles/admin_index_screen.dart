import 'package:flutter/material.dart';
import '../../core/user_role.dart';
import 'role_index_shell.dart';

class AdminIndexScreen extends StatelessWidget {
  const AdminIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleIndexShell(
      role: UserRole.admin,
      title: 'Panel Administrador',
      subtitle:
          'Gestiona usuarios, roles y configuraciones globales del sistema.',
      accent: Color(0xFFEF4444),
    );
  }
}
