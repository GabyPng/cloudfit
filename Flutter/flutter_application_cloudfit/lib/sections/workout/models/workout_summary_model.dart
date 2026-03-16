class WorkoutSummaryModel {
  final String duration;
  final int calories;
  final int totalWeight;
  final List<double> performanceData;

  WorkoutSummaryModel({
    required this.duration,
    required this.calories,
    required this.totalWeight,
    required this.performanceData,
  });
}