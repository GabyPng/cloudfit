import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/services/nutrition_service.dart';
import 'models/nutrition_model.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class NutritionScreen extends StatefulWidget {
  static const String name = 'nutrition_screen';
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const _weeklyKcal = [2100.0, 2450.0, 1980.0, 2320.0, 1840.0, 0.0, 0.0];
  static const _todayIndex = 4;
  static const _waterConsumed = 6;
  static const _waterTarget = 8;

  late Future<NutritionPlanModel?> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture = NutritionService.getAssignedPlan();
  }

  void _refresh() => setState(() {
        _planFuture = NutritionService.getAssignedPlan();
      });

  static IconData _iconForType(String type) {
    switch (type) {
      case 'desayuno':
        return Icons.wb_sunny_rounded;
      case 'colacion_1':
        return Icons.egg_rounded;
      case 'comida':
        return Icons.lunch_dining_rounded;
      case 'colacion_2':
        return Icons.sports_score_rounded;
      case 'cena':
        return Icons.dinner_dining_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  static Color _colorForType(String type) {
    switch (type) {
      case 'desayuno':
        return AppColors.coralOrange;
      case 'colacion_1':
        return AppColors.neonGreen;
      case 'comida':
        return AppColors.electricPurple;
      case 'colacion_2':
        return const Color(0xFF4DD0E1);
      case 'cena':
        return const Color(0xFF6366F1);
      default:
        return Colors.white54;
    }
  }

  void _showMealDetail(BuildContext context, MealModel meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MealDetailSheet(
        meal: meal,
        color: _colorForType(meal.mealType),
        icon: _iconForType(meal.mealType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<NutritionPlanModel?>(
        future: _planFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }
          final plan = snapshot.data;
          if (plan == null) return _buildEmpty();
          return _buildContent(plan);
        },
      ),
    );
  }

  // ── States ─────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Nutrición', ''),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.electricPurple),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Nutrición', ''),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.coralOrange, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error al cargar el plan',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(message,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Nutrición', ''),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.restaurant_menu_rounded,
                        color: Colors.white24, size: 36),
                  ),
                  const SizedBox(height: 20),
                  const Text('Sin plan nutricional',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu nutriólogo aún no te ha asignado un plan nutricional.',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Main content ───────────────────────────────────────────────────────────

  Widget _buildContent(NutritionPlanModel plan) {
    final calorieTarget = plan.effectiveDailyCalories;
    final calorieSum = plan.totalCaloriesFromMeals;
    final calPct =
        calorieTarget > 0 ? (calorieSum / calorieTarget).clamp(0.0, 1.0) : 0.0;
    final remaining = calorieTarget - calorieSum;

    final subtitleParts = [
      plan.title,
      if (plan.goal != null && plan.goal!.isNotEmpty) plan.goal!,
    ];

    return CustomScrollView(
      slivers: [
        _buildAppBar('Nutrición', subtitleParts.join(' · ')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildCalorieCard(calPct, calorieSum, calorieTarget, remaining),
              const SizedBox(height: 14),
              _buildMacrosCard(plan),
              const SizedBox(height: 14),
              _buildWeeklyChart(),
              const SizedBox(height: 14),
              _buildWaterCard(),
              const SizedBox(height: 24),
              const Text('Comidas del Plan',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...plan.meals.map((m) => _buildMealCard(context, m)),
            ]),
          ),
        ),
      ],
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar(String title, String subtitle) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      expandedHeight: 90,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white)),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                  overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ── Calorie ring card ──────────────────────────────────────────────────────

  Widget _buildCalorieCard(
      double calPct, int calorieSum, int calorieTarget, int remaining) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1B4B),
            AppColors.background.withValues(alpha: 0.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.electricPurple.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _RingPainter(
                    progress: calPct,
                    color: AppColors.electricPurple,
                    bgColor: Colors.white10,
                    strokeWidth: 13,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$calorieSum',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22)),
                    const Text('kcal',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _calRow('Meta diaria', '$calorieTarget kcal', Colors.white54),
                const SizedBox(height: 11),
                _calRow(
                    'Plan total', '$calorieSum kcal', AppColors.electricPurple),
                const SizedBox(height: 11),
                _calRow(
                  remaining >= 0 ? 'Disponibles' : 'Excedente',
                  '${remaining.abs()} kcal',
                  remaining >= 0 ? AppColors.neonGreen : AppColors.coralOrange,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: calPct,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.electricPurple),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${(calPct * 100).toInt()}% de la meta',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ── Macros card ────────────────────────────────────────────────────────────

  Widget _buildMacrosCard(NutritionPlanModel plan) {
    final macros = [
      _MacroData('Proteínas', plan.totalProtein, AppColors.electricPurple),
      _MacroData('Carbohidratos', plan.totalCarbs, AppColors.neonGreen),
      _MacroData('Grasas', plan.totalFats, AppColors.coralOrange),
    ];
    final total = plan.totalProtein + plan.totalCarbs + plan.totalFats;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Macronutrientes',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...macros.map((m) => _macroBar(m, total)),
        ],
      ),
    );
  }

  Widget _macroBar(_MacroData m, int total) {
    final pct = total > 0 ? (m.grams / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: m.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(m.name,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
              Text('${m.grams}g',
                  style: TextStyle(
                      color: m.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 9,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(m.color),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${(pct * 100).toInt()}%',
                style: TextStyle(
                    color: m.color.withValues(alpha: 0.7), fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // ── Weekly bar chart ───────────────────────────────────────────────────────

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calorías Semanales',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              Text('Esta semana',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                maxY: 3000,
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.cardGrey,
                    getTooltipItem: (group, _, rod, _) {
                      if (rod.toY == 0) return null;
                      return BarTooltipItem(
                        '${rod.toY.toInt()} kcal',
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= _weekdays.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _weekdays[i],
                            style: TextStyle(
                              fontSize: 11,
                              color: i == _todayIndex
                                  ? AppColors.neonGreen
                                  : Colors.white38,
                              fontWeight: i == _todayIndex
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_weeklyKcal.length, (i) {
                  final isToday = i == _todayIndex;
                  final val = _weeklyKcal[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val == 0 ? 1 : val,
                        width: 26,
                        borderRadius: BorderRadius.circular(7),
                        color: val == 0
                            ? Colors.white10
                            : isToday
                                ? AppColors.neonGreen
                                : AppColors.electricPurple
                                    .withValues(alpha: 0.60),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 3000,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Water tracker ──────────────────────────────────────────────────────────

  Widget _buildWaterCard() {
    const waterColor = Color(0xFF4DD0E1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: waterColor.withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: waterColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.water_drop_rounded, color: waterColor, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hidratación',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text('$_waterConsumed de $_waterTarget vasos',
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Row(
            children: List.generate(
              _waterTarget,
              (i) => Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Icon(
                  i < _waterConsumed
                      ? Icons.water_drop_rounded
                      : Icons.water_drop_outlined,
                  color: i < _waterConsumed ? waterColor : Colors.white12,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Meal card ──────────────────────────────────────────────────────────────

  Widget _buildMealCard(BuildContext context, MealModel meal) {
    final color = _colorForType(meal.mealType);
    final icon = _iconForType(meal.mealType);
    return GestureDetector(
      onTap: () => _showMealDetail(context, meal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    meal.description.isNotEmpty
                        ? meal.description
                        : (meal.portion ?? ''),
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 7),
                  Row(children: [
                    _pill('P: ${meal.protein}g', AppColors.electricPurple),
                    const SizedBox(width: 5),
                    _pill('C: ${meal.carbs}g', AppColors.neonGreen),
                    const SizedBox(width: 5),
                    _pill('G: ${meal.fats}g', AppColors.coralOrange),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${meal.caloriesInt}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 17)),
                const Text('kcal',
                    style: TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(height: 10),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white24, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Internal macro display data ───────────────────────────────────────────────

class _MacroData {
  final String name;
  final int grams;
  final Color color;
  const _MacroData(this.name, this.grams, this.color);
}

// ── Ring painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    if (progress <= 0) return;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Meal detail bottom sheet ──────────────────────────────────────────────────

class _MealDetailSheet extends StatelessWidget {
  final MealModel meal;
  final Color color;
  final IconData icon;

  const _MealDetailSheet({
    required this.meal,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final totalG = meal.protein + meal.carbs + meal.fats;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      if (meal.description.isNotEmpty)
                        Text(meal.description,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.30)),
                  ),
                  child: Column(
                    children: [
                      Text('${meal.caloriesInt}',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 20)),
                      const Text('kcal',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Portion
            if (meal.portion != null && meal.portion!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.scale_rounded,
                      color: Colors.white38, size: 14),
                  const SizedBox(width: 6),
                  Text(meal.portion!,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13, height: 1.5)),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Notes
            if (meal.notes != null && meal.notes!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(meal.notes!,
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              height: 1.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Macros
            const Text('Macronutrientes',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _sheetMacroRow(
                'Proteínas', meal.protein, totalG, AppColors.electricPurple),
            const SizedBox(height: 12),
            _sheetMacroRow(
                'Carbohidratos', meal.carbs, totalG, AppColors.neonGreen),
            const SizedBox(height: 12),
            _sheetMacroRow('Grasas', meal.fats, totalG, AppColors.coralOrange),
          ],
        ),
      ),
    );
  }

  Widget _sheetMacroRow(String name, int amount, int total, Color color) {
    final pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 13)),
            Text('${amount}g · ${(pct * 100).toInt()}%',
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
