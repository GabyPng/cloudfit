<?php

namespace Database\Seeders;

use App\Models\Client;
use App\Models\Coach;
use App\Models\Nutriologo;
use App\Models\NutritionPlan;
use App\Models\NutritionPlanAssignment;
use App\Models\NutritionPlanMeal;
use App\Models\Progress;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Faker\Factory as Faker;

class Nutri1SpecificSeeder extends Seeder
{
    public function run(): void
    {
        $faker = Faker::create('es_ES');
        $password = Hash::make('password123');
        
        $clientRoleId = Role::query()->where('name', 'cliente')->value('role_id');
        $coachRoleId = Role::query()->where('name', 'coach')->value('role_id');
        
        // Find massive.nutri1@cloudfit.test
        $nutriUser = User::where('email', 'massive.nutri1@cloudfit.test')->first();
        if (!$nutriUser) {
            $this->command->error("No se encontro massive.nutri1@cloudfit.test");
            return;
        }
        
        $nutriProfile = Nutriologo::where('user_id', $nutriUser->id)->first();
        if (!$nutriProfile) {
            $this->command->error("El usuario massive.nutri1 no tiene perfil de nutriologo");
            return;
        }

        $this->command->info("Creando planes detallados para massive.nutri1...");

        // Create Detailed Plans
        $plansData = [
            [
                'title' => 'Definición Extrema 1500 kcal',
                'goal' => 'Pérdida de peso',
                'daily_calories' => 1500,
                'meals' => [
                    ['type' => 'desayuno', 'name' => 'Claras con espinaca y avena', 'cals' => 300, 'p' => 25, 'c' => 35, 'f' => 5],
                    ['type' => 'colacion_1', 'name' => 'Manzana con almendras', 'cals' => 150, 'p' => 3, 'c' => 20, 'f' => 8],
                    ['type' => 'comida', 'name' => 'Pechuga asada con verduras', 'cals' => 450, 'p' => 45, 'c' => 40, 'f' => 10],
                    ['type' => 'cena', 'name' => 'Ensalada de atún', 'cals' => 350, 'p' => 30, 'c' => 15, 'f' => 15],
                ]
            ],
            [
                'title' => 'Volumen Limpio 2800 kcal',
                'goal' => 'Aumento de masa muscular',
                'daily_calories' => 2800,
                'meals' => [
                    ['type' => 'desayuno', 'name' => 'Huevos enteros, pan y plátano', 'cals' => 600, 'p' => 30, 'c' => 65, 'f' => 20],
                    ['type' => 'comida', 'name' => 'Bistec de res con arroz', 'cals' => 800, 'p' => 50, 'c' => 90, 'f' => 25],
                    ['type' => 'colacion_1', 'name' => 'Batido de proteína y crema de maní', 'cals' => 450, 'p' => 40, 'c' => 30, 'f' => 20],
                    ['type' => 'cena', 'name' => 'Salmón con papa asada', 'cals' => 700, 'p' => 45, 'c' => 55, 'f' => 30],
                ]
            ],
            [
                'title' => 'Recomposición Corporal 2000 kcal',
                'goal' => 'Recomposición corporal',
                'daily_calories' => 2000,
                'meals' => [
                    ['type' => 'desayuno', 'name' => 'Yogurt griego con berries', 'cals' => 350, 'p' => 22, 'c' => 45, 'f' => 5],
                    ['type' => 'comida', 'name' => 'Pollo teriyaki y arroz', 'cals' => 650, 'p' => 45, 'c' => 70, 'f' => 15],
                    ['type' => 'cena', 'name' => 'Pavo molido con calabacitas', 'cals' => 450, 'p' => 40, 'c' => 20, 'f' => 20],
                ]
            ],
        ];

        $createdPlans = [];
        foreach ($plansData as $pd) {
            $plan = NutritionPlan::firstOrCreate(
                ['nutriologo_id' => $nutriProfile->id, 'title' => $pd['title']],
                [
                    'description' => 'Plan diseñado automáticamente para resultados óptimos.',
                    'goal' => $pd['goal'],
                    'daily_calories' => $pd['daily_calories'],
                    'is_active' => true,
                    'starts_at' => now()->toDateString(),
                ]
            );
            $createdPlans[] = $plan->id;

            // Delete old meals if any
            $plan->meals()->delete();
            foreach ($pd['meals'] as $index => $m) {
                NutritionPlanMeal::create([
                    'nutrition_plan_id' => $plan->id,
                    'meal_type' => $m['type'],
                    'name' => $m['name'],
                    'portion' => 'Porción calculada',
                    'calories' => $m['cals'],
                    'protein_g' => $m['p'],
                    'carbs_g' => $m['c'],
                    'fat_g' => $m['f'],
                    'position' => $index,
                ]);
            }
        }

        $coaches = Coach::pluck('user_id')->toArray();
        if (empty($coaches)) {
            $coaches = [null];
        }

        $this->command->info("Creando 100 pacientes para massive.nutri1...");

        for ($i = 0; $i < 100; $i++) {
            $email = "nutri1.paciente{$i}@cloudfit.test";
            $user = User::firstOrCreate(
                ['email' => $email],
                [
                    'name' => $faker->name,
                    'password' => $password,
                    'role_id' => $clientRoleId,
                    'email_verified_at' => now(),
                    'objective' => $faker->randomElement(['Competencia', 'Salud general', 'Bajar talla', 'Aumentar fuerza']),
                ]
            );

            Client::firstOrCreate(
                ['user_id' => $user->id],
                [
                    'coach_id' => $faker->randomElement($coaches),
                    'nutritionist_id' => $nutriUser->id,
                    'birth_date' => $faker->date('Y-m-d', '-20 years'),
                    'height' => $faker->randomFloat(2, 1.55, 1.90),
                    'goal' => $faker->randomElement(['Bajar de peso', 'Ganar masa muscular', 'Recomposición corporal']),
                ]
            );

            $randomPlanId = $faker->randomElement($createdPlans);
            
            // Randomly set status to have active, paused, cancelled, completed
            $status = $faker->randomElement(['active', 'active', 'active', 'active', 'paused', 'completed', 'cancelled']);

            NutritionPlanAssignment::firstOrCreate(
                [
                    'nutrition_plan_id' => $randomPlanId,
                    'client_id' => $user->id,
                ],
                [
                    'nutriologo_id' => $nutriProfile->id,
                    'status' => $status,
                    'assigned_at' => now()->subDays($faker->numberBetween(1, 60))->toDateString(),
                    'updated_at' => now()->subHours($faker->numberBetween(1, 72)),
                ]
            );

            // Progress tracking
            $progressCount = $faker->numberBetween(4, 12);
            $startWeight = $faker->randomFloat(2, 65, 100);
            $isLosing = $status === 'completed' || $faker->boolean(70);

            for ($p = 0; $p < $progressCount; $p++) {
                if ($isLosing) {
                    $startWeight -= $faker->randomFloat(2, 0.2, 1.0);
                } else {
                    $startWeight += $faker->randomFloat(2, 0.2, 1.0);
                }

                Progress::create([
                    'client_id' => $user->id,
                    'weight' => $startWeight,
                    'body_fat' => $faker->randomFloat(2, 12, 30),
                    'bmi' => $startWeight / (1.7 * 1.7), 
                    'date' => now()->subWeeks($progressCount - $p)->toDateString(),
                ]);
            }
        }

        $this->command->info("¡Nutri1SpecificSeeder completado con éxito!");
    }
}
