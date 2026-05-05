import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants.dart';
import '../../data/nutriologo_api.dart';

class NutriologoBottomNav extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const NutriologoBottomNav({super.key, required this.navigationShell});

  @override
  State<NutriologoBottomNav> createState() => _NutriologoBottomNavState();
}

class _NutriologoBottomNavState extends State<NutriologoBottomNav> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPending();
  }

  Future<void> _fetchPending() async {
    try {
      final list = await NutriologoApi.getSolicitudes(status: 'pending');
      if (mounted) setState(() => _pendingCount = list.length);
    } catch (_) {}
  }

  void _onTap(int index) {
    if (index == 3) _fetchPending();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
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
          _navItem(Icons.home_filled, 0),
          _navItem(Icons.people_outlined, 1),
          _navItem(Icons.restaurant_menu_outlined, 2),
          _navItemWithBadge(Icons.person_outline, 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isActive = widget.navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon,
            color: isActive ? AppColors.neonGreen : Colors.grey, size: 28),
      ),
    );
  }

  Widget _navItemWithBadge(IconData icon, int index) {
    final isActive = widget.navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon,
                color: isActive ? AppColors.neonGreen : Colors.grey, size: 28),
            if (_pendingCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.coralOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _pendingCount > 9 ? '9+' : '$_pendingCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
