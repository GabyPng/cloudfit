import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants.dart';
import 'models/professional_model.dart';
import 'professional_detail_screen.dart';

class ProfessionalsScreen extends StatefulWidget {
  static const String name = 'professionals_screen';
  const ProfessionalsScreen({super.key});

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  final _supabase = Supabase.instance.client;
  final _searchCtrl = TextEditingController();

  List<ProfessionalModel> _professionals = [];
  List<ProfessionalModel> _filtered = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedRole;

  @override
  void initState() {
    super.initState();
    _fetchProfessionals();
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfessionals() async {
    try {
      final response = await _supabase
          .from('users')
          .select(
              'user_id, name, avatar_url, role_id, objective, nutriologos(license_number, focus, certificate_uploads)')
          .inFilter('role_id', [2, 3])
          .order('role_id');

      setState(() {
        _professionals =
            (response as List).map((e) => ProfessionalModel.fromMap(e)).toList();
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = 'Error al cargar profesionales: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = _professionals.where((p) {
        final nameMatch = p.name.toLowerCase().contains(q);
        final roleMatch = _selectedRole == null || p.roleId == _selectedRole;
        return nameMatch && roleMatch;
      }).toList();
    });
  }

  void _setRole(int? roleId) {
    setState(() => _selectedRole = roleId);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearch(),
            _buildChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Profesionales',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const Text('Encuentra a tu equipo ideal',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ]),
        const Spacer(),
        IconButton(
          onPressed: () {
            setState(() => _isLoading = true);
            _fetchProfessionals();
          },
          icon: const Icon(Icons.refresh_rounded, color: Colors.white38),
        ),
      ]),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre...',
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon:
              const Icon(Icons.search_rounded, color: Colors.white30, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white30, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    _applyFilters();
                  },
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
                BorderSide(color: Colors.white.withValues(alpha: 0.07), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.neonGreen, width: 1),
          ),
        ),
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────
  Widget _buildChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(children: [
        _chip(label: 'Todos', roleId: null, icon: Icons.people_outline),
        const SizedBox(width: 8),
        _chip(label: 'Coaches', roleId: 2, icon: Icons.fitness_center),
        const SizedBox(width: 8),
        _chip(
            label: 'Nutriólogos',
            roleId: 3,
            icon: Icons.restaurant_menu_outlined),
      ]),
    );
  }

  Widget _chip(
      {required String label, required int? roleId, required IconData icon}) {
    final sel = _selectedRole == roleId;
    final Color c = roleId == 2
        ? AppColors.neonGreen
        : roleId == 3
            ? AppColors.electricPurple
            : Colors.white70;
    return GestureDetector(
      onTap: () => _setRole(roleId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? c.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: sel ? c.withValues(alpha: 0.70) : Colors.white12,
              width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: sel ? c : Colors.white38),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? c : Colors.white38,
              )),
        ]),
      ),
    );
  }

  // ── Body states ───────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.neonGreen));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.coralOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    color: AppColors.coralOrange, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Sin conexión',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 13)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _fetchProfessionals,
                child: const Text('Reintentar',
                    style: TextStyle(color: AppColors.neonGreen)),
              ),
            ],
          ),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration:
                  const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: const Icon(Icons.person_search_outlined,
                  color: Colors.white24, size: 44),
            ),
            const SizedBox(height: 16),
            Text(
              _searchCtrl.text.isNotEmpty
                  ? 'Sin resultados para "${_searchCtrl.text}"'
                  : 'No hay profesionales disponibles',
              style: const TextStyle(color: Colors.white38, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _proCard(_filtered[i]),
    );
  }

  // ── Professional card ─────────────────────────────────────────────────────
  Widget _proCard(ProfessionalModel pro) {
    final isCoach = pro.roleId == 2;
    final rc = isCoach ? AppColors.neonGreen : AppColors.electricPurple;
    final rl = isCoach ? 'Coach' : 'Nutriólogo';

    return GestureDetector(
      onTap: () => _goToDetail(pro),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rc.withValues(alpha: 0.18), width: 1),
        ),
        child: Column(children: [
          // Main row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(children: [
              // Avatar
              Stack(children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [rc, rc.withValues(alpha: 0.30)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.cardGrey,
                    backgroundImage: (pro.avatarUrl?.isNotEmpty == true)
                        ? NetworkImage(pro.avatarUrl!)
                        : null,
                    child: (pro.avatarUrl?.isNotEmpty != true)
                        ? Text(
                            pro.name.isNotEmpty
                                ? pro.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: rc),
                          )
                        : null,
                  ),
                ),
                if (pro.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(pro.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: rc.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(rl,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: rc)),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      if (pro.objective?.isNotEmpty == true)
                        Text(pro.objective!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white38)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(pro.rating,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        if (!pro.isOnline) ...[
                          const SizedBox(width: 10),
                          const Text('Fuera de línea',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.white30)),
                        ],
                      ]),
                    ]),
              ),
            ]),
          ),
          // Bottom action strip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: Row(children: [
              Expanded(
                child: _inlineBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Mensaje',
                  color: rc,
                  onTap: () {},
                ),
              ),
              Container(width: 1, height: 20, color: Colors.white12),
              Expanded(
                child: _inlineBtn(
                  icon: Icons.arrow_forward_rounded,
                  label: 'Ver perfil',
                  color: Colors.white54,
                  onTap: () => _goToDetail(pro),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _inlineBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  void _goToDetail(ProfessionalModel pro) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ProfessionalDetailScreen(professional: pro)),
    );
  }
}
