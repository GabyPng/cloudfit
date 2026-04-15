import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';

class ProfessionalModel {
  final int userId;
  final String name;
  final String specialty;
  final String rating;
  final bool isOnline;
  final String? avatarUrl;
  final int roleId;

  ProfessionalModel({
    required this.userId,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.isOnline,
    this.avatarUrl,
    required this.roleId,
  });

  factory ProfessionalModel.fromMap(Map<String, dynamic> map) {
    final roleId = map['role_id'] as int;
    final specialty = roleId == 2 ? 'Coach' : 'Nutriólogo';

    return ProfessionalModel(
      userId: map['user_id'] as int,
      name: map['name'] ?? 'Sin nombre',
      specialty: specialty,
      rating: '4.8', // puedes agregar campo rating a la BD después
      isOnline: false,
      avatarUrl: map['avatar_url'],
      roleId: roleId,
    );
  }
}

class ProfessionalsScreen extends StatefulWidget {
  static const String name = 'professionals_screen';

  const ProfessionalsScreen({super.key});

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  final _supabase = Supabase.instance.client;
  List<ProfessionalModel> _professionals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfessionals();
  }

  Future<void> _fetchProfessionals() async {
    try {
      // role_id 2 = Coach, role_id 3 = Nutriólogo
      final response = await _supabase
          .from('users')
          .select('user_id, name, avatar_url, role_id')
          .inFilter('role_id', [2, 3])
          .order('role_id');

      setState(() {
        _professionals = (response as List)
            .map((e) => ProfessionalModel.fromMap(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar profesionales: $e';
        _isLoading = false;
      });
    }
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
      body: _buildBody(),
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

    if (_professionals.isEmpty) {
      return const Center(child: Text('No hay profesionales disponibles'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _professionals.length,
      itemBuilder: (context, index) => _professionalCard(_professionals[index]),
    );
  }

  Widget _professionalCard(ProfessionalModel pro) {
    return Container(
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
                backgroundImage: (pro.avatarUrl != null && pro.avatarUrl!.isNotEmpty)
                    ? NetworkImage(pro.avatarUrl!)
                    : null,
                child: (pro.avatarUrl == null || pro.avatarUrl!.isEmpty)
                    ? Text(
                        pro.name.isNotEmpty ? pro.name[0].toUpperCase() : '?',
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  pro.specialty,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      pro.rating,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge de rol
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
                color: pro.roleId == 2 ? AppColors.neonGreen : Colors.blue,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.neonGreen),
          ),
        ],
      ),
    );
  }
}