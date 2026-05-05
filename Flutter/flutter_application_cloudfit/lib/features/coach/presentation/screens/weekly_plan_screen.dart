import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';

class WeeklyPlanScreen extends StatefulWidget {
  final String clientId;
  final String clientName;

  const WeeklyPlanScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  final _supabase = Supabase.instance.client;
  final _notesCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  int? _coachId;

  List<Map<String, dynamic>> _availableRoutines = [];

  static const _days = [
    {'key': 'Mon', 'label': 'Lunes'},
    {'key': 'Tue', 'label': 'Martes'},
    {'key': 'Wed', 'label': 'Miércoles'},
    {'key': 'Thu', 'label': 'Jueves'},
    {'key': 'Fri', 'label': 'Viernes'},
    {'key': 'Sat', 'label': 'Sábado'},
    {'key': 'Sun', 'label': 'Domingo'},
  ];

  // day_key → list of {id, name, training_plan}
  Map<String, List<Map<String, dynamic>>> _weeklyPlan = {
    for (final d in _days) d['key'] as String: [],
  };

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      final myAuthId = _supabase.auth.currentUser!.id;
      final userData = await _supabase
          .from('users')
          .select('user_id')
          .eq('supabase_id', myAuthId)
          .single();
      _coachId = userData['user_id'] as int;

      final clientIdInt = int.parse(widget.clientId);

      // All routines available for this client
      final routinesData = await _supabase
          .from('routines')
          .select('id, name, training_plan')
          .eq('client_id', widget.clientId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      // Current weekly plan
      final planData = await _supabase
          .from('weekly_plans')
          .select('day_of_week, sort_order, routines(id, name, training_plan)')
          .eq('client_id', clientIdInt)
          .eq('coach_id', _coachId!)
          .order('sort_order');

      // Notes
      final clientData = await _supabase
          .from('clients')
          .select('weekly_plan_notes')
          .eq('user_id', clientIdInt)
          .maybeSingle();

      final newPlan = <String, List<Map<String, dynamic>>>{
        for (final d in _days) d['key'] as String: [],
      };

      for (final row in (planData as List)) {
        final day = row['day_of_week'] as String;
        if (newPlan.containsKey(day)) {
          final r = row['routines'] as Map<String, dynamic>;
          newPlan[day]!.add({
            'id': r['id'],
            'name': r['name'],
            'training_plan': r['training_plan'],
          });
        }
      }

      setState(() {
        _availableRoutines = List<Map<String, dynamic>>.from(routinesData);
        _weeklyPlan = newPlan;
        _notesCtrl.text = clientData?['weekly_plan_notes'] as String? ?? '';
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final coachId = _coachId;
    if (coachId == null) return;

    setState(() => _saving = true);
    try {
      final clientIdInt = int.parse(widget.clientId);

      // Full replace
      await _supabase
          .from('weekly_plans')
          .delete()
          .eq('client_id', clientIdInt)
          .eq('coach_id', coachId);

      final rows = <Map<String, dynamic>>[];
      for (final day in _days) {
        final dayKey = day['key'] as String;
        final routines = _weeklyPlan[dayKey]!;
        for (int i = 0; i < routines.length; i++) {
          rows.add({
            'client_id': clientIdInt,
            'coach_id': coachId,
            'routine_id': routines[i]['id'],
            'day_of_week': dayKey,
            'sort_order': i,
          });
        }
      }

      if (rows.isNotEmpty) {
        await _supabase.from('weekly_plans').insert(rows);
      }

      final notes = _notesCtrl.text.trim();
      await _supabase
          .from('clients')
          .update({'weekly_plan_notes': notes.isEmpty ? null : notes})
          .eq('user_id', clientIdInt);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan semanal guardado'),
          backgroundColor: AppColors.neonGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _pickRoutineForDay(String dayKey) {
    if (_availableRoutines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay rutinas creadas para este cliente')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SELECCIONAR RUTINA',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _availableRoutines.length,
                separatorBuilder: (_, i) =>
                    const Divider(color: Colors.white10, height: 1),
                itemBuilder: (ctx2, i) {
                  final r = _availableRoutines[i];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fitness_center,
                          color: AppColors.neonGreen, size: 18),
                    ),
                    title: Text(
                      r['name'] as String,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: r['training_plan'] != null
                        ? Text(
                            r['training_plan'] as String,
                            style: const TextStyle(
                                color: AppColors.neonGreen, fontSize: 11),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _weeklyPlan[dayKey]!.add({
                          'id': r['id'],
                          'name': r['name'],
                          'training_plan': r['training_plan'],
                        });
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
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
        title: Column(
          children: [
            const Text(
              'PLAN SEMANAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              widget.clientName,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.neonGreen),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'GUARDAR',
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                children: [
                  ..._days.map((day) => _buildDayCard(
                        dayKey: day['key'] as String,
                        dayLabel: day['label'] as String,
                      )),
                  const SizedBox(height: 16),
                  _buildNotesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildDayCard({required String dayKey, required String dayLabel}) {
    final routines = _weeklyPlan[dayKey]!;
    final hasRoutines = routines.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasRoutines
              ? AppColors.neonGreen.withValues(alpha:0.3)
              : Colors.white.withValues(alpha:0.06),
        ),
      ),
      child: Column(
        children: [
          // Day header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  dayLabel.toUpperCase(),
                  style: TextStyle(
                    color: hasRoutines ? AppColors.neonGreen : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                if (hasRoutines)
                  Text(
                    '${routines.length} rutina${routines.length > 1 ? 's' : ''}',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _pickRoutineForDay(dayKey),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.add,
                        color: AppColors.neonGreen, size: 16),
                  ),
                ),
              ],
            ),
          ),

          // Routines list
          if (hasRoutines)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: routines.asMap().entries.map((entry) {
                  final i = entry.key;
                  final r = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_handle,
                            color: Colors.white24, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (r['training_plan'] != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  r['training_plan'] as String,
                                  style: const TextStyle(
                                      color: AppColors.neonGreen,
                                      fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _weeklyPlan[dayKey]!.removeAt(i);
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close,
                                color: Colors.white38, size: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: const [
                  Icon(Icons.hotel, color: Colors.white24, size: 14),
                  SizedBox(width: 6),
                  Text('Descanso',
                      style:
                          TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOTAS DEL PLAN',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesCtrl,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Objetivos, restricciones, observaciones...',
              hintStyle: TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
