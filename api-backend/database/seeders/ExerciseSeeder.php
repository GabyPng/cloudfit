<?php

namespace Database\Seeders;

use App\Models\Exercise;
use Illuminate\Database\Seeder;

class ExerciseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Exercise::create([
            'name' => 'Flexiones',
            'category' => 'Brazos',
            'description' => 'Ejercicio básico para el pecho, hombros y tríceps usando el peso corporal.',
            'image_url' => null,
            'sets' => 3,
            'reps' => 10,
            'difficulty' => 'beginner',
            'duration' => 20,
            'instructions' => 'Coloca las manos al ancho de los hombros. Baja el cuerpo hasta que el pecho casi toque el suelo. Sube nuevamente.',
        ]);

        Exercise::create([
            'name' => 'Dominada',
            'category' => 'Espalda',
            'description' => 'Ejercicio de tracción que trabaja espalda, brazos y core.',
            'image_url' => null,
            'sets' => 3,
            'reps' => 8,
            'difficulty' => 'advanced',
            'duration' => 25,
            'instructions' => 'Cuelga de una barra con las manos al ancho de los hombros. Tira hacia arriba hasta que la barbilla supere la barra. Baja controladamente.',
        ]);

        Exercise::create([
            'name' => 'Sentadilla',
            'category' => 'Piernas',
            'description' => 'Movimiento fundamental para piernas y glúteos.',
            'image_url' => null,
            'sets' => 4,
            'reps' => 12,
            'difficulty' => 'intermediate',
            'duration' => 30,
            'instructions' => 'De pie con pies al ancho de hombros. Baja flexionando rodillas y cadera. Sube manteniendo la espalda recta.',
        ]);

        Exercise::create([
            'name' => 'Press de Banca',
            'category' => 'Pecho',
            'description' => 'Ejercicio con peso para pecho, hombros y tríceps.',
            'image_url' => null,
            'sets' => 4,
            'reps' => 8,
            'difficulty' => 'intermediate',
            'duration' => 30,
            'instructions' => 'Acuéstate en la banca. Baja la barra a la altura del pecho. Empuja hacia arriba hasta extender los brazos.',
        ]);

        Exercise::create([
            'name' => 'Peso Muerto',
            'category' => 'Espalda',
            'description' => 'Movimiento compuesto que trabaja espalda baja, glúteos y piernas.',
            'image_url' => null,
            'sets' => 3,
            'reps' => 5,
            'difficulty' => 'advanced',
            'duration' => 25,
            'instructions' => 'De pie frente a la barra. Baja manteniendo la espalda recta. Levanta con potencia.',
        ]);

        Exercise::create([
            'name' => 'Planchas',
            'category' => 'Core',
            'description' => 'Ejercicio isométrico para fortalecer el core.',
            'image_url' => null,
            'sets' => 3,
            'reps' => null,
            'difficulty' => 'beginner',
            'duration' => 30,
            'instructions' => 'Posición de flexión apoyado en antebrazos. Mantén el cuerpo recto durante 30-60 segundos.',
        ]);

        Exercise::create([
            'name' => 'Burpees',
            'category' => 'Cardio',
            'description' => 'Ejercicio funcional de alta intensidad.',
            'image_url' => null,
            'sets' => 3,
            'reps' => 10,
            'difficulty' => 'advanced',
            'duration' => 20,
            'instructions' => 'De pie, baja en posición de flexión, da un salto, vuelve a bajar y salta hacia arriba.',
        ]);

        Exercise::create([
            'name' => 'Curl de Bíceps',
            'category' => 'Brazos',
            'description' => 'Ejercicio de aislamiento para bíceps.',
            'image_url' => null,
            'sets' => 3,
            'reps' => 12,
            'difficulty' => 'beginner',
            'duration' => 20,
            'instructions' => 'De pie con mancuernas. Flexiona los codos subiendo las mancuernas hacia los hombros.',
        ]);
    }
}
