import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../data/nutriologo_api.dart';

class NutriologoPlanesScreen extends StatefulWidget {
  const NutriologoPlanesScreen({super.key});

  @override
  State<NutriologoPlanesScreen> createState() => _NutriologoPlanesScreenState();
}

class _NutriologoPlanesScreenState extends State<NutriologoPlanesScreen> {
  static const int _pageSize = 8;

  bool _isLoading = true;
  bool _loadingMore = false;
  bool _saving = false;
  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _clients = [];
  int _page = 1;
  int _total = 0;
  bool _hasMore = false;
  String _query = '';
  Timer? _debounce;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _loadClients();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = value;
      _load(reset: true);
    });
  }

  Future<void> _load({required bool reset}) async {
    final targetPage = reset ? 1 : _page + 1;
    if (reset) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final resp = await NutriologoApi.getPlansPage(
        search: _query,
        page: targetPage,
        perPage: _pageSize,
      );
      final data = (resp['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final meta = resp['meta'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        _plans = reset ? data : [..._plans, ...data];
        _page = (meta['current_page'] as num?)?.toInt() ?? targetPage;
        _total = (meta['total'] as num?)?.toInt() ?? _plans.length;
        _hasMore = meta['has_more'] == true;
        _isLoading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _loadClients() async {
    try {
      final resp = await NutriologoApi.getClientsPage(perPage: 50);
      if (!mounted) return;
      setState(() {
        _clients = (resp['data'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
      });
    } catch (_) {}
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _createPlanDialog() async {
    final titleCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuevo plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(controller: titleCtrl, label: 'Título *'),
            const SizedBox(height: 10),
            _input(controller: goalCtrl, label: 'Objetivo'),
            const SizedBox(height: 10),
            _input(controller: caloriesCtrl, label: 'Calorías diarias', keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              setState(() => _saving = true);
              try {
                await NutriologoApi.createPlan(
                  title: titleCtrl.text.trim(),
                  goal: goalCtrl.text.trim(),
                  dailyCalories: int.tryParse(caloriesCtrl.text.trim()),
                );
                _snack('Plan creado correctamente.');
                await _load(reset: true);
              } catch (e) {
                _snack('Error: $e');
              } finally {
                if (mounted) setState(() => _saving = false);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _editPlanDialog(Map<String, dynamic> plan) async {
    final titleCtrl = TextEditingController(text: plan['title']?.toString() ?? '');
    final goalCtrl = TextEditingController(text: plan['goal']?.toString() ?? '');
    final caloriesCtrl = TextEditingController(text: plan['daily_calories']?.toString() ?? '');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(controller: titleCtrl, label: 'Título *'),
            const SizedBox(height: 10),
            _input(controller: goalCtrl, label: 'Objetivo'),
            const SizedBox(height: 10),
            _input(controller: caloriesCtrl, label: 'Calorías diarias', keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                await NutriologoApi.updatePlan(
                  planId: plan['id'] as int,
                  title: titleCtrl.text.trim(),
                  goal: goalCtrl.text.trim(),
                  dailyCalories: int.tryParse(caloriesCtrl.text.trim()),
                );
                _snack('Plan actualizado.');
                await _load(reset: true);
              } catch (e) {
                _snack('Error: $e');
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlanDialog(Map<String, dynamic> plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Se eliminará "${plan['title'] ?? 'este plan'}" y todas sus asignaciones. Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coralOrange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await NutriologoApi.deletePlan(plan['id'] as int);
      _snack('Plan eliminado.');
      await _load(reset: true);
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> _assignPlanDialog(int planId) async {
    if (_clients.isEmpty) {
      _snack('No hay clientes disponibles para asignar.');
      return;
    }
    int selectedClientId = _clients.first['id'] as int;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Asignar plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: DropdownButtonFormField<int>(
          initialValue: selectedClientId,
          dropdownColor: const Color(0xFF1A1A1A),
          decoration: const InputDecoration(
            labelText: 'Paciente',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          items: _clients
              .map((c) => DropdownMenuItem<int>(
                    value: c['id'] as int,
                    child: Text(c['name']?.toString() ?? 'Sin nombre'),
                  ))
              .toList(),
          onChanged: (v) { if (v != null) selectedClientId = v; },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await NutriologoApi.assignPlan(planId: planId, clientId: selectedClientId);
                _snack('Plan asignado correctamente.');
                await _load(reset: true);
              } catch (e) {
                _snack('Error: $e');
              }
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  Future<void> _viewPlanDetail(int planId) async {
    try {
      final detail = await NutriologoApi.getPlanDetail(planId);
      final meals = (detail['meals'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final assignments = (detail['assignments'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.background,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, sc) => ListView(
            controller: sc,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                detail['title']?.toString() ?? 'Plan nutricional',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              if (detail['goal'] != null)
                Text('Objetivo: ${detail['goal']}', style: const TextStyle(color: Colors.white70)),
              if (detail['daily_calories'] != null)
                Text('${detail['daily_calories']} kcal/día', style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Comidas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              if (meals.isEmpty)
                const Text('Sin comidas registradas.', style: TextStyle(color: Colors.white54))
              else
                ...meals.map((m) => _mealRow(m)),
              const SizedBox(height: 20),
              const Text('Asignaciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              if (assignments.isEmpty)
                const Text('Sin asignaciones.', style: TextStyle(color: Colors.white54))
              else
                ...assignments.map((a) => _assignmentRow(a)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    } catch (e) {
      _snack('Error al cargar detalle: $e');
    }
  }

  Widget _mealRow(Map<String, dynamic> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu_outlined, color: Colors.white38, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['name']?.toString() ?? 'Comida', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(m['meal_type']?.toString() ?? '', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          if (m['calories'] != null)
            Text('${m['calories']} kcal', style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _assignmentRow(Map<String, dynamic> a) {
    final clientName = a['client']?['name']?.toString() ?? 'Cliente';
    final status = a['status']?.toString() ?? 'active';
    final statusColor = status == 'active' ? AppColors.neonGreen
        : status == 'completed' ? AppColors.electricPurple
        : AppColors.coralOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.neonGreen.withValues(alpha: 0.15),
            child: Text(
              clientName.isNotEmpty ? clientName[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(clientName, style: const TextStyle(color: Colors.white)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(Map<String, dynamic> plan, bool value) async {
    // Actualización optimista: el switch se mueve al instante.
    setState(() {
      _plans = _plans.map((p) {
        if (p['id'] == plan['id']) return {...p, 'is_active': value};
        return p;
      }).toList();
    });

    try {
      await NutriologoApi.updatePlan(planId: plan['id'] as int, isActive: value);
    } catch (e) {
      // Revertir si la API falla.
      if (mounted) {
        setState(() {
          _plans = _plans.map((p) {
            if (p['id'] == plan['id']) return {...p, 'is_active': !value};
            return p;
          }).toList();
        });
        _snack('Error al actualizar: $e');
      }
    }
  }

  bool _isPlanActive(Map<String, dynamic> plan) {
    final raw = plan['is_active'];
    if (raw is bool) return raw;
    if (raw is num) return raw == 1;
    if (raw is String) return raw == '1' || raw.toLowerCase() == 'true';
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Planes Nutricionales',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _createPlanDialog,
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo plan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar plan...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (!_isLoading)
              Text(
                '$_total plan${_total != 1 ? 'es' : ''}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),

            const SizedBox(height: 8),

            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : RefreshIndicator(
                      onRefresh: () => _load(reset: true),
                      color: AppColors.neonGreen,
                      child: _plans.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.restaurant_menu_outlined,
                                      color: Colors.white24, size: 48),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No hay planes todavía.',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: _createPlanDialog,
                                    style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.neonGreen,
                                        foregroundColor: Colors.black),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Crear primer plan'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _plans.length + (_hasMore ? 1 : 0),
                              itemBuilder: (_, index) {
                                if (index == _plans.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: TextButton.icon(
                                      onPressed: _loadingMore ? null : () => _load(reset: false),
                                      icon: const Icon(Icons.expand_more, color: AppColors.neonGreen),
                                      label: Text(
                                        _loadingMore ? 'Cargando...' : 'Mostrar más',
                                        style: const TextStyle(color: AppColors.neonGreen),
                                      ),
                                    ),
                                  );
                                }
                                return _planCard(_plans[index]);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SkeletonBox(height: 120, width: double.infinity),
        ),
      ),
    );
  }

  Widget _planCard(Map<String, dynamic> plan) {
    final planId = plan['id'] as int;
    final isActive = _isPlanActive(plan);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(
            color: isActive ? AppColors.neonGreen : Colors.white12,
            width: 3,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan['title']?.toString() ?? 'Sin título',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: isActive,
                  activeThumbColor: AppColors.neonGreen,
                  activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.4),
                  onChanged: (v) => _toggleActive(plan, v),
                ),
              ],
            ),

            if (plan['goal'] != null && plan['goal'].toString().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                plan['goal'].toString(),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],

            const SizedBox(height: 8),

            // Meta row
            Row(
              children: [
                _chip(Icons.restaurant_menu_outlined,
                    '${plan['meals_count'] ?? 0} comidas'),
                const SizedBox(width: 8),
                _chip(Icons.people_outlined,
                    '${plan['assignments_count'] ?? 0} asig.'),
                if (plan['daily_calories'] != null) ...[
                  const SizedBox(width: 8),
                  _chip(Icons.local_fire_department_outlined,
                      '${plan['daily_calories']} kcal',
                      color: AppColors.coralOrange),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Actions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _actionBtn(Icons.visibility_outlined, 'Ver', () => _viewPlanDetail(planId)),
                  const SizedBox(width: 8),
                  _actionBtn(Icons.person_add_outlined, 'Asignar', () => _assignPlanDialog(planId)),
                  const SizedBox(width: 8),
                  _actionBtn(Icons.edit_outlined, 'Editar', () => _editPlanDialog(plan)),
                  const SizedBox(width: 8),
                  _actionBtn(Icons.delete_outline, 'Eliminar',
                      () => _deletePlanDialog(plan),
                      color: AppColors.coralOrange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, {Color color = Colors.white38}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap,
      {Color color = Colors.white70}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF121212),
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
