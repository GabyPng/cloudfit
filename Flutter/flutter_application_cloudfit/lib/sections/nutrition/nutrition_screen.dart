import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

// ── Local static models ───────────────────────────────────────────────────────

class _Macro {
  final String name;
  final int consumed;
  final int target;
  final Color color;
  const _Macro(this.name, this.consumed, this.target, this.color);
  double get pct => (consumed / target).clamp(0.0, 1.0);
}

class _MealData {
  final String title;
  final String time;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final String description;
  final List<String> ingredients;
  final IconData icon;
  final Color color;
  const _MealData({
    required this.title,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.description,
    required this.ingredients,
    required this.icon,
    required this.color,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class NutritionScreen extends StatelessWidget {
  static const String name = 'nutrition_screen';
  const NutritionScreen({super.key});

  // ── Static data ──────────────────────────────────────────────────────────
  static const _planTitle = 'Plan Definición Verano';
  static const _planGoal = 'Reducción de grasa corporal';
  static const _calorieTarget = 2500;
  static const _caloriesConsumed = 1840;
  static const _waterConsumed = 6;
  static const _waterTarget = 8;
  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const _weeklyKcal = [2100.0, 2450.0, 1980.0, 2320.0, 1840.0, 0.0, 0.0];
  static const _todayIndex = 4;

  static const _macros = [
    _Macro('Proteínas', 145, 180, AppColors.electricPurple),
    _Macro('Carbohidratos', 210, 280, AppColors.neonGreen),
    _Macro('Grasas', 58, 80, AppColors.coralOrange),
  ];

  static const _meals = [
    _MealData(
      title: 'Desayuno',
      time: '07:30',
      calories: 450,
      protein: 35,
      carbs: 55,
      fats: 12,
      description:
          'Avena con proteína, frutas y frutos secos para iniciar el día con energía sostenida.',
      ingredients: [
        '100g avena en hojuelas',
        '1 scoop proteína de vainilla',
        '1 plátano maduro',
        '30g nueces picadas',
        '200ml leche descremada',
      ],
      icon: Icons.wb_sunny_rounded,
      color: AppColors.coralOrange,
    ),
    _MealData(
      title: 'Snack Mañana',
      time: '10:00',
      calories: 180,
      protein: 20,
      carbs: 15,
      fats: 4,
      description: 'Snack alto en proteína para mantener el metabolismo activo entre comidas.',
      ingredients: [
        '2 huevos duros',
        '1 manzana verde',
        '1 pizca de sal y pimienta',
      ],
      icon: Icons.egg_rounded,
      color: AppColors.neonGreen,
    ),
    _MealData(
      title: 'Almuerzo',
      time: '13:00',
      calories: 620,
      protein: 45,
      carbs: 75,
      fats: 18,
      description:
          'Comida principal del día con proteína magra, carbohidratos complejos y vegetales frescos.',
      ingredients: [
        '200g pechuga de pollo a la plancha',
        '150g arroz integral cocido',
        '200g brócoli al vapor',
        '1 cdta aceite de oliva extra virgen',
        'Ajo, sal y especias al gusto',
      ],
      icon: Icons.lunch_dining_rounded,
      color: AppColors.electricPurple,
    ),
    _MealData(
      title: 'Merienda',
      time: '16:30',
      calories: 220,
      protein: 18,
      carbs: 28,
      fats: 5,
      description: 'Pre-entreno ligero para tener energía durante el entrenamiento.',
      ingredients: [
        '1 yogur griego 0% grasa',
        '1 cda miel de abeja',
        '30g granola sin azúcar añadida',
      ],
      icon: Icons.sports_score_rounded,
      color: Color(0xFF4DD0E1),
    ),
    _MealData(
      title: 'Cena',
      time: '20:00',
      calories: 370,
      protein: 27,
      carbs: 37,
      fats: 19,
      description:
          'Cena balanceada y ligera para favorecer la recuperación muscular nocturna.',
      ingredients: [
        '180g salmón al horno con limón',
        '1 taza espinacas salteadas con ajo',
        '100g batata asada',
        '1 cda aceite de coco',
      ],
      icon: Icons.dinner_dining_rounded,
      color: Color(0xFF6366F1),
    ),
  ];

  void _showMealDetail(BuildContext context, _MealData meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MealDetailSheet(meal: meal),
    );
  }

  @override
  Widget build(BuildContext context) {
    const calPct = _caloriesConsumed / _calorieTarget;
    const remaining = _calorieTarget - _caloriesConsumed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCalorieCard(calPct, remaining),
                const SizedBox(height: 14),
                _buildMacrosCard(),
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
                ..._meals.map((m) => _buildMealCard(context, m)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      expandedHeight: 90,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Nutrición',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white)),
            Text('$_planTitle · $_planGoal',
                style: TextStyle(fontSize: 11, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  // ── Calorie ring card ──────────────────────────────────────────────────────
  Widget _buildCalorieCard(double calPct, int remaining) {
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
          // Ring
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
                    Text('$_caloriesConsumed',
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
          // Stats column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _calRow('Meta diaria', '$_calorieTarget kcal', Colors.white54),
                const SizedBox(height: 11),
                _calRow('Consumidas', '$_caloriesConsumed kcal',
                    AppColors.electricPurple),
                const SizedBox(height: 11),
                _calRow('Restantes', '$remaining kcal', AppColors.neonGreen),
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
                    style: const TextStyle(color: Colors.white38, fontSize: 10)),
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
  Widget _buildMacrosCard() {
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
          ..._macros.map(_macroBar),
        ],
      ),
    );
  }

  Widget _macroBar(_Macro m) {
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
                  decoration: BoxDecoration(
                      color: m.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(m.name,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
              Text('${m.consumed} / ${m.target}g',
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
              value: m.pct,
              minHeight: 9,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(m.color),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${(m.pct * 100).toInt()}%',
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
        border: Border.all(
            color: waterColor.withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: waterColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.water_drop_rounded,
                color: waterColor, size: 20),
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
  Widget _buildMealCard(BuildContext context, _MealData meal) {
    return GestureDetector(
      onTap: () => _showMealDetail(context, meal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: meal.color.withValues(alpha: 0.18), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: meal.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(meal.icon, color: meal.color, size: 22),
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
                  Text(meal.description,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
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
                Text('${meal.calories}',
                    style: TextStyle(
                        color: meal.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 17)),
                const Text('kcal',
                    style: TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(height: 5),
                Text(meal.time,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 5),
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

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    if (progress <= 0) return;

    // Progress arc
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
  final _MealData meal;
  const _MealDetailSheet({required this.meal});

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
            // Handle
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
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: meal.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(meal.icon, color: meal.color, size: 26),
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
                      Row(children: [
                        const Icon(Icons.schedule_rounded,
                            color: Colors.white38, size: 13),
                        const SizedBox(width: 4),
                        Text(meal.time,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                      ]),
                    ],
                  ),
                ),
                // Kcal badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: meal.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: meal.color.withValues(alpha: 0.30)),
                  ),
                  child: Column(
                    children: [
                      Text('${meal.calories}',
                          style: TextStyle(
                              color: meal.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 20)),
                      const Text('kcal',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Description
            Text(meal.description,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            // Ingredients
            const Text('Ingredientes',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...meal.ingredients.map(
              (ing) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: meal.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Text(ing,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
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
