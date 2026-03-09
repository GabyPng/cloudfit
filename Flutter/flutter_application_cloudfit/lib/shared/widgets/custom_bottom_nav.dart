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
        color: AppColors.cardGrey.withOpacity(0.95),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, 0),
          _navItem(Icons.fitness_center, 1),
          _navItem(Icons.workspace_premium, 2),
          _navItem(Icons.person_outline, 3),
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