import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';
import '../../../../core/auth_service.dart';
import 'admin_professional_list_screen.dart';
import 'admin_tickets_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_users_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _tabIndex = 0;

  static const _tabs = [
    'Validación',
    'Soporte',
    'Analíticas',
    'Usuarios',
  ];

  static const _icons = [
    Icons.verified_user_outlined,
    Icons.support_agent_outlined,
    Icons.bar_chart_rounded,
    Icons.people_outline_rounded,
  ];

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 10),
            Text('Cerrar Sesión',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión del panel de administración?',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar Sesión',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService.logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 4),
            _buildTabBar(),
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userName = Supabase.instance.client.auth.currentUser
            ?.userMetadata?['nombre']
            ?.toString() ??
        'Admin';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          // Admin icon badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.2),
                  const Color(0xFFEF4444).withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.admin_panel_settings,
                color: Color(0xFFEF4444), size: 22),
          ),
          const SizedBox(width: 12),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Panel Admin',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                Text('CloudFit · $userName',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Logout button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _confirmLogout,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color:
                          const Color(0xFFEF4444).withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Color(0xFFEF4444), size: 16),
                    SizedBox(width: 6),
                    Text('Salir',
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = i == _tabIndex;
          return GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel
                    ? const Color(0xFFEF4444).withValues(alpha: 0.18)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: sel
                      ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                      : Colors.white12,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_icons[i],
                    size: 14,
                    color:
                        sel ? const Color(0xFFEF4444) : Colors.white38),
                const SizedBox(width: 6),
                Text(_tabs[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          sel ? FontWeight.bold : FontWeight.normal,
                      color: sel
                          ? const Color(0xFFEF4444)
                          : Colors.white38,
                    )),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_tabIndex) {
      case 0:
        return const AdminProfessionalListScreen();
      case 1:
        return const AdminTicketsScreen();
      case 2:
        return const AdminAnalyticsScreen();
      case 3:
        return const AdminUsersScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
