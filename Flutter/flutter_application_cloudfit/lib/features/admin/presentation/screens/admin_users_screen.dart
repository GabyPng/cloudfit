import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../data/admin_api.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  List _users = [];
  Map _meta = {};
  bool _loading = true;
  int _page = 1;
  String? _roleFilter;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    _page = 1;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await AdminApi.getUsers(
        search: _searchCtrl.text.trim(),
        role: _roleFilter,
        page: _page,
      );
      if (!mounted) return;
      setState(() {
        _users = result['data'] as List;
        _meta = result['meta'] as Map;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildSearch(),
      _buildRoleFilters(),
      Expanded(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.neonGreen))
            : _users.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    color: AppColors.neonGreen,
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: _users.length,
                      itemBuilder: (_, i) => _buildUserCard(_users[i] as Map),
                    ),
                  ),
      ),
      _buildPagination(),
    ]);
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o email...',
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: const Icon(Icons.search, color: Colors.white30, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white30, size: 18),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleFilters() {
    final roles = [null, 'cliente', 'coach', 'nutriologo', 'admin'];
    final labels = {
      null: 'Todos',
      'cliente': 'Clientes',
      'coach': 'Coaches',
      'nutriologo': 'Nutriologos',
      'admin': 'Admins',
    };

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: roles.map((r) {
          final sel = _roleFilter == r;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _roleFilter = r;
                  _page = 1;
                });
                _load();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.neonGreen.withValues(alpha: 0.18)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel ? AppColors.neonGreen : Colors.white12),
                ),
                child: Text(labels[r]!,
                    style: TextStyle(
                      color: sel ? AppColors.neonGreen : Colors.white54,
                      fontSize: 11,
                      fontWeight:
                          sel ? FontWeight.bold : FontWeight.normal,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserCard(Map user) {
    final name = user['name']?.toString() ?? '—';
    final email = user['email']?.toString() ?? '';
    final role = (user['roles'] as Map?)?['name']?.toString() ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.neonGreen.withValues(alpha: 0.15),
          child: Text(initial,
              style: const TextStyle(
                  color: AppColors.neonGreen,
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
                      fontSize: 13)),
              Text(email,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
        if (role.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _roleColor(role).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(role,
                style: TextStyle(
                    color: _roleColor(role),
                    fontSize: 9,
                    fontWeight: FontWeight.bold)),
          ),
      ]),
    );
  }

  Color _roleColor(String role) {
    return switch (role) {
      'coach' => AppColors.neonGreen,
      'nutriologo' => AppColors.electricPurple,
      'admin' => const Color(0xFFEF4444),
      _ => Colors.white54,
    };
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: AppColors.surface, shape: BoxShape.circle),
          child: const Icon(Icons.people_outline,
              color: Colors.white24, size: 44),
        ),
        const SizedBox(height: 16),
        const Text('Sin usuarios encontrados',
            style: TextStyle(color: Colors.white38, fontSize: 14)),
      ]),
    );
  }

  Widget _buildPagination() {
    final lastPage = (_meta['last_page'] as int?) ?? 1;
    if (lastPage <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white54),
          onPressed: _page > 1
              ? () {
                  setState(() => _page--);
                  _load();
                }
              : null,
        ),
        Text('$_page / $lastPage',
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white54),
          onPressed: _page < lastPage
              ? () {
                  setState(() => _page++);
                  _load();
                }
              : null,
        ),
      ]),
    );
  }
}
