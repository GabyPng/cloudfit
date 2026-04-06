import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth_service.dart';
import '../../../nutriologo/data/nutriologo_api.dart';

class NutriologoDashboardScreen extends StatefulWidget {
  const NutriologoDashboardScreen({super.key});

  @override
  State<NutriologoDashboardScreen> createState() =>
      _NutriologoDashboardScreenState();
}

class _NutriologoDashboardScreenState extends State<NutriologoDashboardScreen> {
  static const int _pageSize = 8;

  bool _loading = true;
  bool _creatingPlan = false;
  bool _loadingMoreClients = false;
  bool _loadingMorePlans = false;
  String? _error;

  Map<String, dynamic> _dashboard = {};
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _plans = [];

  int _clientsPage = 1;
  int _plansPage = 1;
  int _clientsTotal = 0;
  int _plansTotal = 0;
  bool _clientsHasMore = false;
  bool _plansHasMore = false;

  String _clientsQuery = '';
  String _plansQuery = '';
  Timer? _clientsSearchDebounce;
  Timer? _plansSearchDebounce;

  final _clientsSearchCtrl = TextEditingController();
  final _plansSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _clientsSearchDebounce?.cancel();
    _plansSearchDebounce?.cancel();
    _clientsSearchCtrl.dispose();
    _plansSearchCtrl.dispose();
    super.dispose();
  }

  void _onClientsSearchChanged(String value) {
    _clientsSearchDebounce?.cancel();
    _clientsSearchDebounce = Timer(const Duration(milliseconds: 300), () async {
      _clientsQuery = value;
      await _loadClients(reset: true);
    });
  }

  void _onPlansSearchChanged(String value) {
    _plansSearchDebounce?.cancel();
    _plansSearchDebounce = Timer(const Duration(milliseconds: 300), () async {
      _plansQuery = value;
      await _loadPlans(reset: true);
    });
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dashboard = await NutriologoApi.getDashboard();
      await Future.wait([_loadClients(reset: true), _loadPlans(reset: true)]);

      setState(() {
        _dashboard = dashboard;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadClients({required bool reset}) async {
    final targetPage = reset ? 1 : _clientsPage + 1;
    if (!reset) {
      setState(() => _loadingMoreClients = true);
    }

    try {
      final response = await NutriologoApi.getClientsPage(
        search: _clientsQuery,
        page: targetPage,
        perPage: _pageSize,
      );

      final data = (response['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final meta = response['meta'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        _clients = reset ? data : [..._clients, ...data];
        _clientsPage = (meta['current_page'] as num?)?.toInt() ?? targetPage;
        _clientsTotal = (meta['total'] as num?)?.toInt() ?? _clients.length;
        _clientsHasMore = meta['has_more'] == true;
      });
    } finally {
      if (!reset && mounted) {
        setState(() => _loadingMoreClients = false);
      }
    }
  }

  Future<void> _loadPlans({required bool reset}) async {
    final targetPage = reset ? 1 : _plansPage + 1;
    if (!reset) {
      setState(() => _loadingMorePlans = true);
    }

    try {
      final response = await NutriologoApi.getPlansPage(
        search: _plansQuery,
        page: targetPage,
        perPage: _pageSize,
      );

      final data = (response['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final meta = response['meta'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        _plans = reset ? data : [..._plans, ...data];
        _plansPage = (meta['current_page'] as num?)?.toInt() ?? targetPage;
        _plansTotal = (meta['total'] as num?)?.toInt() ?? _plans.length;
        _plansHasMore = meta['has_more'] == true;
      });
    } finally {
      if (!reset && mounted) {
        setState(() => _loadingMorePlans = false);
      }
    }
  }

  Future<void> _createPlanDialog() async {
    final titleCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Nuevo plan nutricional',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _darkInput(controller: titleCtrl, label: 'Titulo *'),
            const SizedBox(height: 10),
            _darkInput(controller: goalCtrl, label: 'Objetivo'),
            const SizedBox(height: 10),
            _darkInput(
              controller: caloriesCtrl,
              label: 'Calorias diarias',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(dialogContext);

              setState(() => _creatingPlan = true);
              try {
                await NutriologoApi.createPlan(
                  title: titleCtrl.text.trim(),
                  goal: goalCtrl.text.trim(),
                  dailyCalories: int.tryParse(caloriesCtrl.text.trim()),
                );

                _showSnack('Plan creado correctamente.');
                await _loadPlans(reset: true);
                await _loadDashboardStats();
              } catch (e) {
                _showSnack('Error al crear plan: $e');
              } finally {
                if (mounted) {
                  setState(() => _creatingPlan = false);
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignPlanDialog(int planId) async {
    if (_clients.isEmpty) {
      _showSnack('No hay clientes cargados. Usa buscar o mostrar mas.');
      return;
    }

    int selectedClientId = _clients.first['id'] as int;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Asignar plan',
          style: TextStyle(color: Colors.white),
        ),
        content: DropdownButtonFormField<int>(
          initialValue: selectedClientId,
          dropdownColor: const Color(0xFF1A1A1A),
          decoration: const InputDecoration(
            labelText: 'Cliente',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          items: _clients
              .map(
                (client) => DropdownMenuItem<int>(
                  value: client['id'] as int,
                  child: Text(client['name']?.toString() ?? 'Sin nombre'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            selectedClientId = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await NutriologoApi.assignPlan(
                  planId: planId,
                  clientId: selectedClientId,
                );
                _showSnack('Plan asignado correctamente.');
                await _loadPlans(reset: true);
                await _loadDashboardStats();
              } catch (e) {
                _showSnack('Error al asignar plan: $e');
              }
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editPlanDialog(Map<String, dynamic> plan) async {
    final titleCtrl = TextEditingController(
      text: plan['title']?.toString() ?? '',
    );
    final goalCtrl = TextEditingController(
      text: plan['goal']?.toString() ?? '',
    );
    final caloriesCtrl = TextEditingController(
      text: plan['daily_calories']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Editar plan', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _darkInput(controller: titleCtrl, label: 'Titulo *'),
            const SizedBox(height: 10),
            _darkInput(controller: goalCtrl, label: 'Objetivo'),
            const SizedBox(height: 10),
            _darkInput(
              controller: caloriesCtrl,
              label: 'Calorias diarias',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(dialogContext);

              try {
                await NutriologoApi.updatePlan(
                  planId: plan['id'] as int,
                  title: titleCtrl.text.trim(),
                  goal: goalCtrl.text.trim(),
                  dailyCalories: int.tryParse(caloriesCtrl.text.trim()),
                );
                _showSnack('Plan actualizado correctamente.');
                await _loadPlans(reset: true);
              } catch (e) {
                _showSnack('Error al actualizar plan: $e');
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
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Eliminar plan',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Se eliminara "${plan['title'] ?? 'este plan'}" y sus asignaciones. Esta accion no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await NutriologoApi.deletePlan(plan['id'] as int);
      _showSnack('Plan eliminado correctamente.');
      await _loadPlans(reset: true);
      await _loadDashboardStats();
    } catch (e) {
      _showSnack('Error al eliminar plan: $e');
    }
  }

  Future<void> _manageAssignments(int planId) async {
    try {
      final detail = await NutriologoApi.getPlanDetail(planId);
      final assignments = (detail['assignments'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      if (!mounted) return;
      if (assignments.isEmpty) {
        _showSnack('Este plan aun no tiene asignaciones.');
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF121212),
        isScrollControlled: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asignaciones del plan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              ...assignments.map(
                (assignment) => Card(
                  color: const Color(0xFF1E1E1E),
                  child: ListTile(
                    title: Text(
                      assignment['client']?['name']?.toString() ?? 'Cliente',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Estado: ${assignment['status']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: PopupMenuButton<String>(
                      iconColor: Colors.white70,
                      onSelected: (status) async {
                        Navigator.of(context).pop();
                        try {
                          await NutriologoApi.updateAssignmentStatus(
                            assignmentId: assignment['id'] as int,
                            status: status,
                          );
                          await _loadDashboardStats();
                          _showSnack('Estado actualizado correctamente.');
                        } catch (e) {
                          _showSnack('Error al actualizar: $e');
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'active', child: Text('active')),
                        PopupMenuItem(value: 'paused', child: Text('paused')),
                        PopupMenuItem(
                          value: 'completed',
                          child: Text('completed'),
                        ),
                        PopupMenuItem(
                          value: 'cancelled',
                          child: Text('cancelled'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _showSnack('Error al cargar asignaciones: $e');
    }
  }

  Future<void> _viewPlanDetail(int planId) async {
    try {
      final detail = await NutriologoApi.getPlanDetail(planId);
      final meals = (detail['meals'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final assignments = (detail['assignments'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF121212),
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.45,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                detail['title']?.toString() ?? 'Plan nutricional',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Objetivo: ${detail['goal'] ?? 'Sin objetivo'}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Calorias: ${detail['daily_calories'] ?? 'N/A'}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              const Text(
                'Comidas',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (meals.isEmpty)
                const Text(
                  'Este plan no tiene comidas registradas.',
                  style: TextStyle(color: Colors.white60),
                )
              else
                ...meals.map(
                  (meal) => Card(
                    color: const Color(0xFF1E1E1E),
                    child: ListTile(
                      title: Text(
                        meal['name']?.toString() ?? 'Comida',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${meal['meal_type'] ?? 'tipo'} | ${meal['calories'] ?? '-'} kcal',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              const Text(
                'Asignaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (assignments.isEmpty)
                const Text(
                  'Este plan no tiene asignaciones.',
                  style: TextStyle(color: Colors.white60),
                )
              else
                ...assignments.map(
                  (assignment) => Card(
                    color: const Color(0xFF1E1E1E),
                    child: ListTile(
                      title: Text(
                        assignment['client']?['name']?.toString() ?? 'Cliente',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Estado: ${assignment['status']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      _showSnack('Error al cargar detalle: $e');
    }
  }

  Future<void> _togglePlanActive(
    Map<String, dynamic> plan,
    bool newValue,
  ) async {
    final planId = plan['id'] as int;

    try {
      await NutriologoApi.updatePlan(planId: planId, isActive: newValue);
      setState(() {
        _plans = _plans.map((item) {
          if (item['id'] == planId) {
            return {...item, 'is_active': newValue};
          }
          return item;
        }).toList();
      });
      _showSnack(newValue ? 'Plan activado.' : 'Plan desactivado.');
    } catch (e) {
      _showSnack('Error al cambiar estado del plan: $e');
    }
  }

  bool _isPlanActive(Map<String, dynamic> plan) {
    final raw = plan['is_active'];
    if (raw is bool) return raw;
    if (raw is num) return raw == 1;
    if (raw is String) return raw == '1' || raw.toLowerCase() == 'true';
    return true;
  }

  Future<void> _loadDashboardStats() async {
    try {
      final dashboard = await NutriologoApi.getDashboard();
      if (!mounted) return;
      setState(() => _dashboard = dashboard);
    } catch (_) {
      // Keep UI usable if stats refresh fails.
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Panel Nutriologo',
          style: TextStyle(
            color: Color(0xFF10B981),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final router = GoRouter.of(context);
              await AuthService.logout();
              if (!mounted) return;
              router.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _creatingPlan ? null : _createPlanDialog,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo plan'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _statsCard(),
                  const SizedBox(height: 16),
                  _sectionTitle('Clientes asignados ($_clientsTotal)'),
                  const SizedBox(height: 8),
                  _searchField(
                    controller: _clientsSearchCtrl,
                    hint: 'Buscar cliente por nombre o correo',
                    onChanged: _onClientsSearchChanged,
                  ),
                  const SizedBox(height: 8),
                  if (_clients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No hay clientes que coincidan con la busqueda.',
                        style: TextStyle(color: Colors.white60),
                      ),
                    )
                  else
                    ..._clients.map(
                      (client) => Card(
                        color: const Color(0xFF1E1E1E),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2A2A2A),
                            child: Text(
                              (client['name']?.toString().isNotEmpty ?? false)
                                  ? client['name']
                                        .toString()
                                        .substring(0, 1)
                                        .toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(
                            client['name']?.toString() ?? 'Sin nombre',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            client['email']?.toString() ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  if (_clientsHasMore)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _loadingMoreClients
                            ? null
                            : () async {
                                await _loadClients(reset: false);
                              },
                        icon: const Icon(Icons.expand_more),
                        label: Text(
                          _loadingMoreClients
                              ? 'Cargando...'
                              : 'Mostrar mas clientes',
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _sectionTitle('Planes nutricionales ($_plansTotal)'),
                  const SizedBox(height: 8),
                  _searchField(
                    controller: _plansSearchCtrl,
                    hint: 'Buscar plan por titulo u objetivo',
                    onChanged: _onPlansSearchChanged,
                  ),
                  const SizedBox(height: 8),
                  if (_plans.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No hay planes que coincidan con la busqueda.',
                        style: TextStyle(color: Colors.white60),
                      ),
                    )
                  else
                    ..._plans.map((plan) {
                      final planId = plan['id'] as int;
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan['title']?.toString() ?? 'Sin titulo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Comidas: ${plan['meals_count'] ?? 0}  |  Asignaciones: ${plan['assignments_count'] ?? 0}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Activo',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch.adaptive(
                                    value: _isPlanActive(plan),
                                    activeThumbColor: const Color(0xFF10B981),
                                    onChanged: (value) =>
                                        _togglePlanActive(plan, value),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _viewPlanDetail(planId),
                                    child: const Text('Ver detalle'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _assignPlanDialog(planId),
                                    child: const Text('Asignar'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _manageAssignments(planId),
                                    child: const Text('Estados'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _editPlanDialog(plan),
                                    child: const Text('Editar'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _deletePlanDialog(plan),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                    ),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  if (_plansHasMore)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _loadingMorePlans
                            ? null
                            : () async {
                                await _loadPlans(reset: false);
                              },
                        icon: const Icon(Icons.expand_more),
                        label: Text(
                          _loadingMorePlans
                              ? 'Cargando...'
                              : 'Mostrar mas planes',
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _statsCard() {
    final stats = _dashboard['stats'] as Map<String, dynamic>? ?? {};

    Widget metric(String label, dynamic value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            children: [
              Text(
                '${value ?? 0}',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        metric('Clientes', stats['clientes_asignados']),
        const SizedBox(width: 8),
        metric('Planes', stats['planes_totales']),
        const SizedBox(width: 8),
        metric('Activos', stats['asignaciones_activas']),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _darkInput({
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
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
      ),
    );
  }

  Widget _searchField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
      ),
    );
  }
}
