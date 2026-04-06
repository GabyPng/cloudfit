import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth_service.dart';
import '../../core/user_role.dart';

class RoleIndexShell extends StatelessWidget {
  final UserRole role;
  final String title;
  final String subtitle;
  final Color accent;

  const RoleIndexShell({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: Text(
          title,
          style: TextStyle(color: accent, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ),
      floatingActionButton: role == UserRole.cliente
          ? null
          : FloatingActionButton.extended(
              backgroundColor: accent,
              onPressed: () => context.go(roleHomeRoute(role)),
              label: const Text('Inicio'),
              icon: const Icon(Icons.home_rounded),
            ),
    );
  }
}
