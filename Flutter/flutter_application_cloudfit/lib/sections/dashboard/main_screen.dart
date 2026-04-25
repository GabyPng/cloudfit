import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';

// ── Muscle zone ───────────────────────────────────────────────────────────────
class _MuscleZone {
  final String name;
  final Color color;
  const _MuscleZone(this.name, this.color);
}

// ═══════════════════════════════════════════════════════════════════════════════
// PATH BUILDERS — 130×280 coordinate space, cx = 65
// Shared between painters and hit-test logic.
// ═══════════════════════════════════════════════════════════════════════════════

Path _bodyHead(double cx) => Path()
  ..moveTo(cx, 1)
  ..cubicTo(cx + 19, 2, cx + 19, 17, cx + 16, 24)
  ..cubicTo(cx + 13, 32, cx + 9, 39, cx, 41)
  ..cubicTo(cx - 9, 39, cx - 13, 32, cx - 16, 24)
  ..cubicTo(cx - 19, 17, cx - 19, 2, cx, 1)
  ..close();

Path _bodyNeck(double cx) => Path()
  ..moveTo(cx - 7, 39)
  ..lineTo(cx - 8, 51)
  ..lineTo(cx + 8, 51)
  ..lineTo(cx + 7, 39)
  ..close();

Path _bodyTorso(double cx) => Path()
  ..moveTo(cx - 8, 51)
  ..cubicTo(cx - 22, 51, cx - 40, 56, cx - 44, 65)
  ..cubicTo(cx - 48, 75, cx - 47, 93, cx - 41, 113)
  ..cubicTo(cx - 37, 126, cx - 32, 133, cx - 27, 140)
  ..cubicTo(cx - 24, 147, cx - 27, 158, cx - 33, 166)
  ..lineTo(cx - 5, 170)
  ..lineTo(cx + 5, 170)
  ..cubicTo(cx + 27, 158, cx + 24, 147, cx + 27, 140)
  ..cubicTo(cx + 32, 133, cx + 37, 126, cx + 41, 113)
  ..cubicTo(cx + 47, 93, cx + 48, 75, cx + 44, 65)
  ..cubicTo(cx + 40, 56, cx + 22, 51, cx + 8, 51)
  ..close();

Path _bodyPecL(double cx) => Path()
  ..moveTo(cx - 3, 56)
  ..cubicTo(cx - 16, 54, cx - 36, 61, cx - 41, 73)
  ..cubicTo(cx - 44, 84, cx - 38, 99, cx - 27, 107)
  ..cubicTo(cx - 18, 112, cx - 6, 114, cx - 2, 112)
  ..lineTo(cx - 2, 56)
  ..close();

Path _bodyPecR(double cx) => Path()
  ..moveTo(cx + 3, 56)
  ..cubicTo(cx + 16, 54, cx + 36, 61, cx + 41, 73)
  ..cubicTo(cx + 44, 84, cx + 38, 99, cx + 27, 107)
  ..cubicTo(cx + 18, 112, cx + 6, 114, cx + 2, 112)
  ..lineTo(cx + 2, 56)
  ..close();

Path _bodyAbsZone(double cx) => Path()
  ..moveTo(cx - 22, 114)
  ..lineTo(cx + 22, 114)
  ..cubicTo(cx + 27, 132, cx + 27, 150, cx + 23, 163)
  ..lineTo(cx + 5, 170)
  ..lineTo(cx - 5, 170)
  ..cubicTo(cx - 23, 163, cx - 27, 150, cx - 27, 132)
  ..close();

Path _bodyArmL(double cx) => Path()
  ..moveTo(cx - 37, 58)
  ..cubicTo(cx - 44, 57, cx - 52, 63, cx - 55, 74)
  ..cubicTo(cx - 58, 88, cx - 56, 108, cx - 52, 122)
  ..cubicTo(cx - 50, 136, cx - 48, 151, cx - 46, 163)
  ..lineTo(cx - 44, 170)
  ..cubicTo(cx - 45, 174, cx - 46, 180, cx - 43, 184)
  ..lineTo(cx - 38, 187)
  ..cubicTo(cx - 35, 188, cx - 32, 185, cx - 31, 181)
  ..lineTo(cx - 33, 170)
  ..cubicTo(cx - 34, 157, cx - 36, 142, cx - 37, 127)
  ..cubicTo(cx - 38, 110, cx - 37, 92, cx - 35, 78)
  ..cubicTo(cx - 34, 67, cx - 34, 60, cx - 37, 58)
  ..close();

Path _bodyArmR(double cx) => Path()
  ..moveTo(cx + 37, 58)
  ..cubicTo(cx + 44, 57, cx + 52, 63, cx + 55, 74)
  ..cubicTo(cx + 58, 88, cx + 56, 108, cx + 52, 122)
  ..cubicTo(cx + 50, 136, cx + 48, 151, cx + 46, 163)
  ..lineTo(cx + 44, 170)
  ..cubicTo(cx + 45, 174, cx + 46, 180, cx + 43, 184)
  ..lineTo(cx + 38, 187)
  ..cubicTo(cx + 35, 188, cx + 32, 185, cx + 31, 181)
  ..lineTo(cx + 33, 170)
  ..cubicTo(cx + 34, 157, cx + 36, 142, cx + 37, 127)
  ..cubicTo(cx + 38, 110, cx + 37, 92, cx + 35, 78)
  ..cubicTo(cx + 34, 67, cx + 34, 60, cx + 37, 58)
  ..close();

Path _bodyLegL(double cx) => Path()
  ..moveTo(cx - 33, 166)
  ..cubicTo(cx - 37, 179, cx - 38, 200, cx - 34, 220)
  ..cubicTo(cx - 32, 230, cx - 30, 236, cx - 29, 243)
  ..cubicTo(cx - 29, 253, cx - 27, 263, cx - 25, 271)
  ..lineTo(cx - 25, 275)
  ..cubicTo(cx - 26, 278, cx - 29, 280, cx - 27, 280)
  ..lineTo(cx - 7, 280)
  ..cubicTo(cx - 4, 280, cx - 3, 277, cx - 5, 273)
  ..lineTo(cx - 8, 271)
  ..cubicTo(cx - 10, 261, cx - 11, 250, cx - 11, 243)
  ..cubicTo(cx - 10, 232, cx - 8, 222, cx - 6, 215)
  ..cubicTo(cx - 3, 198, cx - 2, 181, cx - 5, 170)
  ..close();

Path _bodyLegR(double cx) => Path()
  ..moveTo(cx + 33, 166)
  ..cubicTo(cx + 37, 179, cx + 38, 200, cx + 34, 220)
  ..cubicTo(cx + 32, 230, cx + 30, 236, cx + 29, 243)
  ..cubicTo(cx + 29, 253, cx + 27, 263, cx + 25, 271)
  ..lineTo(cx + 25, 275)
  ..cubicTo(cx + 26, 278, cx + 29, 280, cx + 27, 280)
  ..lineTo(cx + 7, 280)
  ..cubicTo(cx + 4, 280, cx + 3, 277, cx + 5, 273)
  ..lineTo(cx + 8, 271)
  ..cubicTo(cx + 10, 261, cx + 11, 250, cx + 11, 243)
  ..cubicTo(cx + 10, 232, cx + 8, 222, cx + 6, 215)
  ..cubicTo(cx + 3, 198, cx + 2, 181, cx + 5, 170)
  ..close();

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _name = 'Santiago';
  static const _weight = 78.4;
  static const _bmi = 23.1;
  static const _weeklyWorkouts = 4;
  static const _caloriesConsumed = 1840;
  static const _caloriesTarget = 2500;
  static const _routineName = 'Push · Pull · Legs';

  static const _zones = [
    _MuscleZone('Pecho',   AppColors.neonGreen),
    _MuscleZone('Espalda', Color(0xFF4DD0E1)),
    _MuscleZone('Brazos',  Color(0xFFD0FD3E)),
    _MuscleZone('Core',    Color(0xFFFF6B6B)),
    _MuscleZone('Piernas', Color(0xFF6366F1)),
  ];

  void _onMuscleTap(BuildContext context, String zone) {
    context.go('/cliente/exercises');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildBodyCard(context),
              const SizedBox(height: 24),
              _buildTodaySection(),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buenos días,',
                style: TextStyle(color: Colors.white54, fontSize: 14)),
            Text(_name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        _StreakBadge(days: 7),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage('assets/images/Jona.png'),
          backgroundColor: AppColors.cardGrey,
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(
            label: 'Peso',
            value: '${_weight}kg',
            icon: Icons.monitor_weight_outlined,
            accent: AppColors.neonGreen),
        const SizedBox(width: 10),
        _StatCard(
            label: 'IMC',
            value: '$_bmi',
            icon: Icons.health_and_safety_outlined,
            accent: const Color(0xFF6366F1)),
        const SizedBox(width: 10),
        _StatCard(
            label: 'Semana',
            value: '$_weeklyWorkouts/7',
            icon: Icons.fitness_center,
            accent: const Color(0xFFFF6B6B)),
      ],
    );
  }

  Widget _buildBodyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                const Text('Mapa Muscular',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                Row(children: const [
                  Icon(Icons.touch_app_rounded, color: Colors.white24, size: 14),
                  SizedBox(width: 4),
                  Text('Toca un músculo',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ]),
              ],
            ),
          ),
          // Dual body silhouettes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _BodyTapWidget(
                  isBack: false,
                  zones: _zones,
                  onTap: (z) => _onMuscleTap(context, z),
                ),
                Container(
                  width: 1,
                  height: 200,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
                _BodyTapWidget(
                  isBack: true,
                  zones: _zones,
                  onTap: (z) => _onMuscleTap(context, z),
                ),
              ],
            ),
          ),
          // Zone legend chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _zones
                  .map((z) => _ZoneChip(
                      zone: z, onTap: () => _onMuscleTap(context, z.name)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hoy',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _RoutineCard(name: _routineName, workoutsThisWeek: _weeklyWorkouts),
        const SizedBox(height: 12),
        _CaloriesCard(consumed: _caloriesConsumed, target: _caloriesTarget),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAPPABLE BODY WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class _BodyTapWidget extends StatelessWidget {
  final bool isBack;
  final List<_MuscleZone> zones;
  final void Function(String zone) onTap;

  const _BodyTapWidget({
    required this.isBack,
    required this.zones,
    required this.onTap,
  });

  // Widget canvas size
  static const double _kW = 118;
  static const double _kH = 268;

  // Convert widget-space tap to 130×280 path-space for containment check
  static Offset _toPathSpace(Offset pos) =>
      Offset(pos.dx * 130 / _kW, pos.dy * 280 / _kH);

  String? _hitTest(Offset pos) {
    final p = _toPathSpace(pos);
    const cx = 65.0;
    if (!isBack) {
      if (_bodyAbsZone(cx).contains(p)) return 'Core';
      if (_bodyPecL(cx).contains(p) || _bodyPecR(cx).contains(p)) return 'Pecho';
      if (_bodyArmL(cx).contains(p) || _bodyArmR(cx).contains(p)) return 'Brazos';
      if (_bodyLegL(cx).contains(p) || _bodyLegR(cx).contains(p)) return 'Piernas';
    } else {
      if (_bodyArmL(cx).contains(p) || _bodyArmR(cx).contains(p)) return 'Brazos';
      if (_bodyTorso(cx).contains(p) || _bodyNeck(cx).contains(p)) return 'Espalda';
      if (_bodyLegL(cx).contains(p) || _bodyLegR(cx).contains(p)) return 'Piernas';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapUp: (d) {
            final zone = _hitTest(d.localPosition);
            if (zone != null) onTap(zone);
          },
          child: CustomPaint(
            size: const Size(_kW, _kH),
            painter: isBack
                ? _BodyPainterBack(zones)
                : _BodyPainterFront(zones),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isBack ? 'Posterior' : 'Anterior',
          style: const TextStyle(
              color: Colors.white38, fontSize: 11, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FRONT BODY PAINTER
// ═══════════════════════════════════════════════════════════════════════════════

class _BodyPainterFront extends CustomPainter {
  final List<_MuscleZone> zones;
  const _BodyPainterFront(this.zones);

  Color? _zoneColor(String name) {
    for (final z in zones) {
      if (z.name == name) return z.color.withValues(alpha: 0.50);
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 130, size.height / 280);
    const cx = 65.0;
    const base = Color(0xFF252525);

    final bold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.22);
    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65
      ..color = Colors.white.withValues(alpha: 0.11);

    void shade(Path path, String? zone, {bool subtle = false}) {
      canvas.drawPath(path, Paint()..style = PaintingStyle.fill..color = base);
      if (zone != null) {
        final c = _zoneColor(zone);
        if (c != null) {
          canvas.save();
          canvas.clipPath(path);
          final b = path.getBounds();
          canvas.drawRect(
            b,
            Paint()
              ..style = PaintingStyle.fill
              ..shader = LinearGradient(
                colors: [c, c.withValues(alpha: c.a * 0.15)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(b),
          );
          canvas.restore();
        }
      }
      canvas.drawPath(path, subtle ? soft : bold);
    }

    shade(_bodyLegL(cx), 'Piernas');
    shade(_bodyLegR(cx), 'Piernas');
    shade(_bodyTorso(cx), null);
    shade(_bodyPecL(cx), 'Pecho', subtle: true);
    shade(_bodyPecR(cx), 'Pecho', subtle: true);
    shade(_bodyAbsZone(cx), 'Core', subtle: true);
    shade(_bodyArmL(cx), 'Brazos');
    shade(_bodyArmR(cx), 'Brazos');
    shade(_bodyNeck(cx), null);
    shade(_bodyHead(cx), null);
    _frontDetails(canvas, cx, soft);
  }

  void _frontDetails(Canvas canvas, double cx, Paint p) {
    void ln(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    void pt(Path path) => canvas.drawPath(path, p);

    // Collarbones
    pt(Path()..moveTo(cx - 40, 62)..cubicTo(cx - 22, 57, cx - 10, 56, cx, 57));
    pt(Path()..moveTo(cx + 40, 62)..cubicTo(cx + 22, 57, cx + 10, 56, cx, 57));
    // Sternum
    ln(cx, 57, cx, 113);
    // Lower pec arcs
    pt(Path()..moveTo(cx - 2, 112)..cubicTo(cx - 12, 115, cx - 23, 113, cx - 28, 107));
    pt(Path()..moveTo(cx + 2, 112)..cubicTo(cx + 12, 115, cx + 23, 113, cx + 28, 107));
    // Abs vertical
    ln(cx, 115, cx, 165);
    // Abs horizontal bands (3 rows)
    for (int i = 0; i < 3; i++) {
      final y = 122.0 + i * 15;
      pt(Path()
        ..moveTo(cx - 18, y)
        ..cubicTo(cx - 9, y + 2, cx, y + 2, cx, y + 2)
        ..cubicTo(cx, y + 2, cx + 9, y + 2, cx + 18, y));
    }
    // Obliques
    pt(Path()..moveTo(cx - 20, 152)..cubicTo(cx - 25, 158, cx - 27, 163, cx - 28, 166));
    pt(Path()..moveTo(cx + 20, 152)..cubicTo(cx + 25, 158, cx + 27, 163, cx + 28, 166));
    // Deltoid arcs
    pt(Path()..moveTo(cx - 41, 64)..cubicTo(cx - 46, 72, cx - 47, 83, cx - 45, 93));
    pt(Path()..moveTo(cx + 41, 64)..cubicTo(cx + 46, 72, cx + 47, 83, cx + 45, 93));
    // Bicep–tricep separation
    ln(cx - 47, 92, cx - 44, 120);
    ln(cx + 47, 92, cx + 44, 120);
    // Forearm centerline
    ln(cx - 43, 132, cx - 41, 158);
    ln(cx + 43, 132, cx + 41, 158);
    // Neck SCM
    ln(cx - 4, 41, cx - 7, 51);
    ln(cx + 4, 41, cx + 7, 51);
    // Quad separation
    for (final s in [-1.0, 1.0]) {
      pt(Path()..moveTo(cx + s * 8, 174)..cubicTo(cx + s * 10, 194, cx + s * 12, 212, cx + s * 13, 228));
      pt(Path()..moveTo(cx + s * 25, 172)..cubicTo(cx + s * 26, 190, cx + s * 24, 210, cx + s * 22, 225));
    }
    // Kneecap ovals
    for (final s in [-1.0, 1.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + s * 18, 236), width: 16, height: 13), p);
    }
    // Gastrocnemius
    for (final s in [-1.0, 1.0]) {
      pt(Path()..moveTo(cx + s * 17, 246)..cubicTo(cx + s * 17, 258, cx + s * 16, 266, cx + s * 14, 273));
    }
    // Tibialis
    ln(cx - 9, 247, cx - 8, 271);
    ln(cx + 9, 247, cx + 8, 271);
  }

  @override
  bool shouldRepaint(covariant _BodyPainterFront old) => old.zones != zones;
}

// ═══════════════════════════════════════════════════════════════════════════════
// BACK BODY PAINTER
// ═══════════════════════════════════════════════════════════════════════════════

class _BodyPainterBack extends CustomPainter {
  final List<_MuscleZone> zones;
  const _BodyPainterBack(this.zones);

  Color? _zoneColor(String name) {
    for (final z in zones) {
      if (z.name == name) return z.color.withValues(alpha: 0.50);
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 130, size.height / 280);
    const cx = 65.0;
    const base = Color(0xFF252525);

    final bold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.22);
    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65
      ..color = Colors.white.withValues(alpha: 0.11);

    void shade(Path path, String? zone, {bool subtle = false}) {
      canvas.drawPath(path, Paint()..style = PaintingStyle.fill..color = base);
      if (zone != null) {
        final c = _zoneColor(zone);
        if (c != null) {
          canvas.save();
          canvas.clipPath(path);
          final b = path.getBounds();
          canvas.drawRect(
            b,
            Paint()
              ..style = PaintingStyle.fill
              ..shader = LinearGradient(
                colors: [c, c.withValues(alpha: c.a * 0.15)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(b),
          );
          canvas.restore();
        }
      }
      canvas.drawPath(path, subtle ? soft : bold);
    }

    // Back view: torso = Espalda, arms = Brazos, legs = Piernas
    shade(_bodyLegL(cx), 'Piernas');
    shade(_bodyLegR(cx), 'Piernas');
    shade(_bodyTorso(cx), 'Espalda');
    shade(_bodyArmL(cx), 'Brazos');
    shade(_bodyArmR(cx), 'Brazos');
    shade(_bodyNeck(cx), null);
    shade(_bodyHead(cx), null);
    _backDetails(canvas, cx, soft, bold);
  }

  void _backDetails(Canvas canvas, double cx, Paint soft, Paint bold) {
    void ln(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), soft);
    void pt(Path path) => canvas.drawPath(path, soft);

    // Spine
    ln(cx, 55, cx, 165);

    // Trapezius diamond: neck → shoulders → mid-back
    pt(Path()..moveTo(cx - 7, 51)..cubicTo(cx - 20, 55, cx - 38, 62, cx - 42, 70));
    pt(Path()..moveTo(cx + 7, 51)..cubicTo(cx + 20, 55, cx + 38, 62, cx + 42, 70));
    pt(Path()..moveTo(cx - 42, 70)..cubicTo(cx - 34, 92, cx - 18, 112, cx, 120));
    pt(Path()..moveTo(cx + 42, 70)..cubicTo(cx + 34, 92, cx + 18, 112, cx, 120));

    // Scapula (shoulder blade) hints
    pt(Path()..moveTo(cx - 20, 64)..cubicTo(cx - 26, 78, cx - 27, 96, cx - 22, 108));
    pt(Path()..moveTo(cx + 20, 64)..cubicTo(cx + 26, 78, cx + 27, 96, cx + 22, 108));

    // Lat outer curves (armpit → lower back)
    pt(Path()..moveTo(cx - 43, 78)..cubicTo(cx - 36, 104, cx - 30, 128, cx - 27, 148));
    pt(Path()..moveTo(cx + 43, 78)..cubicTo(cx + 36, 104, cx + 30, 128, cx + 27, 148));

    // Deltoid arcs
    pt(Path()..moveTo(cx - 41, 64)..cubicTo(cx - 46, 72, cx - 47, 83, cx - 45, 93));
    pt(Path()..moveTo(cx + 41, 64)..cubicTo(cx + 46, 72, cx + 47, 83, cx + 45, 93));

    // Tricep groove
    ln(cx - 47, 92, cx - 44, 128);
    ln(cx + 47, 92, cx + 44, 128);
    ln(cx - 43, 130, cx - 41, 160);
    ln(cx + 43, 130, cx + 41, 160);

    // Neck center
    ln(cx, 41, cx, 51);

    // Glute split
    ln(cx, 168, cx, 188);

    // Glute crease (top of glutes to leg sides)
    pt(Path()..moveTo(cx - 5, 168)..cubicTo(cx - 16, 173, cx - 28, 171, cx - 33, 167));
    pt(Path()..moveTo(cx + 5, 168)..cubicTo(cx + 16, 173, cx + 28, 171, cx + 33, 167));

    // Hamstring groove
    for (final s in [-1.0, 1.0]) {
      pt(Path()
          ..moveTo(cx + s * 18, 186)
          ..cubicTo(cx + s * 20, 206, cx + s * 21, 222, cx + s * 20, 236));
    }

    // Back of knee crease
    for (final s in [-1.0, 1.0]) {
      pt(Path()
          ..moveTo(cx + s * 12, 240)
          ..cubicTo(cx + s * 16, 242, cx + s * 22, 242, cx + s * 26, 240));
    }

    // Gastrocnemius split (same from back)
    for (final s in [-1.0, 1.0]) {
      pt(Path()
          ..moveTo(cx + s * 17, 248)
          ..cubicTo(cx + s * 17, 260, cx + s * 16, 267, cx + s * 14, 274));
    }
    ln(cx - 9, 248, cx - 8, 272);
    ln(cx + 9, 248, cx + 8, 272);
  }

  @override
  bool shouldRepaint(covariant _BodyPainterBack old) => old.zones != zones;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _ZoneChip extends StatelessWidget {
  final _MuscleZone zone;
  final VoidCallback onTap;
  const _ZoneChip({required this.zone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: zone.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: zone.color.withValues(alpha: 0.35), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: zone.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(zone.name,
                style: TextStyle(
                    color: zone.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int days;
  const _StreakBadge({required this.days});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.cardGrey, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        const Icon(Icons.local_fire_department, color: Color(0xFFFF6B6B), size: 18),
        const SizedBox(width: 4),
        Text('$days días',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  const _StatCard({required this.label, required this.value, required this.icon, required this.accent});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final String name;
  final int workoutsThisWeek;
  const _RoutineCard({required this.name, required this.workoutsThisWeek});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
            color: AppColors.neonGreen.withValues(alpha: 0.25), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.neonGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.fitness_center, color: AppColors.neonGreen, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Rutina de hoy',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            Text(name,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text('$workoutsThisWeek entrenos esta semana',
                style: const TextStyle(color: AppColors.neonGreen, fontSize: 12)),
          ]),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 15),
      ]),
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  final int consumed;
  final int target;
  const _CaloriesCard({required this.consumed, required this.target});
  @override
  Widget build(BuildContext context) {
    final pct = (consumed / target).clamp(0.0, 1.0);
    const purple = Color(0xFF6366F1);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.restaurant_menu, color: purple, size: 24),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Calorías de hoy',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: '$consumed',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: ' / $target kcal',
                    style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ]),
            ),
          ]),
          const Spacer(),
          Text('${(pct * 100).toInt()}%',
              style: const TextStyle(
                  color: purple, fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(purple),
          ),
        ),
      ]),
    );
  }
}
