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

  String _dateLabel() {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    final now = DateTime.now();
    return '${now.day} de ${months[now.month - 1]}. de ${now.year}';
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
    final user = AuthService.currentUser;
    final name = user?.userMetadata?['full_name']?.toString() ??
        user?.email?.split('@').first ??
        'Nutriólogo';
    final greeting = _greeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $name',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _dateLabel(),
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => _load(forceRefresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: _confirmLogout,
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
          // Stats
          Row(
            children: [
              _statCard('Pacientes', _stats['total_pacientes'],
                  Icons.people_outlined, AppColors.neonGreen),
              const SizedBox(width: 10),
              _statCard('Planes activos', _stats['planes_activos'],
                  Icons.restaurant_menu_outlined, AppColors.electricPurple),
              const SizedBox(width: 10),
              _statCard('Alertas', _stats['alertas_nutricionales'],
                  Icons.warning_amber_rounded, AppColors.coralOrange),
            ],
          ),

          const SizedBox(height: 24),

          // Recent clients
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Clientes recientes',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15),
              ),
              GestureDetector(
                onTap: () => context.go('/nutriologo/pacientes'),
                child: const Text('Ver todos',
                    style:
                        TextStyle(color: AppColors.neonGreen, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_recentClients.isEmpty)
            _emptyState('No hay clientes asignados')
          else
            ..._recentClients.map((c) => _clientTile(c)),

          const SizedBox(height: 24),

          // Recent plans
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Planes recientes',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15),
              ),
              GestureDetector(
                onTap: () => context.go('/nutriologo/planes'),
                child: const Text('Ver todos',
                    style:
                        TextStyle(color: AppColors.neonGreen, fontSize: 12)),
              ),
            ],
          ),
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

  Widget _statCard(
      String label, dynamic value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              '${value ?? 0}',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clientTile(Map<String, dynamic> client) {
    final initial =
        (client['name']?.toString().isNotEmpty ?? false)
            ? client['name'].toString().substring(0, 1).toUpperCase()
            : '?';
    return GestureDetector(
      onTap: () => context.go('/nutriologo/pacientes'),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                AppColors.neonGreen.withValues(alpha: 0.18),
            child: Text(
              initial,
              style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client['name']?.toString() ?? 'Sin nombre',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                Text(
                  client['email']?.toString() ?? '',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: Colors.white24, size: 13),
        ],
      ),
    ),
    );
  }

  Widget _planTile(Map<String, dynamic> plan) {
    final isActive = _isPlanActive(plan);
    return GestureDetector(
      onTap: () => context.go('/nutriologo/planes'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.neonGreen : Colors.white12,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.restaurant_menu_outlined,
                color: Colors.white38, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['title']?.toString() ?? 'Sin título',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  Text(
                    '${plan['meals_count'] ?? 0} comidas · ${plan['assignments_count'] ?? 0} asignaciones',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.neonGreen.withValues(alpha: 0.15)
                    : Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: isActive ? AppColors.neonGreen : Colors.white54,
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
