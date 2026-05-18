import 'dart:ui';

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

  static const _icons = [
    Icons.home_rounded,
    Icons.people_rounded,
    Icons.restaurant_menu_rounded,
    Icons.person_rounded,
  ];

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
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: const Color(0xFF1C1C1C).withValues(alpha: 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) {
                return i == 3
                    ? _navItemWithBadge(_icons[i], i)
                    : _navItem(_icons[i], i);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isActive = widget.navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.neonGreen.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.neonGreen : Colors.grey.shade600,
          size: 26,
        ),
      ),
    );
  }

  Widget _navItemWithBadge(IconData icon, int index) {
    final isActive = widget.navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.neonGreen.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.neonGreen : Colors.grey.shade600,
              size: 26,
            ),
            if (_pendingCount > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 17, minHeight: 17),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
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
