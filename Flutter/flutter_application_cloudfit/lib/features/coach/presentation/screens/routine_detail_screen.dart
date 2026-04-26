import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';

class RoutineDetailScreen extends StatefulWidget {
  final String routineId;
  const RoutineDetailScreen({super.key, required this.routineId});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> _fetchRoutine() async {
    return await _supabase
        .from('routines')
        .select()
        .eq('id', widget.routineId)
        .single();
  }

  Future<void> _deleteExercise(int exerciseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardGrey,
        title: const Text('Eliminar ejercicio', style: TextStyle(color: Colors.white)),
        content: const Text('¿Deseas eliminar este ejercicio?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _supabase.from('routine_exercises').delete().eq('id', exerciseId);
    }
  }

  Future<void> _editExercise(Map<String, dynamic> exercise) async {
    final nameCtrl = TextEditingController(text: exercise['exercise_name']);
    final setsCtrl = TextEditingController(text: exercise['sets']?.toString() ?? '');
    final repsCtrl = TextEditingController(text: exercise['reps'] ?? '');
    final restCtrl = TextEditingController(text: exercise['rest_time'] ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardGrey,
        title: const Text('Editar ejercicio', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'Nombre del ejercicio'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _dialogField(setsCtrl, 'Series', isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _dialogField(repsCtrl, 'Reps')),
                ],
              ),
              const SizedBox(height: 12),
              _dialogField(restCtrl, 'Descanso (ej. 90 seg)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar', style: TextStyle(color: AppColors.neonGreen)),
          ),
        ],
      ),
    );

    if (saved == true) {
      await _supabase.from('routine_exercises').update({
        'exercise_name': nameCtrl.text.trim(),
        'sets': int.tryParse(setsCtrl.text.trim()) ?? exercise['sets'],
        'reps': repsCtrl.text.trim(),
        'rest_time': restCtrl.text.trim(),
      }).eq('id', exercise['id']);
    }
  }

  Future<void> _addExercise() async {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    final restCtrl = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardGrey,
        title: const Text('Nuevo ejercicio', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'Nombre del ejercicio'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _dialogField(setsCtrl, 'Series', isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _dialogField(repsCtrl, 'Reps')),
                ],
              ),
              const SizedBox(height: 12),
              _dialogField(restCtrl, 'Descanso (ej. 90 seg)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Agregar', style: TextStyle(color: AppColors.neonGreen)),
          ),
        ],
      ),
    );

    if (saved == true && nameCtrl.text.trim().isNotEmpty) {
      final exerciseName = nameCtrl.text.trim();

      var existing = await _supabase
          .from('exercise_catalog')
          .select('exercise_id')
          .eq('name', exerciseName)
          .maybeSingle();

      int exerciseId;
      if (existing == null) {
        final created = await _supabase
            .from('exercise_catalog')
            .insert({'name': exerciseName})
            .select()
            .single();
        exerciseId = created['exercise_id'];
      } else {
        exerciseId = existing['exercise_id'];
      }

      await _supabase.from('routine_exercises').insert({
        'routine_id': int.parse(widget.routineId),
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'sets': int.tryParse(setsCtrl.text.trim()) ?? 3,
        'reps': repsCtrl.text.trim(),
        'rest_time': restCtrl.text.trim(),
      });
    }
  }

  Widget _dialogField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.neonGreen),
        ),
      ),
    );
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
        title: FutureBuilder<Map<String, dynamic>>(
          future: _fetchRoutine(),
          builder: (ctx, snap) => Text(
            snap.data?['name'] ?? 'RUTINA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('routine_exercises')
            .stream(primaryKey: ['id'])
            .eq('routine_id', widget.routineId)
            .order('order', ascending: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.neonGreen));
          }

          final exercises = snapshot.data!;

          if (exercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, color: Colors.white24, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin ejercicios aún',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _addExercise,
                    child: const Text('+ Agregar el primero', style: TextStyle(color: AppColors.neonGreen)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: exercises.length,
            itemBuilder: (ctx, i) {
              final ex = exercises[i];
              return Dismissible(
                key: ValueKey(ex['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 28),
                ),
                confirmDismiss: (_) async {
                  await _deleteExercise(ex['id']);
                  return false;
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: AppColors.neonGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      ex['exercise_name'] ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${ex['sets']} series × ${ex['reps']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        if (ex['rest_time'] != null && ex['rest_time'].toString().isNotEmpty)
                          Text(
                            'Descanso: ${ex['rest_time']}',
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 20),
                      onPressed: () => _editExercise(ex),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
