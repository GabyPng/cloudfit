import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/auth_service.dart';
import '../../core/constants.dart';
import 'share_progress_widget.dart';

class ProgressScreen extends StatefulWidget {
  static const String name = 'progress_screen';
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<_ProgressData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProgressData> _load() async {
    final clientId = await AuthService.getNumericUserId();
    if (clientId == null) return _ProgressData.empty();

    final rows = await Supabase.instance.client
        .from('progress_records')
        .select(
          'date,weight_kg,bmi,body_fat_pct,muscle_mass_kg,calories_target,adherence_pct',
        )
        .eq('client_id', clientId)
        .order('date', ascending: true)
        .limit(20);

    final list = List<Map<String, dynamic>>.from(rows as List);
    if (list.isEmpty) return _ProgressData.empty();

    final latest = list.last;
    final chartPoints = list.length > 8 ? list.sublist(list.length - 8) : list;

    return _ProgressData(
      records: list,
      chartPoints: chartPoints,
      currentWeight: (latest['weight_kg'] as num?)?.toDouble(),
      bmi: (latest['bmi'] as num?)?.toDouble(),
      bodyFatPct: (latest['body_fat_pct'] as num?)?.toDouble(),
      muscleMassKg: (latest['muscle_mass_kg'] as num?)?.toDouble(),
      lastDate: latest['date'] as String?,
    );
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_ProgressData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }
          if (snap.hasError) {
            return _buildError();
          }
          final data = snap.data ?? _ProgressData.empty();
          if (data.records.isEmpty) return _buildEmpty();
          return _buildContent(data);
        },
      ),
    );
  }

  Widget _buildLoading() => CustomScrollView(slivers: [
        _buildHeader(),
        const SliverFillRemaining(
          child: Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen)),
        ),
      ]);

  Widget _buildError() => CustomScrollView(slivers: [
        _buildHeader(),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.coralOrange, size: 48),
                const SizedBox(height: 16),
                const Text('Error al cargar el progreso',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]);

  Widget _buildEmpty() => CustomScrollView(slivers: [
        _buildHeader(),
        const SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart_rounded,
                      color: Colors.white24, size: 52),
                  SizedBox(height: 16),
                  Text('Sin registros de progreso',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    'Tu entrenador aún no ha registrado mediciones.',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ]);

  Widget _buildContent(_ProgressData data) {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSummaryCards(data),
              if (data.chartPoints.length >= 2) ...[
                const SizedBox(height: 14),
                _buildWeightChart(data),
              ],
              if (data.bodyFatPct != null || data.muscleMassKg != null) ...[
                const SizedBox(height: 14),
                _buildBodyCompositionCard(data),
              ],
              const SizedBox(height: 14),
              _buildLastMeasurement(data),
              const SizedBox(height: 14),
              const ShareProgressWidget(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
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
            ),
            IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white38, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(_ProgressData data) {
    final weightStr = data.currentWeight != null
        ? '${data.currentWeight!.toStringAsFixed(1)} kg'
        : '-- kg';
    final bmiStr =
        data.bmi != null ? data.bmi!.toStringAsFixed(1) : '--';
    final bmiLabel = _bmiLabel(data.bmi);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.monitor_weight_outlined,
            iconColor: AppColors.neonGreen,
            title: 'Peso actual',
            value: weightStr,
            badge: bmiLabel,
            badgeColor: AppColors.neonGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.shield_outlined,
            iconColor: AppColors.electricPurple,
            title: 'IMC actual',
            value: bmiStr,
            badge: bmiLabel,
            badgeColor: AppColors.electricPurple,
          ),
        ),
      ],
    );
  }

  String _bmiLabel(double? bmi) {
    if (bmi == null) return '--';
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Widget _buildWeightChart(_ProgressData data) {
    final points = data.chartPoints;
    final weights = points.map((r) => (r['weight_kg'] as num?)?.toDouble() ?? 0.0).toList();
    final labels = points.map((r) {
      final d = DateTime.tryParse(r['date'] as String? ?? '');
      return d != null ? '${d.day}/${d.month}' : '';
    }).toList();

    final minW = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxW = weights.reduce((a, b) => a > b ? a : b) + 2;

    final spots = List.generate(
        weights.length, (i) => FlSpot(i.toDouble(), weights[i]));

    final weightLine = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: AppColors.neonGreen,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
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
          const Text('Evolución de peso',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minW,
                maxY: maxW,
                minX: 0,
                maxX: (weights.length - 1).toDouble(),
                clipData: const FlClipData.all(),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.cardGrey,
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} kg',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 2,
                      getTitlesWidget: (val, _) => Text(
                        val.toStringAsFixed(0),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, _) {
                        final i = val.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(labels[i],
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10)),
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
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [weightLine],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyCompositionCard(_ProgressData data) {
    final musclePct = data.muscleMassKg != null && data.currentWeight != null && data.currentWeight! > 0
        ? (data.muscleMassKg! / data.currentWeight! * 100).clamp(0.0, 100.0)
        : null;
    final fatPct = data.bodyFatPct;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Composición corporal',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (musclePct != null)
            _compRow('Músculo', '${musclePct.toStringAsFixed(1)}%',
                musclePct / 100, AppColors.neonGreen),
          if (musclePct != null) const SizedBox(height: 14),
          if (fatPct != null)
            _compRow('Grasa corporal', '${fatPct.toStringAsFixed(1)}%',
                (fatPct / 100).clamp(0.0, 1.0), AppColors.electricPurple),
          if (musclePct == null && fatPct == null)
            const Text('Sin datos de composición',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _compRow(String label, String valueText, double pct, Color color) {
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
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
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

  Widget _buildLastMeasurement(_ProgressData data) {
    String dateLabel = 'Sin fecha';
    if (data.lastDate != null) {
      final d = DateTime.tryParse(data.lastDate!);
      if (d != null) {
        dateLabel =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      }
    }

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Última medición',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(dateLabel,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressData {
  final List<Map<String, dynamic>> records;
  final List<Map<String, dynamic>> chartPoints;
  final double? currentWeight;
  final double? bmi;
  final double? bodyFatPct;
  final double? muscleMassKg;
  final String? lastDate;

  const _ProgressData({
    required this.records,
    required this.chartPoints,
    this.currentWeight,
    this.bmi,
    this.bodyFatPct,
    this.muscleMassKg,
    this.lastDate,
  });

  factory _ProgressData.empty() => const _ProgressData(
        records: [],
        chartPoints: [],
      );
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String badge;
  final Color badgeColor;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeColor,
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
        ],
      ),
    );
  }
}
