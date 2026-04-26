import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import 'models/achievement.dart';

// ── Achievement definition ───────────────────────────────────────────────────
class _AchievementDef {
  final String title;
  final String description;
  final IconData icon;
  final int threshold;
  final String type; // 'workout_count' | 'streak'

  const _AchievementDef({
    required this.title,
    required this.description,
    required this.icon,
    required this.threshold,
    required this.type,
  });
}

const _defs = [
  _AchievementDef(
    title: 'Primer Paso',
    description: 'Completa tu primer entrenamiento',
    icon: Icons.directions_run_rounded,
    threshold: 1,
    type: 'workout_count',
  ),
  _AchievementDef(
    title: 'Constante',
    description: 'Completa 5 entrenamientos',
    icon: Icons.fitness_center_rounded,
    threshold: 5,
    type: 'workout_count',
  ),
  _AchievementDef(
    title: 'Racha de Fuego',
    description: '7 días consecutivos activo',
    icon: Icons.local_fire_department_rounded,
    threshold: 7,
    type: 'streak',
  ),
  _AchievementDef(
    title: 'Dedicado',
    description: 'Completa 10 entrenamientos',
    icon: Icons.emoji_events_rounded,
    threshold: 10,
    type: 'workout_count',
  ),
  _AchievementDef(
    title: 'Inquebrantable',
    description: '30 días consecutivos activo',
    icon: Icons.bolt_rounded,
    threshold: 30,
    type: 'streak',
  ),
  _AchievementDef(
    title: 'Veterano',
    description: 'Completa 30 entrenamientos',
    icon: Icons.workspace_premium_rounded,
    threshold: 30,
    type: 'workout_count',
  ),
];

// ── Screen ───────────────────────────────────────────────────────────────────
class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final _supabase = Supabase.instance.client;
  late Future<_RewardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_RewardData> _loadData() async {
    final authId = _supabase.auth.currentUser?.id;
    if (authId == null) return _RewardData.empty();

    final userData = await _supabase
        .from('users')
        .select('user_id')
        .eq('supabase_id', authId)
        .maybeSingle();
    if (userData == null) return _RewardData.empty();

    final clientId = userData['user_id'];

    final logs = await _supabase
        .from('workout_logs')
        .select('date, is_complete')
        .eq('client_id', clientId)
        .eq('is_complete', true)
        .order('date', ascending: false);

    final totalWorkouts = logs.length;
    final streak = _computeStreak(logs);
    final xp = totalWorkouts * 50;
    final level = (xp ~/ 500) + 1;
    final xpTarget = level * 500;

    final achievements = _defs.map((d) {
      final current = d.type == 'workout_count' ? totalWorkouts : streak;
      final progress = (current / d.threshold).clamp(0.0, 1.0);
      return AchievementModel(
        title: d.title,
        description: d.description,
        icon: d.icon,
        isUnlocked: current >= d.threshold,
        progress: progress,
      );
    }).toList();

    return _RewardData(
      totalWorkouts: totalWorkouts,
      streak: streak,
      xp: xp,
      level: level,
      xpTarget: xpTarget,
      achievements: achievements,
      weekDays: _computeWeekDays(logs),
    );
  }

  int _computeStreak(List logs) {
    if (logs.isEmpty) return 0;
    final dates = logs
        .map((l) {
          final d = DateTime.tryParse(l['date'].toString());
          return d == null ? null : DateTime(d.year, d.month, d.day);
        })
        .whereType<DateTime>()
        .toSet();

    int streak = 0;
    var current = DateTime.now();
    current = DateTime(current.year, current.month, current.day);

    while (dates.contains(current)) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<bool> _computeWeekDays(List logs) {
    final today = DateTime.now();
    final dates = logs
        .map((l) {
          final d = DateTime.tryParse(l['date'].toString());
          return d == null ? null : DateTime(d.year, d.month, d.day);
        })
        .whereType<DateTime>()
        .toSet();

    // Monday = 0 index in weekDays list
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      return dates.contains(day);
    });
  }

  static const _weekDayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_RewardData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.neonGreen));
          }

          final data = snapshot.data ?? _RewardData.empty();
          final unlocked = data.achievements.where((a) => a.isUnlocked).length;

          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildLevelCard(data),
                    const SizedBox(height: 14),
                    _buildStatsRow(data.xp, data.streak, unlocked, data.achievements.length),
                    const SizedBox(height: 14),
                    _buildStreakCard(data.streak, data.weekDays),
                    const SizedBox(height: 24),
                    _sectionTitle('Logros'),
                    const SizedBox(height: 12),
                    _buildAchievementsGrid(data.achievements),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      expandedHeight: 90,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white38),
          onPressed: () => setState(() => _future = _loadData()),
        ),
      ],
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.fromLTRB(20, 0, 20, 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logros',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
            Text('Tu progreso y recompensas',
                style: TextStyle(fontSize: 12, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(_RewardData data) {
    final xpPct = data.xpTarget > 0 ? (data.xp / data.xpTarget).clamp(0.0, 1.0) : 0.0;
    final levelTitle = _levelTitle(data.level);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [AppColors.electricPurple, Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(Icons.auto_awesome_rounded,
                size: 90, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('NIVEL ${data.level}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.5)),
              ),
              const SizedBox(height: 10),
              Text(levelTitle,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${data.xp} XP',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  Text('${data.xpTarget} XP para Nivel ${data.level + 1}',
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: xpPct,
                  minHeight: 10,
                  backgroundColor: Colors.black.withValues(alpha: 0.25),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _levelTitle(int level) {
    const titles = [
      'NOVATO CURIOSO',
      'PRINCIPIANTE ACTIVO',
      'ATLETA EN FORMACIÓN',
      'GUERRERO CONSTANTE',
      'ATACANTE VETERANO',
      'ÉLITE FITNESS',
      'MAESTRO DEL HIERRO',
    ];
    final i = (level - 1).clamp(0, titles.length - 1);
    return titles[i];
  }

  Widget _buildStatsRow(int xp, int streak, int unlocked, int total) {
    return Row(
      children: [
        _statCard(icon: Icons.bolt_rounded, color: AppColors.neonGreen, value: '$xp', label: 'XP Total'),
        const SizedBox(width: 10),
        _statCard(icon: Icons.local_fire_department_rounded, color: AppColors.coralOrange, value: '$streak días', label: 'Racha'),
        const SizedBox(width: 10),
        _statCard(icon: Icons.workspace_premium_rounded, color: AppColors.electricPurple, value: '$unlocked/$total', label: 'Logros'),
      ],
    );
  }

  Widget _statCard({required IconData icon, required Color color, required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _buildStreakCard(int streak, List<bool> completedDays) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Icon(Icons.bolt_rounded, color: AppColors.neonGreen, size: 20),
                SizedBox(width: 8),
                Text('Racha Semanal',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.35)),
                ),
                child: Text('¡$streak Días!',
                    style: const TextStyle(
                        color: AppColors.neonGreen, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final done = i < completedDays.length ? completedDays[i] : false;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: done ? AppColors.neonGreen : AppColors.cardGrey,
                      shape: BoxShape.circle,
                      boxShadow: done
                          ? [BoxShadow(color: AppColors.neonGreen.withValues(alpha: 0.35), blurRadius: 8, spreadRadius: 1)]
                          : null,
                    ),
                    child: Icon(done ? Icons.check_rounded : Icons.remove,
                        color: done ? Colors.black : Colors.white24, size: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(_weekDayLabels[i],
                      style: TextStyle(
                          fontSize: 11,
                          color: done ? Colors.white70 : Colors.white24,
                          fontWeight: done ? FontWeight.w600 : FontWeight.normal)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildAchievementsGrid(List<AchievementModel> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: achievements.length,
      itemBuilder: (_, i) => _AchievementCard(achievement: achievements[i]),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _RewardData {
  final int totalWorkouts;
  final int streak;
  final int xp;
  final int level;
  final int xpTarget;
  final List<AchievementModel> achievements;
  final List<bool> weekDays;

  const _RewardData({
    required this.totalWorkouts,
    required this.streak,
    required this.xp,
    required this.level,
    required this.xpTarget,
    required this.achievements,
    required this.weekDays,
  });

  factory _RewardData.empty() => _RewardData(
        totalWorkouts: 0,
        streak: 0,
        xp: 0,
        level: 1,
        xpTarget: 500,
        achievements: _defs
            .map((d) => AchievementModel(
                  title: d.title,
                  description: d.description,
                  icon: d.icon,
                  isUnlocked: false,
                  progress: 0.0,
                ))
            .toList(),
        weekDays: List.filled(7, false),
      );
}

// ── Achievement card ──────────────────────────────────────────────────────────
class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    final color = unlocked ? AppColors.neonGreen : Colors.white24;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.surface : AppColors.cardGrey,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked
              ? AppColors.neonGreen.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? AppColors.neonGreen.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: unlocked
                    ? AppColors.neonGreen.withValues(alpha: 0.40)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Icon(achievement.icon, size: 26, color: color),
          ),
          const SizedBox(height: 12),
          Text(achievement.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: unlocked ? Colors.white : Colors.white38)),
          const SizedBox(height: 4),
          Text(achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: unlocked ? Colors.white54 : Colors.white24,
                  height: 1.3)),
          if (!unlocked && achievement.progress > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement.progress,
                minHeight: 4,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricPurple),
              ),
            ),
            const SizedBox(height: 4),
            Text('${(achievement.progress * 100).toInt()}%',
                style: const TextStyle(
                    color: AppColors.electricPurple,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
          if (unlocked) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Completado',
                  style: TextStyle(
                      color: AppColors.neonGreen, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}
