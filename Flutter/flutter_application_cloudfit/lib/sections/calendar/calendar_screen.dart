import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/auth_service.dart';
import '../../../../core/constants.dart';

class CalendarScreen extends StatefulWidget {
  static const String name = 'calendar_screen';
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  static const _dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  late DateTime _month;
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final clientId = await AuthService.getNumericUserId();
    if (clientId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final start = '${_month.year}-${_month.month.toString().padLeft(2, '0')}-01';
    final nextMonth = DateTime(_month.year, _month.month + 1);
    final end = '${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-01';

    final rows = await Supabase.instance.client
        .from('workout_logs')
        .select('date, routine_id, routines(name)')
        .eq('client_id', clientId)
        .eq('is_complete', true)
        .gte('date', start)
        .lt('date', end)
        .order('date', ascending: false);

    if (mounted) {
      setState(() {
        _logs = List<Map<String, dynamic>>.from(rows as List);
        _loading = false;
      });
    }
  }

  void _prevMonth() {
    setState(() => _month = DateTime(_month.year, _month.month - 1));
    _load();
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_month.year == now.year && _month.month == now.month) return;
    setState(() => _month = DateTime(_month.year, _month.month + 1));
    _load();
  }

  Set<int> get _workoutDays {
    final days = <int>{};
    for (final log in _logs) {
      final d = DateTime.tryParse(log['date'] as String? ?? '');
      if (d != null) days.add(d.day);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Mi Actividad',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 20),
          _buildCalendarGrid(),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: AppColors.cardGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Sesiones del mes',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const Spacer(),
                      if (!_loading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${_logs.length}',
                              style: const TextStyle(
                                  color: AppColors.neonGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildHistoryList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final isCurrentMonth =
        _month.year == now.year && _month.month == now.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_monthNames[_month.month - 1]} ${_month.year}',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: _prevMonth,
              ),
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: isCurrentMonth ? Colors.white24 : Colors.white),
                onPressed: isCurrentMonth ? null : _nextMonth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final firstDay = _month;
    final daysInMonth =
        DateTime(_month.year, _month.month + 1, 0).day;
    // weekday of first day: Mon=1 → index 0
    final startOffset = (firstDay.weekday - 1) % 7;
    final workoutDays = _workoutDays;

    // Show a 7-column grid starting from Monday of the first week
    final cells = startOffset + daysInMonth;
    final rows = (cells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Day labels
          Row(
            children: _dayLabels
                .map((l) => Expanded(
                      child: Center(
                        child: Text(l,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(rows, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (col) {
                  final cellIndex = row * 7 + col;
                  final day = cellIndex - startOffset + 1;
                  if (day < 1 || day > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 36));
                  }
                  final isToday = _month.year == now.year &&
                      _month.month == now.month &&
                      day == now.day;
                  final hasWorkout = workoutDays.contains(day);

                  Color bgColor = Colors.transparent;
                  Color textColor = Colors.white;
                  if (isToday) {
                    bgColor = AppColors.neonGreen;
                    textColor = Colors.black;
                  } else if (hasWorkout) {
                    bgColor = AppColors.electricPurple.withValues(alpha: 0.25);
                    textColor = AppColors.electricPurple;
                  }

                  return Expanded(
                    child: Center(
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          border: (!isToday && !hasWorkout)
                              ? Border.all(color: Colors.white10)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: (isToday || hasWorkout)
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.neonGreen));
    }
    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center_rounded,
                color: Colors.white24, size: 36),
            const SizedBox(height: 12),
            const Text('Sin sesiones este mes',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        final dateStr = log['date'] as String? ?? '';
        final date = DateTime.tryParse(dateStr);
        final routineName = (log['routines'] as Map?)?['name'] as String? ??
            'Entrenamiento';
        final dayLabel = date != null
            ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
            : dateStr;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.electricPurple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fitness_center_rounded,
                    color: AppColors.electricPurple, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routineName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(dayLabel,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.neonGreen, size: 18),
            ],
          ),
        );
      },
    );
  }
}
