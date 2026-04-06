import 'dart:async'; // Necesario para el Timer
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants.dart';

class ExerciseDetailScreen extends StatefulWidget {
  static const String name = 'exercise_detail';
  const ExerciseDetailScreen({super.key});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;
  int _seconds = 90;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // La animación dura lo mismo que el temporizador (90 seg)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    );
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);

    _animationController.reverse(
      from: _animationController.value == 0.0
          ? 1.0
          : _animationController.value,
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
    setState(() => _seconds = 90);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose(); // Limpieza de controladores
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "PECHO Y TRÍCEPS",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
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
            const Text(
              "PRESS BANCA",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const Text(
              "Ejercicio 1 de 8",
              style: TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 25),
            const Text(
              "SETS",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 15),
            _buildSetCard(1, "60", "12"),
            _buildSetCard(2, "65", "10"),
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
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.play_arrow_outlined, color: AppColors.neonGreen, size: 80),
          Positioned(
            bottom: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Presiona para ver técnica",
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetCard(int setNum, String weight, String reps) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SET $setNum",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              _buildSmallButton("MARCAR", Colors.white12),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildInputControl("PESO (KG)", weight)),
              const SizedBox(width: 15),
              Expanded(child: _buildInputControl("REPS", reps)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputControl(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.remove, color: AppColors.neonGreen, size: 18),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.add, color: AppColors.neonGreen, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  // Actualización del widget del Temporizador
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
            "DESCANSO",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              // El anillo de progreso animado
              SizedBox(
                width: 180,
                height: 180,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CircularProgressPainter(
                        progress: _animationController.value,
                        color: AppColors.neonGreen,
                      ),
                    );
                  },
                ),
              ),
              // El texto del tiempo central
              Column(
                children: [
                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isRunning
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                    ),
                    iconSize: 50,
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
              "REINICIAR",
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            // Al presionar finalizar, navegamos al resumen
            onTap: () => context.push('/cliente/summary'),
            child: _buildSmallButton("FINALIZAR", Colors.white10, height: 60),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Aquí podrías programar el salto al siguiente ejercicio de la lista
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              minimumSize: const Size(0, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "SIGUIENTE",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton(String text, Color color, {double height = 35}) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3); // Efecto Neón

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    // Dibujar fondo gris suave
    canvas.drawCircle(center, radius, circlePaint);

    // Dibujar arco de progreso
    double angle = 2 * 3.14159265 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2, // Empezar arriba (-90 grados)
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
