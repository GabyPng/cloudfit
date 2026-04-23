import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class CustomBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomBottomNav({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.cardGrey.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
  _navItem(Icons.home_filled, 0),         // Dashboard    branch 0
  _navItem(Icons.restaurant_menu, 2),    // Nutrición    branch 2
  _navItem(Icons.show_chart, 3),         // Progreso     branch 3
  _navItem(Icons.workspace_premium, 4),  // Logros       branch 4
  _navItem(Icons.groups_outlined, 6),    // Profesionales branch 6
  _navItem(Icons.person_outline, 5),     // Perfil       branch 5
],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final bool isActive = navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      child: Icon(
        icon,
        color: isActive ? AppColors.neonGreen : Colors.grey,
        size: 28,
      ),
    );
  }
}
