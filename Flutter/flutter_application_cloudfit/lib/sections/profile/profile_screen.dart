import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ProfileScreen extends StatelessWidget {
  static const String name = 'profile_screen';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildStatsRow(),
            const SizedBox(height: 40),
            _buildProfileMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=300'),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.neonGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 18, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text("Daniel Ruiz", 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const Text("Nivel 5 • Miembro desde 2024", 
          style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statItem("Entrenamientos", "42"),
        _statItem("Seguidores", "128"),
        _statItem("Puntos", "1,250"),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.neonGreen)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _menuTile(Icons.person_outline, "Editar Perfil"),
          _menuTile(Icons.notifications_none, "Notificaciones"),
          _menuTile(Icons.security, "Privacidad y Seguridad"),
          _menuTile(Icons.help_outline, "Ayuda y Soporte"),
          const Divider(color: Colors.white10, indent: 20, endIndent: 20),
          _menuTile(Icons.logout, "Cerrar Sesión", isLogout: true),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : Colors.white70),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.redAccent : Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: () {},
    );
  }
}