import 'package:flutter/material.dart';
import 'models/metric_model.dart';
import '../nutrition/models/nutrition_model.dart';
import '../../shared/widgets/skeleton.dart';
import 'package:flutter_application_cloudfit/shared/widgets/metric_card.dart';
import 'package:flutter_application_cloudfit/shared/widgets/food_card.dart';
import 'package:flutter_application_cloudfit/shared/widgets/weekly_chart.dart';
import '../../../core/constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isLoading = true;

  List<MetricModel> metrics = [];
  List<MealModel> foods = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      metrics = [
        MetricModel(title: "Ejercicio", value: 80, previousValue: 70),
        MetricModel(title: "Calorías", value: 2200, previousValue: 2000),
        MetricModel(title: "Peso", value: 72, previousValue: 73),
        MetricModel(title: "Pasos", value: 9000, previousValue: 8000),
      ];

      foods = [
        MealModel(
          title: "Desayuno",
          description: "Avena con fruta",
          time: "08:00 AM",
          calories: "350 kcal",
          imageUrl:
              "https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38",
          protein: 20,
          carbs: 40,
          fats: 10,
        ),
        MealModel(
          title: "Almuerzo",
          description: "Pollo con arroz",
          time: "02:00 PM",
          calories: "650 kcal",
          imageUrl:
              "https://images.unsplash.com/photo-1604908176997-431b3c59e1d1",
          protein: 40,
          carbs: 50,
          fats: 12,
        ),
      ];

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? Column(
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(height: 100, width: 70),
                      SkeletonBox(height: 100, width: 70),
                      SkeletonBox(height: 100, width: 70),
                      SkeletonBox(height: 100, width: 70),
                    ],
                  ),
                  SizedBox(height: 20),
                  SkeletonBox(height: 200, width: double.infinity),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// METRICAS
                    Row(
                      children: metrics
                          .map((m) => MetricCard(metric: m))
                          .toList(),
                    ),

                    const SizedBox(height: 20),

                    /// GRAFICA
                    const Text(
                      "Semana",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const WeeklyChart(
                      data: [2000, 2300, 1800, 2500, 2700, 2200, 3000],
                    ),

                    const SizedBox(height: 20),

                    /// COMIDA
                    const Text(
                      "Comida de Hoy",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Column(
                      children:
                          foods.map((f) => FoodCard(food: f)).toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}