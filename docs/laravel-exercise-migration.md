# Migración de Catálogo de Ejercicios a Laravel

## Resumen de cambios

Se ha migrado la funcionalidad del catálogo de ejercicios de Supabase (Flutter) a Laravel backend.

### Archivos creados:

1. **Migración**: `database/migrations/2026_04_11_000000_create_exercises_table.php`
   - Tabla `exercises` con campos: name, category, description, image_url, sets, reps, difficulty, duration, instructions

2. **Modelo**: `app/Models/Exercise.php`
   - Modelo Eloquent con transformación personalizada de camelCase
   - Conversión de `image_url` → `imageUrl` para compatibilidad con Flutter

3. **Controlador**: `app/Http/Controllers/ExerciseController.php`
   - `GET /api/exercises` - Obtener todos los ejercicios
   - `GET /api/exercises/{id}` - Obtener ejercicio por ID
   - `GET /api/exercises/category/{category}` - Filtrar por categoría
   - `GET /api/exercises/difficulty/{difficulty}` - Filtrar por dificultad

4. **Rutas**: `routes/api/exercises.php`
   - Rutas públicas (sin autenticación requerida)

5. **Factory**: `database/factories/ExerciseFactory.php`
   - Generador de datos aleatorios para testing

6. **Seeder**: `database/seeders/ExerciseSeeder.php`
   - 8 ejercicios predefinidos listos para cargar

## Pasos para ejecutar

### 1. Ejecutar migraciones
```bash
cd c:\Cloudfit\cloudfit\api-backend
php artisan migrate
```

### 2. Cargar datos iniciales (seeder)
```bash
php artisan db:seed
```

### 3. Verificar que funciona
```bash
php artisan serve
```

Luego, visita en tu navegador:
- `http://localhost:8000/api/exercises` - Todos los ejercicios

## Cambios en Flutter para usar Laravel

Crea un nuevo servicio `lib/core/services/exercise_service_laravel.dart`:

```dart
import 'package:http/http.dart' as http;

class ExerciseServiceLaravel {
  static const String apiUrl = 'http://localhost:8000/api/exercises';

  static Future<List<Exercise>> getAllExercises() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['data'] ?? [];
        return data.map((e) => Exercise.fromJson(e)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Stream<List<Exercise>> getExercisesStream() async* {
    while (true) {
      try {
        yield await getAllExercises();
        await Future.delayed(Duration(seconds: 30));
      } catch (e) {
        yield [];
        await Future.delayed(Duration(seconds: 30));
      }
    }
  }
}
```

## Consideraciones

- Los endpoints `/api/exercises` son **públicos** (sin autenticación)
- Si necesitas protegerlos, agrega middleware:
  ```php
  Route::middleware('supabase.auth')
      ->prefix('exercises')
      ->group(base_path('routes/api/exercises.php'));
  ```
- El modelo transforma automáticamente `image_url` → `imageUrl` para mantener compatibilidad con Flutter
- Todos los ejercicios ordensados por nombre alfabético
