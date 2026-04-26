import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';
import 'models/exercise_model.dart';

class ExerciseDetailScreen extends StatefulWidget {
  static const String name = 'exercise_detail';

  final List<RoutineExercise>? exercises;
  final int currentIndex;

  const ExerciseDetailScreen({
    super.key,
    this.exercises,
    this.currentIndex = 0,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;
  late int _seconds;
  bool _isRunning = false;
  final Set<int> _markedSets = {};
  bool _isSaving = false;

  RoutineExercise? get _currentExercise {
    final list = widget.exercises;
    if (list == null || list.isEmpty) return null;
    if (widget.currentIndex >= list.length) return null;
    return list[widget.currentIndex];
  }

  bool get _isLastExercise {
    final list = widget.exercises;
    if (list == null) return true;
    return widget.currentIndex >= list.length - 1;
  }

  int get _totalExercises => widget.exercises?.length ?? 0;
  int get _restSeconds {
    final rt = _currentExercise?.restTime ?? '';
    final match = RegExp(r'\d+').firstMatch(rt);
    return match != null ? int.parse(match.group(0)!) : 90;
  }

  @override
  void initState() {
    super.initState();
    _seconds = _restSeconds;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _restSeconds),
    );
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _animationController.reverse(
      from: _animationController.value == 0.0 ? 1.0 : _animationController.value,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _pauseTimer();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _animationController.stop();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    _animationController.value = 1.0;
    setState(() => _seconds = _restSeconds);
  }

  void _toggleSet(int setIndex) {
    setState(() {
      if (_markedSets.contains(setIndex)) {
        _markedSets.remove(setIndex);
      } else {
        _markedSets.add(setIndex);
        _resetTimer();
        _startTimer();
      }
    });
  }

  Future<void> _finishWorkout() async {
    setState(() => _isSaving = true);
    try {
      final supabase = Supabase.instance.client;
      final authId = supabase.auth.currentUser?.id;
      if (authId != null) {
        final userData = await supabase
            .from('users')
            .select('user_id')
            .eq('supabase_id', authId)
            .single();
        final clientId = userData['user_id'];

        final routineId = _currentExercise?.routineId;
        await supabase.from('workout_logs').insert({
          'client_id': clientId,
          if (routineId != null) 'routine_id': routineId,
          'date': DateTime.now().toIso8601String().split('T').first,
          'is_complete': true,
        });
      }
    } catch (_) {
      // fail silently — still navigate
    }
    if (mounted) context.go('/cliente/summary');
  }

  void _goToNext() {
    context.pushReplacement(
      '/cliente/exercise-detail',
      extra: {
        'exercises': widget.exercises,
        'index': widget.currentIndex + 1,
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ex = _currentExercise;
    final exerciseName = ex?.exerciseName.toUpperCase() ?? 'PRESS BANCA';
    final setsCount = ex?.sets ?? 2;
    final reps = ex?.reps ?? '10';
    final routineName = ex?.routineName ?? 'Rutina personalizada';

    final indexLabel = _totalExercises > 0
        ? 'Ejercicio ${widget.currentIndex + 1} de $_totalExercises'
        : 'Ejercicio demo';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          routineName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoPreview(),
            const SizedBox(height: 25),
            Text(
              exerciseName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              indexLabel,
              style: const TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 25),
            const Text(
              'SETS',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 15),
            ...List.generate(setsCount, (i) => _buildSetCard(i, reps)),
            const SizedBox(height: 20),
            _buildRestTimer(),
            const SizedBox(height: 30),
            _buildBottomActions(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.play_arrow_outlined, color: AppColors.neonGreen, size: 80),
          Positioned(
            bottom: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Presiona para ver técnica',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetCard(int setIndex, String reps) {
    final marked = _markedSets.contains(setIndex);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: marked
            ? AppColors.neonGreen.withValues(alpha: 0.10)
            : AppColors.cardGrey,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: marked
              ? AppColors.neonGreen.withValues(alpha: 0.60)
              : Colors.white12,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SET ${setIndex + 1}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: marked ? AppColors.neonGreen : Colors.white,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$reps reps',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _toggleSet(setIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: marked ? AppColors.neonGreen : Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        marked ? Icons.check_rounded : Icons.radio_button_unchecked,
                        color: marked ? Colors.black : Colors.white54,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        marked ? 'HECHO' : 'MARCAR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: marked ? Colors.black : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text(
            'DESCANSO',
            style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => CustomPaint(
                    painter: CircularProgressPainter(
                      progress: _animationController.value,
                      color: AppColors.neonGreen,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(
                      _isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    ),
                    iconSize: 46,
                    color: Colors.white,
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: _resetTimer,
            child: const Text(
              'REINICIAR',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final allMarked = _currentExercise != null &&
        _markedSets.length >= (_currentExercise!.sets);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isSaving ? null : _finishWorkout,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'FINALIZAR',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
        if (!_isLastExercise) ...[
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: allMarked ? _goToNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: allMarked ? AppColors.neonGreen : Colors.white12,
                minimumSize: const Size(0, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'SIGUIENTE',
                style: TextStyle(
                  color: allMarked ? Colors.black : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, circlePaint);

    final angle = 2 * 3.14159265 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
