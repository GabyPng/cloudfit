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

  Stream<List<Map<String, dynamic>>> _getClientsStream() async* {
    // 1. Obtenemos el ID numérico que corresponde a nuestra sesión de Supabase
    final myAuthId = _supabase.auth.currentUser!.id;

    final userData = await _supabase
        .from('users')
        .select('id')
        .eq(
          'supabase_id',
          myAuthId,
        ) // Asumiendo que guardas el UUID en esta columna
        .single();

    final myNumericId = userData['id'];

    // 2. Ahora sí, lanzamos el stream con el ID correcto
    yield* _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('coach_id', myNumericId)
        .order('name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Panel de Coach",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            Text(
              "CLOUDFIT",
              style: TextStyle(
                color: AppColors.neonGreen,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: AppColors.cardGrey,
          child: IconButton(
            onPressed: () => _supabase.auth.signOut(),
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _statCard("ALUMNOS", "12", AppColors.neonGreen),
        const SizedBox(width: 15),
        _statCard("PLANES", "5", AppColors.electricPurple),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientsList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getClientsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final clients = snapshot.data!;
        if (clients.isEmpty)
          return const Center(
            child: Text(
              "No tienes alumnos asignados.",
              style: TextStyle(color: Colors.white24),
            ),
          );

        return ListView.builder(
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return GestureDetector(
              onTap: () => context.push('/client-detail/${client['id']}'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.cardGrey,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        client['avatar_url'] ??
                            'https://via.placeholder.com/150',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            client['objective'] ?? "Sin objetivo",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white10,
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
