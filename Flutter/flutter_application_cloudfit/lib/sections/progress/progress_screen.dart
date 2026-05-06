import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ProgressScreen extends StatelessWidget {
  static const String name = 'progress_screen';
  const ProgressScreen({super.key});
  // ── Static data ──────────────────────────────────────────────────────────
  static const _weightData = [83.0, 82.0, 80.5, 79.5, 78.8, 78.5, 78.2, 78.4];
  static const _months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago'];
  static const _weightTarget = 72.0;
  static const _currentWeight = 78.4;
  static const _bmi = 23.1;
  static const _muscleKg = 48.6;
  static const _musclePct = 62.0;
  static const _fatPct = 14.0;
  static const _waterPct = 6.0;
  static const _metabolism = 1840;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSummaryCards(),
                const SizedBox(height: 14),
                _buildWeightChart(),
                const SizedBox(height: 14),
                _buildBodyCompositionCard(),
                const SizedBox(height: 14),
                _buildStatsRow(),
                const SizedBox(height: 14),
                _buildLastMeasurement(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progreso',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Tu evolución, paso a paso',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary cards ─────────────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.monitor_weight_outlined,
            iconColor: AppColors.neonGreen,
            title: 'Peso actual',
            value: '$_currentWeight kg',
            badge: 'Normal',
            badgeColor: AppColors.neonGreen,
            delta: '▼  -1.2 kg este mes',
            deltaColor: Colors.redAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.shield_outlined,
            iconColor: AppColors.electricPurple,
            title: 'IMC actual',
            value: '$_bmi',
            badge: 'Normal',
            badgeColor: AppColors.electricPurple,
            delta: '✓  Rango saludable',
            deltaColor: AppColors.neonGreen,
          ),
        ),
      ],
    );
  }

  // ── Weight evolution chart ────────────────────────────────────────────────
  Widget _buildWeightChart() {
    final spots = List.generate(
      _weightData.length,
      (i) => FlSpot(i.toDouble(), _weightData[i]),
    );

    final weightLine = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: AppColors.neonGreen,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
          radius: 4,
          color: AppColors.neonGreen,
          strokeWidth: 2,
          strokeColor: AppColors.background,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            AppColors.neonGreen.withValues(alpha: 0.22),
            AppColors.neonGreen.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Evolución de peso',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cardGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(children: [
                  Text('Peso (kg)',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white38, size: 16),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                minY: 65,
                maxY: 86,
                minX: 0,
                maxX: 7,
                clipData: const FlClipData.all(),
                showingTooltipIndicators: [
                  ShowingTooltipIndicators([
                    LineBarSpot(weightLine, 0, FlSpot(7, 78.4)),
                  ]),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.cardGrey,
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${s.y} kg\nActual',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 5,
                      getTitlesWidget: (val, _) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, _) {
                        final i = val.toInt();
                        if (i < 0 || i >= _months.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(_months[i],
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  weightLine,
                  // Target dashed line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, _weightTarget),
                      FlSpot(7, _weightTarget),
                    ],
                    isCurved: false,
                    color: Colors.white30,
                    barWidth: 1.5,
                    dashArray: [6, 4],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(
                width: 18,
                height: 1.5,
                decoration: const BoxDecoration(
                    color: Colors.white30)),
            const SizedBox(width: 6),
            const Text('Objetivo: $_weightTarget kg',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          ]),
        ],
      ),
    );
  }

  // ── Body composition card ─────────────────────────────────────────────────
  Widget _buildBodyCompositionCard() {
    const cyanColor = Color(0xFF4DD0E1);
    const otherPct = 100.0 - _musclePct - _fatPct - _waterPct;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Composición corporal',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Row(children: const [
                Text('Ver detalles',
                    style: TextStyle(
                        color: AppColors.neonGreen, fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.neonGreen, size: 12),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Donut chart with body icon
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                              value: _musclePct,
                              color: AppColors.neonGreen,
                              radius: 20,
                              title: ''),
                          PieChartSectionData(
                              value: _fatPct,
                              color: AppColors.electricPurple,
                              radius: 20,
                              title: ''),
                          PieChartSectionData(
                              value: _waterPct,
                              color: cyanColor,
                              radius: 20,
                              title: ''),
                          PieChartSectionData(
                              value: otherPct,
                              color: Colors.white10,
                              radius: 20,
                              title: ''),
                        ],
                        centerSpaceRadius: 45,
                        sectionsSpace: 2,
                        startDegreeOffset: -90,
                      ),
                    ),
                    const Icon(Icons.accessibility_new_rounded,
                        color: Colors.white24, size: 44),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Legend with bars
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _compRow('Músculo', '${_musclePct.toInt()}%',
                        _musclePct / 100, AppColors.neonGreen),
                    const SizedBox(height: 18),
                    _compRow('Grasa corporal', '${_fatPct.toInt()}%',
                        _fatPct / 100, AppColors.electricPurple),
                    const SizedBox(height: 18),
                    _compRow('Agua', '${_waterPct.toInt()}%',
                        _waterPct / 100, cyanColor),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compRow(
      String label, String valueText, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ]),
            Text(valueText,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.neonGreen,
            label: 'Masa muscular',
            value: '$_muscleKg kg',
            delta: '+1.8 kg',
            isPositive: true,
          ),
          _vDivider(),
          _StatItem(
            icon: Icons.percent_rounded,
            iconColor: AppColors.electricPurple,
            label: 'Grasa corporal',
            value: '$_fatPct%',
            delta: '-0.8%',
            isPositive: false,
          ),
          _vDivider(),
          _StatItem(
            icon: Icons.water_drop_rounded,
            iconColor: const Color(0xFF4DD0E1),
            label: 'Agua corporal',
            value: '$_waterPct%',
            delta: '= 0%',
            isPositive: null,
          ),
          _vDivider(),
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.coralOrange,
            label: 'Metabolismo',
            value: '$_metabolism',
            delta: '+120 kcal',
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 52,
        color: Colors.white.withValues(alpha: 0.07),
      );

  // ── Last measurement ──────────────────────────────────────────────────────
  Widget _buildLastMeasurement() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.electricPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: AppColors.electricPurple, size: 18),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Última medición',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                SizedBox(height: 2),
                Text('24 Oct, 2023 · 08:30 AM',
                    style:
                        TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white24, size: 15),
        ],
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String badge;
  final Color badgeColor;
  final String delta;
  final Color deltaColor;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.delta,
    required this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge,
                    style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(delta,
              style: TextStyle(
                  color: deltaColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Stat item ─────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String delta;
  final bool? isPositive; // null = neutral

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.delta,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final Color deltaColor;
    final String prefix;
    if (isPositive == null) {
      deltaColor = Colors.white38;
      prefix = '';
    } else if (isPositive!) {
      deltaColor = AppColors.neonGreen;
      prefix = '▲  ';
    } else {
      deltaColor = Colors.redAccent;
      prefix = '▼  ';
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 9.5)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text('$prefix$delta',
              style: TextStyle(
                  color: deltaColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
