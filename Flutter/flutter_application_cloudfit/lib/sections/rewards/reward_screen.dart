import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'models/achievement.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  static const _level = 5;
  static const _levelTitle = 'ATACANTE VETERANO';
  static const _xpCurrent = 2450;
  static const _xpTarget = 3000;
  static const _streakDays = 7;
  static const _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  // cuántos días de la semana están completados
  static const _completedDays = 7;

  static final _achievements = [
    AchievementModel(
      title: 'Madrugador',
      description: '5 entrenos antes de las 7 AM',
      icon: Icons.wb_sunny_rounded,
      isUnlocked: true,
      progress: 1.0,
    ),
    AchievementModel(
      title: 'Voluntad de Hierro',
      description: '10,000 kg levantados en una semana',
      icon: Icons.fitness_center_rounded,
      isUnlocked: true,
      progress: 1.0,
    ),
    AchievementModel(
      title: 'Relámpago',
      description: 'Corre 5 km en menos de 20 min',
      icon: Icons.bolt_rounded,
      isUnlocked: false,
      progress: 0.6,
    ),
    AchievementModel(
      title: 'Escuadrón',
      description: 'Organiza 10 sesiones grupales',
      icon: Icons.groups_rounded,
      isUnlocked: false,
      progress: 0.3,
    ),
    AchievementModel(
      title: 'Inquebrantable',
      description: '30 días consecutivos activo',
      icon: Icons.local_fire_department_rounded,
      isUnlocked: true,
      progress: 1.0,
    ),
    AchievementModel(
      title: 'Gran Maestro',
      description: 'Alcanza nivel de experiencia 50',
      icon: Icons.workspace_premium_rounded,
      isUnlocked: false,
      progress: 0.1,
    ),
  ];

  int get _unlockedCount => _achievements.where((a) => a.isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildLevelCard(),
                const SizedBox(height: 14),
                _buildStatsRow(),
                const SizedBox(height: 14),
                _buildStreakCard(),
                const SizedBox(height: 24),
                _sectionTitle('Logros'),
                const SizedBox(height: 12),
                _buildAchievementsGrid(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
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
            Text('Logros',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white)),
            Text('Tu progreso y recompensas',
                style: TextStyle(fontSize: 12, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  // ── Level card ───────────────────────────────────────────────────────────
  Widget _buildLevelCard() {
    final xpPct = _xpCurrent / _xpTarget;
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
          // Decorative icon
          Positioned(
            right: -8,
            top: -8,
            child: Icon(Icons.auto_awesome_rounded,
                size: 90,
                color: Colors.white.withValues(alpha: 0.08)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('NIVEL $_level',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1.5)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(_levelTitle,
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_xpCurrent XP',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  Text('$_xpTarget XP para Nivel ${_level + 1}',
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: xpPct,
                  minHeight: 10,
                  backgroundColor: Colors.black.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.neonGreen),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard(
          icon: Icons.bolt_rounded,
          color: AppColors.neonGreen,
          value: '$_xpCurrent',
          label: 'XP Total',
        ),
        const SizedBox(width: 10),
        _statCard(
          icon: Icons.local_fire_department_rounded,
          color: AppColors.coralOrange,
          value: '$_streakDays días',
          label: 'Racha',
        ),
        const SizedBox(width: 10),
        _statCard(
          icon: Icons.workspace_premium_rounded,
          color: AppColors.electricPurple,
          value: '$_unlockedCount/${_achievements.length}',
          label: 'Logros',
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ),
    );
  }

  // ── Streak card ──────────────────────────────────────────────────────────
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.neonGreen.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.bolt_rounded,
                    color: AppColors.neonGreen, size: 20),
                const SizedBox(width: 8),
                const Text('Racha Semanal',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.neonGreen.withValues(alpha: 0.35)),
                ),
                child: Text('¡$_streakDays Días!',
                    style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final completed = i < _completedDays;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: completed
                          ? AppColors.neonGreen
                          : AppColors.cardGrey,
                      shape: BoxShape.circle,
                      boxShadow: completed
                          ? [
                              BoxShadow(
                                color: AppColors.neonGreen
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      completed ? Icons.check_rounded : Icons.remove,
                      color: completed ? Colors.black : Colors.white24,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_weekDays[i],
                      style: TextStyle(
                          fontSize: 11,
                          color: completed
                              ? Colors.white70
                              : Colors.white24,
                          fontWeight: completed
                              ? FontWeight.w600
                              : FontWeight.normal)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Achievements section ─────────────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold));
  }

  Widget _buildAchievementsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: _achievements.length,
      itemBuilder: (_, i) => _AchievementCard(achievement: _achievements[i]),
    );
  }
}

// ── Achievement card widget ──────────────────────────────────────────────────
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
          // Icon badge
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
          // Progress bar (only for locked with partial progress)
          if (!unlocked && achievement.progress > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement.progress,
                minHeight: 4,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.electricPurple),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(achievement.progress * 100).toInt()}%',
              style: const TextStyle(
                  color: AppColors.electricPurple,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ],
          if (unlocked) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Completado',
                  style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}
