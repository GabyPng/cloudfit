import 'package:flutter/material.dart';
import 'package:flutter_application_cloudfit/sections/progress/models/progress_data.dart';
import '../../../../core/constants.dart';

class ProgressScreen extends StatelessWidget {
  static const String name = 'progress_screen';

  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para la gráfica
    final weightData = [
      ProgressPoint(value: 80, label: "Ene"),
      ProgressPoint(value: 78, label: "Feb"),
      ProgressPoint(value: 79, label: "Mar"),
      ProgressPoint(value: 75, label: "Abr"),
      ProgressPoint(value: 74, label: "May"),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Progreso Físico", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildStatCards(),
            const SizedBox(height: 30),
            _buildChartSection("Evolución de Peso", weightData, AppColors.neonGreen),
            const SizedBox(height: 25),
            _buildChartSection("Grasa Corporal (%)", weightData, AppColors.electricPurple),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        _miniStat("Peso Inicial", "82 kg", Icons.history),
        const SizedBox(width: 15),
        _miniStat("Meta", "70 kg", Icons.flag_rounded),
      ],
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white38, size: 18),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, List<ProgressPoint> data, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(data: data, color: color),
            ),
          ),
          const SizedBox(height: 15),
          _buildChartLabels(data),
        ],
      ),
    );
  }

  Widget _buildChartLabels(List<ProgressPoint> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: data.map((p) => Text(p.label, style: const TextStyle(color: Colors.white38, fontSize: 10))).toList(),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<ProgressPoint> data;
  final Color color;

  LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2); // Brillo

    final path = Path();
    final double stepX = size.width / (data.length - 1);
    final double maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final double minVal = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < data.length; i++) {
      // Normalización de valores al alto del canvas
      double x = i * stepX;
      double y = size.height - ((data[i].value - minVal) / (maxVal - minVal) * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Dibujar punto neón
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = color);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}