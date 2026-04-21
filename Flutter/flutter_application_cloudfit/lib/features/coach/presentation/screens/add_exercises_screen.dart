import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';

class AddExercisesScreen extends StatefulWidget {
  final String routineId;
  const AddExercisesScreen({super.key, required this.routineId});

  @override
  State<AddExercisesScreen> createState() => _AddExercisesScreenState();
}

class _AddExercisesScreenState extends State<AddExercisesScreen> {
  final _supabase = Supabase.instance.client;
  final _nameCtrl = TextEditingController();
  final _setsCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _restCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _addExercise() async {
  if (_nameCtrl.text.isEmpty || _setsCtrl.text.isEmpty) return;

  setState(() => _isLoading = true);
  try {
    // 1. Buscar o crear el ejercicio en exercise_catalog
    String exerciseName = _nameCtrl.text.trim();
    var existing = await _supabase
        .from('exercise_catalog')
        .select('exercise_id')
        .eq('name', exerciseName)
        .maybeSingle();
    
    int exerciseId;
    if (existing == null) {
      // Crear nuevo ejercicio
      final newExercise = await _supabase
          .from('exercise_catalog')
          .insert({'name': exerciseName})
          .select()
          .single();
      exerciseId = newExercise['exercise_id'];
    } else {
      exerciseId = existing['exercise_id'];
    }

    // 2. Insertar en routine_exercises
    await _supabase.from('routine_exercises').insert({
      'routine_id': int.parse(widget.routineId), // asegurar que es entero
      'exercise_id': exerciseId,
      'exercise_name': exerciseName, // opcional, pero lo guardamos
      'sets': int.parse(_setsCtrl.text),
      'reps': _repsCtrl.text.trim(),
      'rest_time': _restCtrl.text.trim(),
    });

    // Limpiar campos...
  } catch (e) {
    print("Error: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        title: const Text("AÑADIR EJERCICIOS"),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check, color: AppColors.neonGreen),
            label: const Text("TERMINAR", style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildCurrentExercisesList()),
          _buildAddForm(),
        ],
      ),
    );
  }

  Widget _buildCurrentExercisesList() {
    return StreamBuilder(
      stream: _supabase.from('routine_exercises').stream(primaryKey: ['id']).eq('routine_id', widget.routineId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(docs[i]['exercise_name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text("${docs[i]['sets']} series x ${docs[i]['reps']}", style: const TextStyle(color: Colors.white38)),
            trailing: const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 20),
          ),
        );
      },
    );
  }

  Widget _buildAddForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: AppColors.cardGrey, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: "Nombre (ej. Sentadilla)", hintStyle: TextStyle(color: Colors.white24))),
          Row(
            children: [
              Expanded(child: TextField(controller: _setsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Series"))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _repsCtrl, decoration: const InputDecoration(hintText: "Reps"))),
            ],
          ),
          const SizedBox(height: 15),
          _isLoading 
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _addExercise, 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
                child: const Text("AÑADIR A LA LISTA"),
              ),
        ],
      ),
    );
  }
}