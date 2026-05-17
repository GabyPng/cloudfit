import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth_service.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../data/nutriologo_api.dart';

class NutriologoHomeScreen extends StatefulWidget {
  const NutriologoHomeScreen({super.key});

  @override
  State<NutriologoHomeScreen> createState() => _NutriologoHomeScreenState();
}

class _NutriologoHomeScreenState extends State<NutriologoHomeScreen> {
  bool _isLoading = true;
  String _userName = '';
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentClients = [];
  List<Map<String, dynamic>> _recentPlans = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        NutriologoApi.getDashboard(force: forceRefresh),
        NutriologoApi.getClientsPage(perPage: 4),
        NutriologoApi.getPlansPage(perPage: 4),
      ]);
      if (!mounted) return;
      setState(() {
        _userName = results[0]['name']?.toString() ?? '';
        _stats = (results[0]['stats'] as Map<String, dynamic>?) ?? {};
        _recentClients = ((results[1]['data'] as List<dynamic>?) ?? [])
            .cast<Map<String, dynamic>>();
        _recentPlans = ((results[2]['data'] as List<dynamic>?) ?? [])
            .cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cerrar sesión',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text('¿Seguro que deseas salir?',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir',
                style: TextStyle(color: AppColors.coralOrange)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final router = GoRouter.of(context);
      await AuthService.logout();
      router.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _userName.isNotEmpty ? _userName : 'Nutriólogo';
    final greeting = _greeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting 👋',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white60, size: 20),
              onPressed: () => _load(forceRefresh: true),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white60, size: 20),
              onPressed: _confirmLogout,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(forceRefresh: true),
        color: AppColors.neonGreen,
        child: _isLoading ? _buildSkeleton() : _buildContent(),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 95, width: double.infinity)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 95, width: double.infinity)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 95, width: double.infinity)),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 150),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 70, width: double.infinity)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 70, width: double.infinity)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 70, width: double.infinity)),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 150),
          const SizedBox(height: 10),
          const SkeletonBox(height: 68, width: double.infinity),
          const SizedBox(height: 8),
          const SkeletonBox(height: 68, width: double.infinity),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 150),
          const SizedBox(height: 10),
          const SkeletonBox(height: 68, width: double.infinity),
          const SizedBox(height: 8),
          const SkeletonBox(height: 68, width: double.infinity),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _statCard('Pacientes', _stats['total_pacientes'],
                  Icons.people_rounded, AppColors.neonGreen),
              const SizedBox(width: 10),
              _statCard('Planes', _stats['planes_activos'],
                  Icons.restaurant_menu_rounded, AppColors.electricPurple),
              const SizedBox(width: 10),
              _statCard('Alertas', _stats['alertas_nutricionales'],
                  Icons.warning_amber_rounded, AppColors.coralOrange),
            ],
          ),

          const SizedBox(height: 28),

          // Recent clients
          _sectionHeader('Clientes recientes', 'Ver todos',
              () => context.go('/nutriologo/pacientes')),
          const SizedBox(height: 10),
          if (_recentClients.isEmpty)
            _emptyState('No hay clientes asignados')
          else
            ..._recentClients.map((c) => _clientTile(c)),

          const SizedBox(height: 28),

          // Recent plans
          _sectionHeader('Planes recientes', 'Ver todos',
              () => context.go('/nutriologo/planes')),
          const SizedBox(height: 10),
          if (_recentPlans.isEmpty)
            _emptyState('No hay planes creados')
          else
            ..._recentPlans.map((p) => _planTile(p)),

          const SizedBox(height: 110),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onAction) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.neonGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
              letterSpacing: -0.2,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Ver todos',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
      String label, dynamic value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '${value ?? 0}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clientTile(Map<String, dynamic> client) {
    final name = client['name']?.toString() ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final isAlert = client['estado'] == 'alerta';
    return GestureDetector(
      onTap: () => context.go('/nutriologo/pacientes'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isAlert
                      ? AppColors.coralOrange.withValues(alpha: 0.18)
                      : AppColors.neonGreen.withValues(alpha: 0.15),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: isAlert
                          ? AppColors.coralOrange
                          : AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isAlert)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.coralOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Sin nombre',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    client['estado_label']?.toString() ??
                        client['email']?.toString() ?? '',
                    style: TextStyle(
                      color: isAlert
                          ? AppColors.coralOrange.withValues(alpha: 0.8)
                          : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _planTile(Map<String, dynamic> plan) {
    final isActive = _isPlanActive(plan);
    final mealCount = plan['meals_count'] ?? 0;
    final assignCount = plan['assignments_count'] ?? 0;
    return GestureDetector(
      onTap: () => context.go('/nutriologo/planes'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              margin: const EdgeInsets.only(left: 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.neonGreen : Colors.white12,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.neonGreen.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: isActive ? AppColors.neonGreen : Colors.white24,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['title']?.toString() ?? 'Sin título',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$mealCount comidas · $assignCount asig.',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.neonGreen.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: isActive ? AppColors.neonGreen : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(msg,
          style:
              const TextStyle(color: Colors.white38, fontSize: 13)),
    );
  }

  bool _isPlanActive(Map<String, dynamic> plan) {
    final raw = plan['is_active'];
    if (raw is bool) return raw;
    if (raw is num) return raw == 1;
    if (raw is String) return raw == '1' || raw.toLowerCase() == 'true';
    return true;
  }
}
