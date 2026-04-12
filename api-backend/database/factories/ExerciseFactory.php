<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class ExerciseFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $exercises = [
            ['name' => 'Flexiones', 'category' => 'Brazos', 'difficulty' => 'beginner'],
            ['name' => 'Sentadillas', 'category' => 'Piernas', 'difficulty' => 'intermediate'],
            ['name' => 'Dominadas', 'category' => 'Espalda', 'difficulty' => 'advanced'],
            ['name' => 'Press de Banca', 'category' => 'Pecho', 'difficulty' => 'intermediate'],
            ['name' => 'Peso Muerto', 'category' => 'Espalda', 'difficulty' => 'advanced'],
            ['name' => 'Burpees', 'category' => 'Cardio', 'difficulty' => 'advanced'],
            ['name' => 'Planchas', 'category' => 'Core', 'difficulty' => 'beginner'],
            ['name' => 'Curl de Bíceps', 'category' => 'Brazos', 'difficulty' => 'beginner'],
        ];

        $exercise = $this->faker->randomElement($exercises);

        return [
            'name' => $exercise['name'],
            'category' => $exercise['category'],
            'description' => $this->faker->sentence(),
            'image_url' => null,
            'sets' => $this->faker->numberBetween(3, 5),
            'reps' => $this->faker->numberBetween(5, 15),
            'difficulty' => $exercise['difficulty'],
            'duration' => $this->faker->numberBetween(15, 60),
            'instructions' => $this->faker->paragraphs(2, true),
        ];
    }
}
