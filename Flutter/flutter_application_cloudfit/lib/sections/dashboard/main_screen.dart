import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'models/metric_model.dart';

class MainScreen extends StatelessWidget {
  static const String name = 'home_screen';

  MainScreen({super.key});

  final List<MetricModel> metrics = [
    MetricModel(
      title: "Ejercicio",
      value: "4 hrs",
      unit: "",
      gradient: AppColors.greenGradient,
      icon: Icons.fitness_center,
    ),
    MetricModel(
      title: "Calorías",
      value: "1800",
      unit: "kcal",
      
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8A8A)],
      ),
      icon: Icons.local_fire_department,
    ),
    MetricModel(
      title: "Pesos",
      value: "5000",
      unit: "reps",
      gradient: AppColors.purpleGradient,
      icon: Icons.straighten,
    ),
    MetricModel(
      title: "Pasos",
      value: "12000",
      unit: "steps",
      gradient: null,
      icon: Icons.directions_walk,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _buildHeader(),
              const SizedBox(height: 25),
              const Text(
                "Días Trabajados",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildDateRow(),
              const SizedBox(height: 25),
              const Text(
                "Últimos Resultados",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildMetricGrid(),
              const SizedBox(height: 25),
              _buildBarChart(), // <--- Insertar aquí
              const SizedBox(height: 25),
              _buildFoodSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200',
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, Daniel",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const Text(
              "Bienvenido!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.search, color: Colors.white70),
        const SizedBox(width: 15),
        const Icon(Icons.notifications_none, color: Colors.white70),
      ],
    );
  }

  Widget _buildDateRow() {
    final days = ["9", "10", "11", "14", "13", "12"];
    final labels = ["LUN", "MAR", "MIE", "JUE", "VIE", "SAB"];

    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 2;
          return Container(
            width: 50,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.electricPurple : AppColors.cardGrey,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  labels[index],
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6, // Ajustado para que las tarjetas sean más bajas
      ),
      itemBuilder: (context, index) => _metricCard(metrics[index]),
    );
  }

  Widget _metricCard(MetricModel item) {
    final isDark = item.gradient == null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardGrey : null,
        gradient: item.gradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            size: 18,
            color: isDark ? AppColors.neonGreen : Colors.black87,
          ),
          const Spacer(),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            "${item.value} ${item.unit}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBarChart() {
    final days = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Progreso de Objetivos",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              DropdownButton<String>(
                value: 'Semanal',
                items: ['Semanal', 'Mensual'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (_) {},
                underline: const SizedBox(),
                dropdownColor: AppColors.cardGrey,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((day) => _chartBarGroup(day)).toList(),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _chartBarGroup(String label) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _singleBar(40, AppColors.neonGreen), // Ejercicio
            const SizedBox(width: 2),
            _singleBar(60, const Color(0xFFFF6B6B)), // Calorías 
            const SizedBox(width: 2),
            _singleBar(30, AppColors.electricPurple), // Pasos
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _singleBar(double height, Color color) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _legendItem("Ejercicio", AppColors.neonGreen),
        const SizedBox(width: 15),
        _legendItem("Calorías", const Color(0xFFFF6B6B)),
        const SizedBox(width: 15),
        _legendItem("Pasos", AppColors.electricPurple),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 3, backgroundColor: color),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
  Widget _buildFoodSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Comida", 
        style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _foodItem("Burrito", "Pizza Burger", "01:00 AM", "20 gm", 
          "https://images.unsplash.com/photo-1584030373081-f37b7bb4fa8e?q=80&w=100"),
      const SizedBox(height: 8),
      _foodItem("Burger", "Pizza Burger", "01:00 AM", "20 gm", 
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=100"),
    ],
  );
}

Widget _foodItem(String name, String collation, String time, String weight, String url) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.cardGrey,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(url),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(time, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(collation, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(weight, style: const TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
}
}
