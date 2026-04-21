import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';

class CreateRoutineScreen extends StatefulWidget {
  final String clientId; // ID del alumno
  const CreateRoutineScreen({super.key, required this.clientId});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  Future<void> _saveRoutine() async {
  if (_nameCtrl.text.isEmpty) return;

  setState(() => _isLoading = true);
  try {
    // 1. Obtenemos el ID numérico del Coach
    final coachData = await _supabase
        .from('users')
        .select('user_id')
        .eq('supabase_id', _supabase.auth.currentUser!.id)
        .single();

    // 2. REEMPLAZO: Agregamos .select().single() para obtener el registro creado
    final routineResponse = await _supabase.from('routines').insert({
  'name': _nameCtrl.text.trim(),
  'description': _descCtrl.text.trim(),
  'client_id': widget.clientId,  // antes 'user_id'
  'coach_id': coachData['user_id'], // usa 'user_id' (nueva columna)
  'is_active': true,
}).select().single();

    final newRoutineId = routineResponse['id'].toString(); // Extraemos el ID

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rutina creada. Ahora añade los ejercicios."), backgroundColor: AppColors.neonGreen)
      );
      
      // 3. REEMPLAZO: En lugar de Navigator.pop, saltamos a la pantalla de ejercicios
      context.pushReplacement('/add-exercises/$newRoutineId'); 
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
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
            _buildInput("DESCRIPCIÓN / NOTAS", _descCtrl, "Ej. 4 series de 12 reps...", isLong: true),
            const Spacer(),
            _isLoading 
              ? const CircularProgressIndicator(color: AppColors.neonGreen)
              : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveRoutine,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
                    child: const Text("GUARDAR Y ASIGNAR", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
          ],
        ),
      ),
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