import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';

class CoachMainScreen extends StatefulWidget {
  static const String name = 'coach_main';
  const CoachMainScreen({super.key});

  @override
  State<CoachMainScreen> createState() => _CoachMainScreenState();
}

class _CoachMainScreenState extends State<CoachMainScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _filteredClients = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _selectedFilter = 'Todos'; // 'Todos', 'Con objetivo', 'Sin objetivo'

  @override
  void initState() {
    super.initState();
    _loadClients();
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      _clients = await _getClients();
      _filterClients();
    } catch (e) {
      // Handle error if needed
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients = _clients.where((client) {
        final matchesSearch = client['name'].toLowerCase().contains(query) ||
                             client['email'].toLowerCase().contains(query);
        
        final matchesFilter = _selectedFilter == 'Todos' ||
                             (_selectedFilter == 'Con objetivo' && client['objective'] != null && client['objective'].isNotEmpty) ||
                             (_selectedFilter == 'Sin objetivo' && (client['objective'] == null || client['objective'].isEmpty));
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _changeFilter(String filter) {
    setState(() => _selectedFilter = filter);
    _filterClients();
  }

  void _addClient() {
    context.push('/add-client').then((_) => _loadClients());
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o email',
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: AppColors.cardGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _filterChip('Todos'),
            const SizedBox(width: 10),
            _filterChip('Con objetivo'),
            const SizedBox(width: 10),
            _filterChip('Sin objetivo'),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _changeFilter(label),
      backgroundColor: AppColors.cardGrey,
      selectedColor: AppColors.neonGreen.withOpacity(0.2),
      checkmarkColor: AppColors.neonGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.neonGreen : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.neonGreen : Colors.white10,
          width: 1,
        ),
      ),
    );
  }

Future<List<Map<String, dynamic>>> _getClients() async {
  final myAuthId = _supabase.auth.currentUser!.id;
  final userData = await _supabase
      .from('users')
      .select('user_id')
      .eq('supabase_id', myAuthId)
      .single();
  final myNumericId = userData['user_id'];

  final clientsData = await _supabase
      .from('clients')
      .select('user_id, coach_id')
      .eq('coach_id', myNumericId);
  
  final List<Map<String, dynamic>> clientsWithUsers = [];
  for (var client in clientsData) {
    final user = await _supabase
        .from('users')
        .select('user_id, name, email, avatar_url, objective')
        .eq('user_id', client['user_id'])
        .single();
    clientsWithUsers.add(user);
  }
  return clientsWithUsers;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: _addClient,
        backgroundColor: AppColors.neonGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildStats(),
              const SizedBox(height: 30),
              const Text(
                "MIS ALUMNOS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              _buildSearchAndFilters(),
              const SizedBox(height: 15),
              Expanded(child: _buildClientsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "HOLA, COACH",
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.neonGreen, Colors.tealAccent],
              ).createShader(bounds),
              child: const Text(
                "CLOUDFIT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neonGreen.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: CircleAvatar(
            backgroundColor: AppColors.cardGrey,
            radius: 22,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => _supabase.auth.signOut(),
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _statCard("ALUMNOS", _isLoading ? "..." : _clients.length.toString(), AppColors.neonGreen),
        const SizedBox(width: 15),
        _statCard("PLANES", "5", AppColors.electricPurple),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.cardGrey,
              AppColors.cardGrey.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filteredClients.isEmpty) {
      return const Center(
        child: Text(
          "No se encontraron clientes con los filtros aplicados.",
          style: TextStyle(color: Colors.white24),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return GestureDetector(
          onTap: () => context.push('/client-detail/${client['user_id']}'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardGrey,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'avatar_${client['user_id']}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.electricPurple.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.cardGrey,
                      backgroundImage: client['avatar_url'] != null
                          ? NetworkImage(client['avatar_url'])
                          : null,
                      child: client['avatar_url'] == null
                          ? const Icon(Icons.person, color: Colors.white54, size: 28)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.track_changes, size: 14, color: AppColors.neonGreen.withOpacity(0.8)),
                          const SizedBox(width: 5),
                          Text(
                            client['objective'] ?? "Sin objetivo",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white60,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
