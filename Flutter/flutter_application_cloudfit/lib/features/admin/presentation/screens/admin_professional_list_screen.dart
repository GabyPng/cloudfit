import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../data/admin_api.dart';
import 'admin_professional_detail_screen.dart';

class AdminProfessionalListScreen extends StatefulWidget {
  const AdminProfessionalListScreen({super.key});

  @override
  State<AdminProfessionalListScreen> createState() =>
      _AdminProfessionalListScreenState();
}

class _AdminProfessionalListScreenState
    extends State<AdminProfessionalListScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String _statusFilter = 'pending';

  static const _statusLabels = {
    'pending': 'Pendientes',
    'verified': 'Verificados',
    'rejected': 'Rechazados',
    'all': 'Todos',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await AdminApi.getProfessionals(
          status: _statusFilter == 'all' ? null : _statusFilter);
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ AdminProfessionalList error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.neonGreen))
              : _items.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: AppColors.neonGreen,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _buildCard(_items[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _statusLabels.entries.map((e) {
            final sel = _statusFilter == e.key;
            final color = _statusColor(e.key);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _statusFilter = e.key);
                  _load();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? color.withValues(alpha: 0.18) : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? color : Colors.white12),
                  ),
                  child: Text(e.value,
                      style: TextStyle(
                        color: sel ? color : Colors.white54,
                        fontSize: 12,
                        fontWeight:
                            sel ? FontWeight.bold : FontWeight.normal,
                      )),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'verified' => AppColors.neonGreen,
      'rejected' => AppColors.coralOrange,
      _ => const Color(0xFFFFBB00),
    };
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final isCoach = item['type'] == 'coach';
    final isVerified = item['is_verified'] == true;
    final isRejected = item['rejection_reason'] != null;
    final rc = isCoach ? AppColors.neonGreen : AppColors.electricPurple;
    final name = item['name']?.toString() ?? '—';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    Color statusColor;
    String statusLabel;
    if (isVerified) {
      statusColor = AppColors.neonGreen;
      statusLabel = 'Verificado';
    } else if (isRejected) {
      statusColor = AppColors.coralOrange;
      statusLabel = 'Rechazado';
    } else {
      statusColor = const Color(0xFFFFBB00);
      statusLabel = 'Pendiente';
    }

    return GestureDetector(
      onTap: () => _goToDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rc.withValues(alpha: 0.18)),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: rc.withValues(alpha: 0.15),
            child: Text(initial,
                style: TextStyle(
                    color: rc,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(item['email']?.toString() ?? '',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: rc.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        isCoach ? 'Coach' : 'Nutriólogo',
                        style: TextStyle(
                            color: rc,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ]),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: AppColors.surface, shape: BoxShape.circle),
          child: const Icon(Icons.verified_user_outlined,
              color: Colors.white24, size: 44),
        ),
        const SizedBox(height: 16),
        Text(
          _statusFilter == 'pending'
              ? 'Sin profesionistas pendientes'
              : 'Sin resultados',
          style: const TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ]),
    );
  }

  void _goToDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProfessionalDetailScreen(professional: item),
      ),
    ).then((_) => _load());
  }
}
