class MetricModel {
  final String title;
  final double value;
  final double previousValue;

  MetricModel({
    required this.title,
    required this.value,
    required this.previousValue,
  });

  double get percentageChange {
    if (previousValue == 0) return 0;
    return ((value - previousValue) / previousValue) * 100;
  }

  bool get isPositive => percentageChange >= 0;
}