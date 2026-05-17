import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../data/nutriologo_api.dart';

class NutriologoPacientesScreen extends StatefulWidget {
  const NutriologoPacientesScreen({super.key});

  @override
  State<NutriologoPacientesScreen> createState() =>
      _NutriologoPacientesScreenState();
}

class _NutriologoPacientesScreenState
    extends State<NutriologoPacientesScreen> {
  static const int _pageSize = 10;

  bool _isLoading = true;
  bool _loadingMore = false;
  List<Map<String, dynamic>> _clients = [];
  int _page = 1;
  int _total = 0;
  bool _hasMore = false;
  String _query = '';
  String _filterMode = 'todos';
  Timer? _debounce;
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> get _displayClients {
    switch (_filterMode) {
      case 'con_plan':
        return _clients.where((c) => c['current_plan'] != null).toList();
      case 'sin_plan':
        return _clients.where((c) => c['current_plan'] == null).toList();
      default:
        return _clients;
    }
  }

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = value;
      _load(reset: true);
    });
  }

  Future<void> _load({required bool reset}) async {
    final targetPage = reset ? 1 : _page + 1;
    if (reset) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final resp = await NutriologoApi.getClientsPage(
        search: _query,
        page: targetPage,
        perPage: _pageSize,
      );
      final data = (resp['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final meta = resp['meta'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        _clients = reset ? data : [..._clients, ...data];
        _page = (meta['current_page'] as num?)?.toInt() ?? targetPage;
        _total = (meta['total'] as num?)?.toInt() ?? _clients.length;
        _hasMore = meta['has_more'] == true;
        _isLoading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pacientes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 14),

            // Search bar
            TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: AppColors.neonGreen, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Todos', 'todos'),
                  const SizedBox(width: 8),
                  _filterChip('Con plan', 'con_plan'),
                  const SizedBox(width: 8),
                  _filterChip('Sin plan', 'sin_plan'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            if (!_isLoading)
              Text(
                '${_displayClients.length} de $_total paciente${_total != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),

            const SizedBox(height: 8),

            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : RefreshIndicator(
                      onRefresh: () => _load(reset: true),
                      color: AppColors.neonGreen,
                      child: _displayClients.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay pacientes que coincidan.',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  _displayClients.length + (_hasMore && _filterMode == 'todos' ? 1 : 0),
                              itemBuilder: (_, index) {
                                if (index == _displayClients.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    child: TextButton.icon(
                                      onPressed: _loadingMore
                                          ? null
                                          : () => _load(reset: false),
                                      icon: const Icon(Icons.expand_more,
                                          color: AppColors.neonGreen),
                                      label: Text(
                                        _loadingMore
                                            ? 'Cargando...'
                                            : 'Mostrar más',
                                        style: const TextStyle(
                                            color: AppColors.neonGreen),
                                      ),
                                    ),
                                  );
                                }
                                return _clientCard(_displayClients[index]);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _filterChip(String label, String mode) {
    final isActive = _filterMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _filterMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.neonGreen.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.neonGreen : Colors.white12,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.neonGreen : Colors.white54,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        6,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SkeletonBox(height: 72, width: double.infinity),
        ),
      ),
    );
  }

  Widget _clientCard(Map<String, dynamic> client) {
    final name = client['name']?.toString() ?? '';
    final initial =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    final bool hasActivePlans = client['current_plan'] != null;
    final bool isAlert = client['status'] == 'alerta';

    final statusColor = isAlert
        ? AppColors.coralOrange
        : hasActivePlans
            ? AppColors.neonGreen
            : Colors.white24;

    return GestureDetector(
      onTap: () => context.push('/nutriologo/seguimiento', extra: client),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18)),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 22,
              backgroundColor: statusColor.withValues(alpha: 0.14),
              child: Text(
                initial,
                style: TextStyle(
                  color: statusColor == Colors.white24
                      ? Colors.white38
                      : statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Sin nombre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      client['status_label']?.toString() ??
                          client['email']?.toString() ?? '',
                      style: TextStyle(
                        color: isAlert
                            ? AppColors.coralOrange.withValues(alpha: 0.8)
                            : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.15),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
