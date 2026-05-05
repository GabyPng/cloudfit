import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../data/nutriologo_api.dart';

class NutriologoSeguimientoScreen extends StatefulWidget {
  final Map<String, dynamic>? initialPatient;

  const NutriologoSeguimientoScreen({super.key, this.initialPatient});

  @override
  State<NutriologoSeguimientoScreen> createState() =>
      _NutriologoSeguimientoScreenState();
}

class _NutriologoSeguimientoScreenState
    extends State<NutriologoSeguimientoScreen> {
  bool _loadingPatients = true;
  bool _loadingHistory = false;
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _selectedPatient;
  List<Map<String, dynamic>> _history = [];
  String _patientFilter = '';
  final TextEditingController _patientSearchCtrl = TextEditingController();

  List<Map<String, dynamic>> get _filteredPatients {
    if (_patientFilter.isEmpty) return _patients;
    final q = _patientFilter.toLowerCase();
    return _patients.where((p) =>
      (p['name']?.toString().toLowerCase().contains(q) ?? false) ||
      (p['email']?.toString().toLowerCase().contains(q) ?? false),
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _patientSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() => _loadingPatients = true);
    try {
      final initial = widget.initialPatient;
      final initialId = initial != null ? _clientId(initial) : null;

      // Start both requests simultaneously when we already know the patient.
      final patientsF = NutriologoApi.getSeguimientoPacientes();
      final historialF =
          initialId != null ? NutriologoApi.getHistorial(initialId) : null;

      final patients = await patientsF;
      if (!mounted) return;

      final matched = initial != null
          ? patients.firstWhere(
              (p) =>
                  p['id'] == initial['id'] || p['user_id'] == initial['id'],
              orElse: () => initial,
            )
          : (patients.isNotEmpty ? patients.first : null);

      setState(() {
        _patients = patients;
        _selectedPatient = matched ?? initial;
        _loadingPatients = false;
        if (historialF != null) _loadingHistory = true;
      });

      if (historialF != null) {
        try {
          final resp = await historialF;
          if (!mounted) return;
          final timeline = (resp['timeline'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();
          setState(() {
            _history = timeline;
            _loadingHistory = false;
          });
        } catch (_) {
          if (mounted) setState(() => _loadingHistory = false);
        }
      } else if (matched != null) {
        _selectPatient(matched);
      } else if (initial != null) {
        _selectPatient(initial);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPatients = false);
    }
  }

  Future<void> _selectPatient(Map<String, dynamic> patient) async {
    setState(() {
      _selectedPatient = patient;
      _loadingHistory = true;
      _history = [];
    });
    try {
      final clientId = _clientId(patient);
      if (clientId == null) {
        if (mounted) setState(() => _loadingHistory = false);
        return;
      }
      final resp = await NutriologoApi.getHistorial(clientId);
      final timeline = (resp['timeline'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _history = timeline;
        _loadingHistory = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  int? _clientId(Map<String, dynamic> p) =>
      p['id'] as int? ?? p['client_id'] as int? ?? p['user_id'] as int?;

  Future<void> _addProgressDialog() async {
    if (_selectedPatient == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final dateCtrl = TextEditingController(text: today);
    final weightCtrl = TextEditingController();
    final bmiCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    final muscleCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final adherenceCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Registrar progreso',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 16),
              _inputField(dateCtrl, 'Fecha (YYYY-MM-DD) *'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _inputField(weightCtrl, 'Peso (kg)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 10),
                  Expanded(child: _inputField(bmiCtrl, 'IMC',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _inputField(fatCtrl, '% Grasa',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 10),
                  Expanded(child: _inputField(muscleCtrl, 'Músculo (kg)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _inputField(calCtrl, 'Calorías objetivo',
                      keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: _inputField(adherenceCtrl, 'Adherencia (%)',
                      keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 10),
              _inputField(notesCtrl, 'Notas / observaciones', maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final date = dateCtrl.text.trim();
                        if (date.isEmpty) return;
                        Navigator.pop(ctx);
                        final clientId = _clientId(_selectedPatient!);
                        if (clientId == null) return;
                        try {
                          await NutriologoApi.addProgress(
                            clientId: clientId,
                            date: date,
                            weightKg: double.tryParse(weightCtrl.text.trim()),
                            bmi: double.tryParse(bmiCtrl.text.trim()),
                            bodyFatPct: double.tryParse(fatCtrl.text.trim()),
                            muscleMassKg: double.tryParse(muscleCtrl.text.trim()),
                            caloriesTarget: int.tryParse(calCtrl.text.trim()),
                            adherencePct: int.tryParse(adherenceCtrl.text.trim()),
                            notes: notesCtrl.text.trim(),
                          );
                          await _selectPatient(_selectedPatient!);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                      child: const Text('Guardar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    dateCtrl.dispose();
    weightCtrl.dispose();
    bmiCtrl.dispose();
    fatCtrl.dispose();
    muscleCtrl.dispose();
    calCtrl.dispose();
    adherenceCtrl.dispose();
    notesCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _selectedPatient != null
              ? _selectedPatient!['name']?.toString() ?? 'Seguimiento'
              : 'Seguimiento',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedPatient != null)
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.neonGreen),
              onPressed: _addProgressDialog,
              tooltip: 'Registrar progreso',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: _loadingPatients
          ? _buildLoadingSkeleton()
          : _patients.isEmpty && widget.initialPatient == null
              ? const Center(
                  child: Text(
                    'No hay pacientes asignados.',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : Column(
                  children: [
                    if (_patients.isNotEmpty) ...[
                      // ── Encabezado + buscador ──────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pacientes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _patientSearchCtrl,
                              onChanged: (v) =>
                                  setState(() => _patientFilter = v),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Buscar paciente...',
                                hintStyle: const TextStyle(
                                    color: Colors.white38, fontSize: 13),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.white38, size: 18),
                                suffixIcon: _patientFilter.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            color: Colors.white38,
                                            size: 16),
                                        onPressed: () {
                                          _patientSearchCtrl.clear();
                                          setState(
                                              () => _patientFilter = '');
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: AppColors.surface,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Chips de pacientes ─────────────────────────
                      SizedBox(
                        height: 48,
                        child: _filteredPatients.isEmpty
                            ? const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Sin resultados.',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 12),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: _filteredPatients.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (_, i) =>
                                    _patientChip(_filteredPatients[i]),
                              ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    if (_selectedPatient != null)
                      _selectedPatientHeader(),

                    const SizedBox(height: 8),

                    Expanded(
                      child: _loadingHistory
                          ? Column(
                              children: List.generate(
                                4,
                                (_) => Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 10),
                                  child: SkeletonBox(
                                      height: 80,
                                      width: double.infinity),
                                ),
                              ),
                            )
                          : _history.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Sin registros para este paciente.',
                                    style:
                                        TextStyle(color: Colors.white54),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 100),
                                  itemCount: _history.length,
                                  itemBuilder: (_, i) =>
                                      _timelineItem(_history[i], i),
                                ),
                    ),
                  ],
                ),
    );
  }

  Widget _selectedPatientHeader() {
    final name = _selectedPatient!['name']?.toString() ?? 'Sin nombre';
    final email = _selectedPatient!['email']?.toString() ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final progressEntries =
        _history.where((e) => e['type'] == 'progreso').toList();
    final lastProgreso =
        progressEntries.isNotEmpty ? progressEntries.last : null;

    final weightPoints = progressEntries
        .where((e) => e['weight_kg'] != null)
        .map((e) => (e['weight_kg'] as num).toDouble())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.neonGreen.withValues(alpha: 0.18),
                child: Text(initial,
                    style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    if (email.isNotEmpty)
                      Text(email,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _addProgressDialog,
                icon: const Icon(Icons.add, color: AppColors.neonGreen, size: 14),
                label: const Text('Registrar',
                    style: TextStyle(color: AppColors.neonGreen, fontSize: 12)),
              ),
            ],
          ),
        ),
        if (!_loadingHistory && lastProgreso != null) ...[
          const SizedBox(height: 10),
          _metricsRow(lastProgreso),
          if (weightPoints.length >= 2) ...[
            const SizedBox(height: 10),
            _weightSparkline(weightPoints),
          ],
        ],
      ],
    );
  }

  Widget _metricsRow(Map<String, dynamic> p) {
    final tiles = <Widget>[
      if (p['weight_kg'] != null)
        _metricTile('Peso', '${p['weight_kg']} kg', AppColors.neonGreen),
      if (p['bmi'] != null)
        _metricTile('IMC', '${p['bmi']}', AppColors.electricPurple),
      if (p['body_fat_pct'] != null)
        _metricTile('Grasa', '${p['body_fat_pct']}%', AppColors.coralOrange),
      if (p['adherence_pct'] != null)
        _metricTile('Adherencia', '${p['adherence_pct']}%', const Color(0xFF4DD0E1)),
    ];
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: tiles),
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _weightSparkline(List<double> weights) {
    final last = weights.length > 6 ? weights.sublist(weights.length - 6) : weights;
    final minW = last.reduce((a, b) => a < b ? a : b);
    final maxW = last.reduce((a, b) => a > b ? a : b);
    final range = (maxW - minW).abs();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 52,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('kg',
                style: TextStyle(color: Colors.white24, fontSize: 9)),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: last.map((w) {
                  final isLast = w == last.last;
                  final heightPct =
                      range < 0.01 ? 0.6 : ((w - minW) / range) * 0.7 + 0.3;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isLast)
                        Text('$w',
                            style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 8,
                                fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Container(
                        width: 10,
                        height: 28 * heightPct,
                        decoration: BoxDecoration(
                          color: isLast
                              ? AppColors.neonGreen
                              : AppColors.neonGreen.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientChip(Map<String, dynamic> patient) {
    final isSelected = _selectedPatient?['id'] == patient['id'] ||
        _selectedPatient?['user_id'] == patient['user_id'];
    final name = patient['name']?.toString() ?? 'Paciente';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => _selectPatient(patient),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonGreen.withValues(alpha: 0.18)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color:
                isSelected ? AppColors.neonGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isSelected
                  ? AppColors.neonGreen.withValues(alpha: 0.3)
                  : AppColors.cardGrey,
              child: Text(
                initial,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.neonGreen
                      : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              name.split(' ').first,
              style: TextStyle(
                color: isSelected
                    ? AppColors.neonGreen
                    : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem(Map<String, dynamic> entry, int index) {
    final type = entry['type']?.toString() ?? 'progreso';
    final date = _formatDate(
        entry['date']?.toString() ?? entry['created_at']?.toString() ?? '');
    final isLast = index == _history.length - 1;

    Color accentColor;
    IconData icon;
    String title;
    List<Widget> chips;
    String? subtitle;

    if (type == 'asignacion_plan') {
      accentColor = AppColors.electricPurple;
      icon = Icons.restaurant_menu_outlined;
      title = entry['plan_title']?.toString() ?? 'Plan asignado';
      subtitle = entry['plan_goal']?.toString();
      chips = [
        if (entry['plan_calories'] != null)
          _chip('${entry['plan_calories']} kcal/día',
              AppColors.neonGreen),
        if (entry['status'] != null)
          _chip(_planStatusLabel(entry['status'].toString()),
              _planStatusColor(entry['status'].toString())),
        if (entry['starts_at'] != null)
          _chip('Inicio: ${entry['starts_at']}', Colors.white38),
      ];
    } else if (type == 'cambio_dieta') {
      accentColor = AppColors.coralOrange;
      icon = Icons.swap_horiz_rounded;
      title = _changeTypeLabel(entry['change_type']?.toString());
      subtitle = entry['reason']?.toString();
      chips = [
        if (entry['status'] != null)
          _chip(_dietStatusLabel(entry['status'].toString()),
              _dietStatusColor(entry['status'].toString())),
      ];
    } else {
      // progreso
      accentColor = AppColors.neonGreen;
      icon = Icons.monitor_weight_outlined;
      final weightKg = entry['weight_kg'];
      title = weightKg != null ? '$weightKg kg' : 'Registro de progreso';
      subtitle = entry['notes']?.toString();
      chips = [
        if (entry['bmi'] != null)
          _chip('IMC ${entry['bmi']}', Colors.white54),
        if (entry['body_fat_pct'] != null)
          _chip('${entry['body_fat_pct']}% grasa', Colors.white54),
        if (entry['adherence_pct'] != null)
          _chip('${entry['adherence_pct']}% adherencia',
              AppColors.electricPurple),
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              if (!isLast)
                Container(
                  width: 1.5,
                  height: 30,
                  color: Colors.white12,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 4, children: chips),
                  ],
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }

  String _planStatusLabel(String s) => const {
        'active': 'Activo',
        'paused': 'Pausado',
        'completed': 'Completado',
        'cancelled': 'Cancelado',
      }[s] ??
      s;

  Color _planStatusColor(String s) => switch (s) {
        'active' => AppColors.neonGreen,
        'paused' => const Color(0xFFFFBB00),
        'completed' => AppColors.electricPurple,
        _ => AppColors.coralOrange,
      };

  String _dietStatusLabel(String s) => const {
        'pending': 'Pendiente',
        'approved': 'Aprobado',
        'rejected': 'Rechazado',
      }[s] ??
      s;

  Color _dietStatusColor(String s) => switch (s) {
        'approved' => AppColors.neonGreen,
        'rejected' => AppColors.coralOrange,
        _ => const Color(0xFFFFBB00),
      };

  String _changeTypeLabel(String? t) => const {
        'plan_change': 'Cambio de plan',
        'meal_update': 'Actualización de comida',
        'macro_adjust': 'Ajuste de macros',
        'calorie_adjust': 'Ajuste calórico',
        'observation': 'Observación',
      }[t] ??
      (t ?? 'Cambio de dieta');

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SkeletonBox(height: 52, width: double.infinity),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SkeletonBox(height: 80, width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonGreen),
        ),
      ),
    );
  }
}
