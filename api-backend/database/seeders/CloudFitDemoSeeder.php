<?php

namespace Database\Seeders;

use App\Models\Nutriologo;
use App\Models\NutritionPlan;
use App\Models\NutritionPlanAssignment;
use App\Models\NutritionPlanMeal;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class CloudFitDemoSeeder extends Seeder
{
    public function run(): void
    {
        $password = Hash::make('password');

        $adminRoleId = Role::query()->where('name', 'admin')->value('role_id');
        $coachRoleId = Role::query()->where('name', 'coach')->value('role_id');
        $nutriRoleId = Role::query()->where('name', 'nutriologo')->value('role_id');
        $clientRoleId = Role::query()->where('name', 'cliente')->value('role_id');

        $admin = User::query()->updateOrCreate(
            ['email' => 'admin.demo@cloudfit.test'],
            [
                'name' => 'Admin Demo',
                'password' => $password,
                'role_id' => $adminRoleId,
                'email_verified_at' => now(),
            ]
        );

        $coach = User::query()->updateOrCreate(
            ['email' => 'coach.demo@cloudfit.test'],
            [
                'name' => 'Carlos Coach',
                'password' => $password,
                'role_id' => $coachRoleId,
                'email_verified_at' => now(),
            ]
        );

        $nutriUser = User::query()->updateOrCreate(
            ['email' => 'nutri.demo@cloudfit.test'],
            [
                'name' => 'Nancy Nutri',
                'password' => $password,
                'role_id' => $nutriRoleId,
                'email_verified_at' => now(),
            ]
        );

        DB::table('admins')->updateOrInsert(
            ['user_id' => $admin->id],
            ['updated_at' => now(), 'created_at' => now()]
        );

        DB::table('coaches')->updateOrInsert(
            ['user_id' => $coach->id],
            ['updated_at' => now(), 'created_at' => now()]
        );

        $nutriologo = Nutriologo::query()->updateOrCreate(
            ['user_id' => $nutriUser->id],
            [
                'license_number' => 'NUTRI-DEMO-001',
                'focus' => 'Pérdida de grasa y recomposición',
                'certificate_uploads' => null,
            ]
        );

        $clients = [
            [
                'email' => 'cliente.ana@cloudfit.test',
                'name' => 'Ana López',
                'goal' => 'Bajar porcentaje de grasa',
                'height' => 1.64,
                'birth_date' => '1998-04-12',
            ],
            [
                'email' => 'cliente.mario@cloudfit.test',
                'name' => 'Mario Pérez',
                'goal' => 'Ganar masa muscular',
                'height' => 1.78,
                'birth_date' => '1995-09-01',
            ],
            [
                'email' => 'cliente.sofia@cloudfit.test',
                'name' => 'Sofía Ramírez',
                'goal' => 'Mejorar hábitos alimenticios',
                'height' => 1.60,
                'birth_date' => '2000-01-20',
            ],
        ];

        $clientUsers = collect($clients)->map(function (array $client) use ($password, $clientRoleId, $coach, $nutriUser) {
            $user = User::query()->updateOrCreate(
                ['email' => $client['email']],
                [
                    'name' => $client['name'],
                    'password' => $password,
                    'role_id' => $clientRoleId,
                    'email_verified_at' => now(),
                ]
            );

            DB::table('clients')->updateOrInsert(
                ['user_id' => $user->id],
                [
                    'coach_id' => $coach->id,
                    'nutritionist_id' => $nutriUser->id,
                    'birth_date' => $client['birth_date'],
                    'height' => $client['height'],
                    'goal' => $client['goal'],
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );

            return $user;
        });

        $routineDefinitions = [
            [
                'client_email' => 'cliente.ana@cloudfit.test',
                'name' => 'Fuerza Tren Inferior',
                'description' => 'Rutina enfocada en glúteo y pierna',
                'is_active' => true,
                'exercises' => [
                    ['exercise_name' => 'Sentadilla Goblet', 'sets' => 4, 'reps' => '10-12', 'rest_time' => '90 seg', 'notes' => 'Controla la bajada'],
                    ['exercise_name' => 'Hip Thrust', 'sets' => 4, 'reps' => '12', 'rest_time' => '75 seg', 'notes' => 'Pausa arriba'],
                    ['exercise_name' => 'Peso Muerto Rumano', 'sets' => 3, 'reps' => '10', 'rest_time' => '90 seg', 'notes' => 'Espalda neutra'],
                ],
            ],
            [
                'client_email' => 'cliente.mario@cloudfit.test',
                'name' => 'Torso Hipertrofia',
                'description' => 'Rutina de empuje y jalón para hipertrofia',
                'is_active' => true,
                'exercises' => [
                    ['exercise_name' => 'Press de Banca', 'sets' => 4, 'reps' => '8-10', 'rest_time' => '120 seg', 'notes' => 'Técnica estricta'],
                    ['exercise_name' => 'Remo con Mancuerna', 'sets' => 4, 'reps' => '10', 'rest_time' => '75 seg', 'notes' => 'Recorrido completo'],
                    ['exercise_name' => 'Press Militar', 'sets' => 3, 'reps' => '12', 'rest_time' => '60 seg', 'notes' => 'Evita arquear la espalda'],
                ],
            ],
        ];

        foreach ($routineDefinitions as $definition) {
            $client = $clientUsers->firstWhere('email', $definition['client_email']);
            if (! $client) {
                continue;
            }

            DB::table('routines')->updateOrInsert(
                [
                    'client_id' => $client->id,
                    'coach_id' => $coach->id,
                    'name' => $definition['name'],
                ],
                [
                    'description' => $definition['description'],
                    'is_active' => $definition['is_active'],
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );

            $routine = DB::table('routines')
                ->where('client_id', $client->id)
                ->where('coach_id', $coach->id)
                ->where('name', $definition['name'])
                ->first();

            if (! $routine) {
                continue;
            }

            DB::table('routine_exercises')->where('routine_id', $routine->id)->delete();

            foreach ($definition['exercises'] as $index => $exercise) {
                DB::table('exercise_catalog')->updateOrInsert(
                    ['name' => $exercise['exercise_name']],
                    ['created_at' => now(), 'updated_at' => now()]
                );

                $exerciseId = DB::table('exercise_catalog')
                    ->where('name', $exercise['exercise_name'])
                    ->value('exercise_id');

                DB::table('routine_exercises')->insert([
                    'routine_id' => $routine->id,
                    'exercise_id' => $exerciseId,
                    'exercise_name' => $exercise['exercise_name'],
                    'sets' => $exercise['sets'],
                    'reps' => $exercise['reps'],
                    'rest_time' => $exercise['rest_time'],
                    'notes' => $exercise['notes'],
                    'order' => $index + 1,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // Ensure plan is owned by the demo nutriologo, not an old one
        NutritionPlan::query()->where('title', 'Plan Déficit Inteligente')->delete();

        $plan = NutritionPlan::query()->create(
            [
                'nutriologo_id' => $nutriologo->id,
                'title' => 'Plan Déficit Inteligente',
            ] +
            [
                'description' => 'Plan enfocado en adherencia y control de hambre.',
                'goal' => 'Definición',
                'daily_calories' => 1850,
                'macro_targets' => [
                    'protein' => 140,
                    'carbs' => 180,
                    'fat' => 55,
                ],
                'is_active' => true,
                'starts_at' => now()->toDateString(),
                'ends_at' => now()->addWeeks(8)->toDateString(),
            ]
        );

        $mealDefinitions = [
            ['meal_type' => 'desayuno', 'name' => 'Avena con proteína', 'portion' => '1 bowl', 'calories' => 420, 'protein_g' => 30, 'carbs_g' => 48, 'fat_g' => 10],
            ['meal_type' => 'comida', 'name' => 'Pollo con arroz y verduras', 'portion' => '1 plato', 'calories' => 620, 'protein_g' => 45, 'carbs_g' => 60, 'fat_g' => 15],
            ['meal_type' => 'cena', 'name' => 'Yogurt griego con nueces', 'portion' => '1 porción', 'calories' => 300, 'protein_g' => 24, 'carbs_g' => 18, 'fat_g' => 12],
        ];

        $plan->meals()->delete();
        foreach ($mealDefinitions as $index => $meal) {
            NutritionPlanMeal::query()->create([
                'nutrition_plan_id' => $plan->id,
                'meal_type' => $meal['meal_type'],
                'name' => $meal['name'],
                'portion' => $meal['portion'],
                'calories' => $meal['calories'],
                'protein_g' => $meal['protein_g'],
                'carbs_g' => $meal['carbs_g'],
                'fat_g' => $meal['fat_g'],
                'notes' => 'Dato demo para pruebas',
                'position' => $index + 1,
            ]);
        }

        foreach ($clientUsers as $index => $client) {
            NutritionPlanAssignment::query()->updateOrCreate(
                [
                    'nutrition_plan_id' => $plan->id,
                    'client_id' => $client->id,
                    'starts_at' => now()->toDateString(),
                ],
                [
                    'nutriologo_id' => $nutriologo->id,
                    'assigned_at' => now()->toDateString(),
                    'ends_at' => now()->addWeeks(8)->toDateString(),
                    'status' => $index === 2 ? 'paused' : 'active',
                    'notes' => 'Asignación demo para validar dashboard y chatbot',
                ]
            );
        }
    }
}
