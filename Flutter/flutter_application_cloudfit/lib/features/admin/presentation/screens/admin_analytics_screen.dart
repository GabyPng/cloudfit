import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../data/admin_api.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _growth = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AdminApi.getOverview(),
        AdminApi.getUserGrowth(days: 7),
      ]);
      if (!mounted) return;
      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _growth = (results[1] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ AdminAnalytics error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.neonGreen));
    }

    return RefreshIndicator(
      color: AppColors.neonGreen,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          _buildKPIs(),
          const SizedBox(height: 16),
          _buildGrowthChart(),
          const SizedBox(height: 16),
          _buildRoleChart(),
        ],
      ),
    );
  }

  Widget _buildKPIs() {
    return Column(children: [
      Row(children: [
        _kpiCard('Usuarios Totales',
            _overview['total_users']?.toString() ?? '—',
            Icons.people_outline, AppColors.neonGreen),
        const SizedBox(width: 10),
        _kpiCard('Nuevos (7 días)',
            _overview['new_users_7d']?.toString() ?? '—',
            Icons.person_add_outlined, AppColors.electricPurple),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _kpiCard('Verificaciones pendientes',
            _overview['pending_verification']?.toString() ?? '—',
            Icons.pending_outlined, const Color(0xFFFFBB00)),
        const SizedBox(width: 10),
        _kpiCard('Tickets abiertos',
            _overview['open_tickets']?.toString() ?? '—',
            Icons.support_agent_outlined, AppColors.coralOrange),
      ]),
    ]);
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _buildGrowthChart() {
    if (_growth.isEmpty) return const SizedBox.shrink();

    final spots = _growth.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['count'] as int).toDouble());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('NUEVOS USUARIOS (7 DIAS)',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1)),
        const SizedBox(height: 20),
        SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      final i = v.toInt();
                      if (i >= 0 && i < _growth.length) {
                        final date = _growth[i]['date'] as String;
                        return Text(date.substring(5),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 9));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.neonGreen,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.neonGreen.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildRoleChart() {
    final dist = _overview['role_distribution'] as Map? ?? {};
    if (dist.isEmpty) return const SizedBox.shrink();

    final colors = [
      AppColors.neonGreen,
      AppColors.electricPurple,
      AppColors.coralOrange,
      const Color(0xFFFFBB00),
    ];

    final entries = dist.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + (e.value as int));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('DISTRIBUCION DE ROLES',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1)),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: entries.asMap().entries.map((e) {
                  final color = colors[e.key % colors.length];
                  final pct = total > 0
                      ? (e.value.value as int) / total * 100
                      : 0.0;
                  return PieChartSectionData(
                    value: (e.value.value as int).toDouble(),
                    color: color,
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                    radius: 40,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.asMap().entries.map((e) {
                final color = colors[e.key % colors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      '${e.value.key}: ${e.value.value}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ]),
                );
              }).toList(),
            ),
          ),
        ]),
      ]),
    );
  }
}
