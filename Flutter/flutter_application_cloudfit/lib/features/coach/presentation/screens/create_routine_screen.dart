import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';

class CreateRoutineScreen extends StatefulWidget {
  final String clientId;
  const CreateRoutineScreen({super.key, required this.clientId});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _trainingPlan = 'Fuerza';
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  static const _trainingPlanOptions = [
    'Fuerza',
    'Hipertrofia',
    'Cardio',
    'Funcional',
    'Resistencia',
    'Movilidad',
    'HIIT',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveRoutine() async {
    if (_nameCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final coachData = await _supabase
          .from('users')
          .select('user_id')
          .eq('supabase_id', _supabase.auth.currentUser!.id)
          .single();

      final routineResponse = await _supabase.from('routines').insert({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'training_plan': _trainingPlan,
        'client_id': int.parse(widget.clientId),
        'coach_id': coachData['user_id'],
        'is_active': true,
      }).select().single();

      final newRoutineId = routineResponse['id'] as int;

      await _supabase.from('routine_assignments').insert({
        'routine_id': newRoutineId,
        'client_id': int.parse(widget.clientId),
        'coach_id': coachData['user_id'],
        'status': 'active',
        'assigned_at': DateTime.now().toUtc().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rutina creada. Ahora añade los ejercicios."),
          backgroundColor: AppColors.neonGreen,
        ),
      );
      context.pushReplacement('/add-exercises/${newRoutineId.toString()}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("NUEVA RUTINA")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildInput("NOMBRE DE LA RUTINA", _nameCtrl, "Ej. Hipertrofia Tren Superior"),
            const SizedBox(height: 20),
            _buildPlanDropdown(),
            const SizedBox(height: 20),
            _buildInput("DESCRIPCIÓN / NOTAS", _descCtrl, "Ej. 4 series de 12 reps...", isLong: true),
            const Spacer(),
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.neonGreen)
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveRoutine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("GUARDAR Y ASIGNAR", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TIPO DE ENTRENAMIENTO",
          style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardGrey,
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButton<String>(
            value: _trainingPlan,
            isExpanded: true,
            dropdownColor: AppColors.cardGrey,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: _trainingPlanOptions
                .map((plan) => DropdownMenuItem(value: plan, child: Text(plan)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _trainingPlan = v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, String hint, {bool isLong = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: isLong ? 4 : 1,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: AppColors.cardGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
