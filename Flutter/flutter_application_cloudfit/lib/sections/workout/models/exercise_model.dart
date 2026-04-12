class Exercise {
  final int id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final int sets;
  final int reps;
  final String difficulty;
  final int duration;
  final String instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.sets,
    required this.reps,
    required this.difficulty,
    required this.duration,
    required this.instructions,
  });

  /// Convertir JSON de Supabase a modelo Exercise
  factory Exercise.fromJson(Map<String, dynamic> json) {
    final String name = (json['name'] ?? '').toLowerCase();
    String imageUrl = (json['imageUrl'] ?? '').toString().trim();
    
    // Si no tiene imageUrl, asignar uno automático basado en el nombre
    if (imageUrl.isEmpty) {
      if (name.contains('dominada')) {
        imageUrl = 'assets/images/Dominada.jpg';
      } else if (name.contains('flexion')) {
        imageUrl = 'assets/images/Flexiones.webp';
      } else if (name.contains('sentadilla')) {
        imageUrl = 'assets/images/Sentadilla.jpg';
      } else if (name.contains('jona')) {
        imageUrl = 'assets/images/Jona.png';
      } else if (name.contains('efra')) {
        imageUrl = 'assets/images/Efra.jpg';
      } else {
        imageUrl = 'assets/images/Dominada.jpg'; // default
      }
    }
    
    return Exercise(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: imageUrl,
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
      difficulty: json['difficulty'] ?? 'Intermedio',
      duration: json['duration'] ?? 60,
      instructions: json['instructions'] ?? '',
    );
  }

  /// Convertir modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'sets': sets,
      'reps': reps,
      'difficulty': difficulty,
      'duration': duration,
      'instructions': instructions,
    };
  }
}
