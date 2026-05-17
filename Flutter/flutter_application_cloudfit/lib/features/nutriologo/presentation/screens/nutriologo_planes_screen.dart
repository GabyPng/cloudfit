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

  static const _mealTypes = {
    'desayuno': 'Desayuno',
    'colacion_1': 'Colación 1',
    'comida': 'Comida',
    'colacion_2': 'Colación 2',
    'cena': 'Cena',
  };

  Future<void> _manageMealsSheet(Map<String, dynamic> plan) async {
    final planId = plan['id'] as int;

    List<Map<String, dynamic>> meals = [];
    try {
      final detail = await NutriologoApi.getPlanDetail(planId);
      meals = (detail['meals'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      // Keep only editable fields
      meals = meals.map((m) => {
        'meal_type': m['meal_type'] ?? 'desayuno',
        'name': m['name'] ?? '',
        'portion': m['portion'] ?? '',
        'calories': m['calories'],
        'protein_g': m['protein_g'],
        'carbs_g': m['carbs_g'],
        'fat_g': m['fat_g'],
        'notes': m['notes'] ?? '',
      }).toList();
    } catch (e) {
      _snack('Error al cargar comidas: $e');
      return;
    }

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void addMealDialog() async {
            String mealType = 'desayuno';
            final nameCtrl = TextEditingController();
            final portionCtrl = TextEditingController();
            final calCtrl = TextEditingController();
            final protCtrl = TextEditingController();
            final carbCtrl = TextEditingController();
            final fatCtrl = TextEditingController();
            final notesCtrl = TextEditingController();

            await showDialog<void>(
              context: ctx,
              builder: (dCtx) => StatefulBuilder(
                builder: (dCtx, setDlg) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Agregar comida', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: mealType,
                          dropdownColor: const Color(0xFF1A1A1A),
                          decoration: const InputDecoration(labelText: 'Tipo', labelStyle: TextStyle(color: Colors.white70)),
                          style: const TextStyle(color: Colors.white),
                          items: _mealTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                          onChanged: (v) { if (v != null) setDlg(() => mealType = v); },
                        ),
                        const SizedBox(height: 10),
                        _input(controller: nameCtrl, label: 'Nombre *'),
                        const SizedBox(height: 8),
                        _input(controller: portionCtrl, label: 'Porción (ej. 1 taza)'),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: _input(controller: calCtrl, label: 'Calorías', keyboardType: TextInputType.number)),
                          const SizedBox(width: 8),
                          Expanded(child: _input(controller: protCtrl, label: 'Prot (g)', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: _input(controller: carbCtrl, label: 'Carbs (g)', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                          const SizedBox(width: 8),
                          Expanded(child: _input(controller: fatCtrl, label: 'Grasa (g)', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                        ]),
                        const SizedBox(height: 8),
                        _input(controller: notesCtrl, label: 'Notas'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        setSheet(() {
                          meals.add({
                            'meal_type': mealType,
                            'name': nameCtrl.text.trim(),
                            'portion': portionCtrl.text.trim(),
                            'calories': int.tryParse(calCtrl.text.trim()),
                            'protein_g': double.tryParse(protCtrl.text.trim()),
                            'carbs_g': double.tryParse(carbCtrl.text.trim()),
                            'fat_g': double.tryParse(fatCtrl.text.trim()),
                            'notes': notesCtrl.text.trim(),
                          });
                        });
                        Navigator.pop(dCtx);
                      },
                      child: const Text('Agregar'),
                    ),
                  ],
                ),
              ),
            );

            nameCtrl.dispose(); portionCtrl.dispose(); calCtrl.dispose();
            protCtrl.dispose(); carbCtrl.dispose(); fatCtrl.dispose(); notesCtrl.dispose();
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            builder: (_, sc) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 36, height: 4,
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Comidas — ${plan['title'] ?? ''}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: addMealDialog,
                            icon: const Icon(Icons.add, color: AppColors.neonGreen, size: 16),
                            label: const Text('Agregar', style: TextStyle(color: AppColors.neonGreen, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: meals.isEmpty
                      ? const Center(
                          child: Text('Sin comidas. Toca "Agregar" para añadir.',
                              style: TextStyle(color: Colors.white38)),
                        )
                      : ListView.builder(
                          controller: sc,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: meals.length,
                          itemBuilder: (_, i) {
                            final m = meals[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _mealTypes[m['meal_type']] ?? m['meal_type']?.toString() ?? '',
                                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                                        ),
                                        Text(
                                          m['name']?.toString() ?? '',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                        if ((m['portion'] as String?)?.isNotEmpty ?? false)
                                          Text(m['portion'].toString(), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                        const SizedBox(height: 4),
                                        Wrap(spacing: 6, children: [
                                          if (m['calories'] != null) _mealChip('${m['calories']} kcal', AppColors.neonGreen),
                                          if (m['protein_g'] != null) _mealChip('P:${m['protein_g']}g', AppColors.electricPurple),
                                          if (m['carbs_g'] != null) _mealChip('C:${m['carbs_g']}g', const Color(0xFFFFBB00)),
                                          if (m['fat_g'] != null) _mealChip('G:${m['fat_g']}g', AppColors.coralOrange),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.coralOrange, size: 18),
                                    onPressed: () => setSheet(() => meals.removeAt(i)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(ctx).padding.bottom + 16),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        final cleanMeals = meals.map((m) {
                          final clean = Map<String, dynamic>.from(m);
                          clean.removeWhere((k, v) => v == null || (v is String && v.isEmpty));
                          return clean;
                        }).toList();
                        await NutriologoApi.updatePlan(planId: planId, meals: cleanMeals);
                        _snack('Comidas actualizadas correctamente.');
                        await _load(reset: true);
                      } catch (e) {
                        _snack('Error al guardar: $e');
                      }
                    },
                    child: Text(
                      'Guardar ${meals.length} comida${meals.length != 1 ? 's' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _mealChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _createPlanDialog,
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo plan',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: _AboveNavbarFabLocation(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar plan...',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Colors.white38, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: AppColors.neonGreen, width: 1.5),
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
                              padding: const EdgeInsets.only(bottom: 110),
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
    final accentColor = isActive ? AppColors.neonGreen : Colors.white24;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.neonGreen.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent stripe
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive
                    ? [AppColors.neonGreen, AppColors.neonGreen.withValues(alpha: 0.3)]
                    : [Colors.white12, Colors.transparent],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + switch
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['title']?.toString() ?? 'Sin título',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (plan['goal'] != null &&
                              plan['goal'].toString().isNotEmpty)
                            Text(
                              plan['goal'].toString(),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch.adaptive(
                        value: isActive,
                        activeThumbColor: Colors.black,
                        activeTrackColor: AppColors.neonGreen,
                        inactiveThumbColor: Colors.white38,
                        inactiveTrackColor: Colors.white12,
                        onChanged: (v) => _toggleActive(plan, v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Meta chips
                Row(
                  children: [
                    _chip(Icons.restaurant_menu_rounded,
                        '${plan['meals_count'] ?? 0} comidas'),
                    const SizedBox(width: 8),
                    _chip(Icons.people_rounded,
                        '${plan['assignments_count'] ?? 0} asig.'),
                    if (plan['daily_calories'] != null) ...[
                      const SizedBox(width: 8),
                      _chip(Icons.local_fire_department_rounded,
                          '${plan['daily_calories']} kcal',
                          color: AppColors.coralOrange),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _actionBtn(Icons.visibility_rounded, 'Ver',
                          () => _viewPlanDetail(planId)),
                      const SizedBox(width: 6),
                      _actionBtn(Icons.restaurant_menu_rounded, 'Comidas',
                          () => _manageMealsSheet(plan),
                          color: AppColors.electricPurple),
                      const SizedBox(width: 6),
                      _actionBtn(Icons.person_add_rounded, 'Asignar',
                          () => _assignPlanDialog(planId)),
                      const SizedBox(width: 6),
                      _actionBtn(Icons.edit_rounded, 'Editar',
                          () => _editPlanDialog(plan)),
                      const SizedBox(width: 6),
                      _actionBtn(Icons.delete_rounded, 'Eliminar',
                          () => _deletePlanDialog(plan),
                          color: AppColors.coralOrange),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

// Positions FAB just above the floating bottom navbar (72px tall + 25px margin).
class _AboveNavbarFabLocation extends FloatingActionButtonLocation {
  const _AboveNavbarFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final base = FloatingActionButtonLocation.endFloat.getOffset(scaffoldGeometry);
    // endFloat puts FAB bottom 16px from scaffold edge.
    // Navbar occupies bottom ~97px, add 8px clearance → shift up 89px.
    return Offset(base.dx, base.dy - 89);
  }
}
