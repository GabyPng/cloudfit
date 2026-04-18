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
  final TextEditingController _searchController = TextEditingController();

  List<ProfessionalModel> _professionals = [];
  List<ProfessionalModel> _filtered = [];
  bool _isLoading = true;
  String? _error;

  // null = todos, 2 = Coach, 3 = Nutriólogo
  int? _selectedRole;

  @override
  void initState() {
    super.initState();
    _fetchProfessionals();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfessionals() async {
    try {
      final response = await _supabase
          .from('users')
          .select(
              'user_id, name, avatar_url, role_id, objective, nutriologos(license_number, focus, certificate_uploads)')
          .inFilter('role_id', [2, 3]).order('role_id');

      setState(() {
        _professionals = (response as List)
            .map((e) => ProfessionalModel.fromMap(e))
            .toList();
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
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = _professionals.where((pro) {
        final matchesName = pro.name.toLowerCase().contains(query);
        final matchesRole =
            _selectedRole == null || pro.roleId == _selectedRole;
        return matchesName && matchesRole;
      }).toList();
    });
  }

  void _setRoleFilter(int? roleId) {
    setState(() => _selectedRole = roleId);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Profesionales",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchProfessionals();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar profesional...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.cardGrey,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          _filterChip(label: 'Todos', roleId: null),
          const SizedBox(width: 8),
          _filterChip(label: 'Coaches', roleId: 2),
          const SizedBox(width: 8),
          _filterChip(label: 'Nutriólogos', roleId: 3),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required int? roleId}) {
    final isSelected = _selectedRole == roleId;
    Color chipColor;
    if (roleId == 2) {
      chipColor = AppColors.neonGreen;
    } else if (roleId == 3) {
      chipColor = Colors.blue;
    } else {
      chipColor = Colors.white70;
    }

    return GestureDetector(
      onTap: () => _setRoleFilter(roleId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.2) : AppColors.cardGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? chipColor : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neonGreen),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchProfessionals,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search, color: Colors.white24, size: 64),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Sin resultados para "${_searchController.text}"'
                  : 'No hay profesionales disponibles',
              style: const TextStyle(color: Colors.white38),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filtered.length,
      itemBuilder: (context, index) => _professionalCard(_filtered[index]),
    );
  }

  Widget _professionalCard(ProfessionalModel pro) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfessionalDetailScreen(professional: pro),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.neonGreen.withOpacity(0.2),
                  backgroundImage: (pro.avatarUrl != null &&
                          pro.avatarUrl!.isNotEmpty)
                      ? NetworkImage(pro.avatarUrl!)
                      : null,
                  child: (pro.avatarUrl == null || pro.avatarUrl!.isEmpty)
                      ? Text(
                          pro.name.isNotEmpty
                              ? pro.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neonGreen,
                          ),
                        )
                      : null,
                ),
                if (pro.isOnline)
                  Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardGrey, width: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pro.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    pro.specialty,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        pro.rating,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pro.roleId == 2
                    ? AppColors.neonGreen.withOpacity(0.15)
                    : Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pro.roleId == 2 ? 'Coach' : 'Nutri',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color:
                      pro.roleId == 2 ? AppColors.neonGreen : Colors.blue,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
              },
              icon: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.neonGreen),
            ),
          ],
        ),
      ),
    );
  }
}