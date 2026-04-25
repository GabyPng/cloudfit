import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';

class ClientDetailScreen extends StatefulWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> _fetchClientData() async {
    final clientResp = await _supabase.from('users').select().eq('user_id', widget.clientId).single();
    
    // Fetch active routines
    final routinesResp = await _supabase
        .from('routines')
        .select()
        .eq('client_id', widget.clientId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    // Fetch last 7 progress logs
    final progressResp = await _supabase
        .from('progress')
        .select()
        .eq('client_id', widget.clientId)
        .order('date', ascending: true)
        .limit(7);

    // Fetch recent 5 workout logs
    final logsResp = await _supabase
        .from('workout_logs')
        .select()
        .eq('client_id', widget.clientId)
        .order('date', ascending: false)
        .limit(5);

    return {
      'client': clientResp,
      'routines': routinesResp,
      'progress': progressResp,
      'logs': logsResp,
    };
  }

  Future<void> _removeClient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardGrey,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar a este cliente? Se perderá la relación coach-cliente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final myAuthId = _supabase.auth.currentUser!.id;
        final userData = await _supabase
            .from('users')
            .select('user_id')
            .eq('supabase_id', myAuthId)
            .single();
        final myNumericId = userData['user_id'];

        await _supabase
            .from('clients')
            .delete()
            .eq('user_id', int.parse(widget.clientId))
            .eq('coach_id', myNumericId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminado exitosamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando cliente: $e')),
        );
      }
    }
  }

  Future<void> _editClient(Map<String, dynamic> client) async {
    final nameController = TextEditingController(text: client['name']);
    final emailController = TextEditingController(text: client['email']);
    final objectiveController = TextEditingController(text: client['objective'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardGrey,
        title: const Text(
          'Editar Cliente',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: objectiveController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Objetivo',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonGreen),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar', style: TextStyle(color: AppColors.neonGreen)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _supabase
            .from('users')
            .update({
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'objective': objectiveController.text.trim().isEmpty ? null : objectiveController.text.trim(),
            })
            .eq('user_id', client['user_id']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente actualizado exitosamente')),
        );
        // Refresh the screen
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error actualizando cliente: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "EXPEDIENTE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchClientData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar información: \n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen),
            );
          }

          final data = snapshot.data!;
          final client = data['client'] as Map<String, dynamic>;
          final routines = data['routines'] as List<dynamic>;
          final progress = data['progress'] as List<dynamic>;
          final logs = data['logs'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(client),
                const SizedBox(height: 30),

                // OBJECTIVE SECTION
                _buildSectionTitle("OBJETIVO PRINCIPAL"),
                _buildInfoCard(
                  client['objective'] ?? "Sin definir",
                  Icons.track_changes,
                  AppColors.neonGreen,
                ),
                const SizedBox(height: 30),

                // RUTINAS ACTIVAS
                _buildSectionTitle("RUTINAS ASIGNADAS"),
                _buildRoutinesAssigned(routines),
                const SizedBox(height: 30),

                // WORKOUT LOGS (OPTION B)
                _buildSectionTitle("ÚLTIMOS ENTRENAMIENTOS"),
                _buildWorkoutLogs(logs),
                const SizedBox(height: 30),

                // WEIGHT PROGRESS (OPTION A)
                _buildSectionTitle("PROGRESO DE PESO (kg)"),
                _buildWeightChart(progress),
                const SizedBox(height: 40),

                // ACTIONS
                _buildActionButton(
                  "ASIGNAR NUEVA RUTINA",
                  AppColors.electricPurple,
                  Icons.fitness_center,
                  onTap: () => context.push('/create-routine/${client['user_id']}'),
                ),
                const SizedBox(height: 15),
                _buildActionButton(
                  "ENVIAR MENSAJE (TICKET)",
                  Colors.white10,
                  Icons.chat_bubble_outline,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Función de chat en desarrollo")),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _buildActionButton(
                  "EDITAR CLIENTE",
                  AppColors.neonGreen,
                  Icons.edit,
                  onTap: () => _editClient(client),
                ),
                const SizedBox(height: 15),
                _buildActionButton(
                  "ELIMINAR CLIENTE",
                  Colors.redAccent,
                  Icons.delete_forever,
                  onTap: _removeClient,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> client) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.black26,
            backgroundImage: client['avatar_url'] != null
                ? NetworkImage(client['avatar_url'])
                : null,
            child: client['avatar_url'] == null
                ? const Icon(Icons.person, color: Colors.white38, size: 35)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  client['email'],
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesAssigned(List<dynamic> routines) {
    if (routines.isEmpty) {
      return const Text(
        "No hay rutinas asignadas actualmente.",
        style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic),
      );
    }
    return Column(
      children: routines.map((routine) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardGrey,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: AppColors.neonGreen, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routine['name'] ?? 'Rutina', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    if (routine['description'] != null && routine['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(routine['description'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ]
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkoutLogs(List<dynamic> logs) {
    if (logs.isEmpty) {
      return const Text(
        "No hay registros de entrenamiento recientes.",
        style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: logs.map((log) {
          final isComplete = log['is_complete'] == true || log['is_complete'] == 1;
          final dateStr = log['date'].toString().split(' ').first;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isComplete ? AppColors.neonGreen.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isComplete ? Icons.check_circle : Icons.cancel,
                    color: isComplete ? AppColors.neonGreen : Colors.redAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  "Rutina Personalizada", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeightChart(List<dynamic> progress) {
    if (progress.isEmpty) {
      return const Text(
        "No hay registros de peso guardados.",
        style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic),
      );
    }

    double maxWeight = 0;
    for (var p in progress) {
      final w = double.tryParse(p['weight'].toString()) ?? 0;
      if (w > maxWeight) maxWeight = w;
    }

    // A simple beautiful bar chart using native containers
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: progress.map((p) {
          final w = double.tryParse(p['weight'].toString()) ?? 0;
          final heightFactor = maxWeight > 0 ? (w / maxWeight) : 0.0;
          final dateStr = p['date'].toString().substring(8, 10) + '/' + p['date'].toString().substring(5, 7); // DD/MM

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                w.toStringAsFixed(1),
                style: const TextStyle(color: AppColors.neonGreen, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 25,
                height: 90 * heightFactor,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.neonGreen, Colors.tealAccent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateStr,
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == Colors.white10 ? Colors.white : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
