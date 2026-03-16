import 'package:flutter/material.dart';
import '../../../../core/constants.dart';

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
            _buildAvatarHeader(),
            const SizedBox(height: 30),
            _buildStatsGrid(),
            const SizedBox(height: 30),
            _buildSectionTitle("CUENTA"),
            _buildMenuCard([
              _menuItem(Icons.person_outline, "Información Personal", null),
              _menuItem(Icons.workspace_premium, "Mi Suscripción", "Premium"),
              _menuItem(Icons.settings_outlined, "Preferencias Técnicas", null),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle("METAS FÍSICAS"),
            _buildMenuCard([
              _menuItem(Icons.fitness_center, "Récords Personales", null),
              _menuItem(Icons.monitor_weight_outlined, "Ajuste de Peso Meta", "70 kg"),
            ]),
            const SizedBox(height: 30),
            _buildLogoutButton(),
            const SizedBox(height: 120), // Espacio para el BottomNav
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundColor: AppColors.electricPurple,
              child: CircleAvatar(
                radius: 52,
                backgroundImage: AssetImage('assets/images/Efra.jpg'),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text("Daniel Ruiz", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("Rookie • Nivel 5", style: TextStyle(color: Colors.white38, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statBox("PUNTOS", "1,250", AppColors.neonGreen),
          const SizedBox(width: 15),
          _statBox("RACHA", "4 Días", AppColors.electricPurple),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(children: items),
    );
  }

  Widget _menuItem(IconData icon, String title, String? trailingText) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) 
            Text(trailingText, style: const TextStyle(color: AppColors.neonGreen, fontSize: 12)),
          const Icon(Icons.chevron_right, color: Colors.white12),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: () {},
      child: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
    );
  }
}