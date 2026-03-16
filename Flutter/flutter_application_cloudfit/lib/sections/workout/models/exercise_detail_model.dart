class ExerciseDetailModel {
  final String name;
  final String description;
  final String videoUrl; // Placeholder para el video
  final List<String> steps;
  final String musclesTargeted;

  ExerciseDetailModel({
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.steps,
    required this.musclesTargeted,
  });
}