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
  Timer? _debounce;
  final _searchCtrl = TextEditingController();

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
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 14),

            // Search bar
            TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white54, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (!_isLoading)
              Text(
                '$_total paciente${_total != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),

            const SizedBox(height: 8),

            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : RefreshIndicator(
                      onRefresh: () => _load(reset: true),
                      color: AppColors.neonGreen,
                      child: _clients.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay pacientes que coincidan.',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  _clients.length + (_hasMore ? 1 : 0),
                              itemBuilder: (_, index) {
                                if (index == _clients.length) {
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
                                return _clientCard(_clients[index]);
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
    final activePlans = client['active_plans_count'] as int? ?? 0;
    final bool hasActivePlans = activePlans > 0;

    return GestureDetector(
      onTap: () => context.push('/nutriologo/seguimiento', extra: client),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: hasActivePlans
                ? AppColors.neonGreen.withValues(alpha: 0.18)
                : AppColors.cardGrey,
            child: Text(
              initial,
              style: TextStyle(
                color: hasActivePlans ? AppColors.neonGreen : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  client['email']?.toString() ?? '',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (activePlans > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$activePlans plan${activePlans != 1 ? 'es' : ''}',
                style: const TextStyle(
                  color: AppColors.neonGreen,
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
}
