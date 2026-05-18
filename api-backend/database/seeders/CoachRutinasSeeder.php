<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\Routine;
use App\Models\RoutineAssignment;
use App\Models\RoutineExercise;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Seeds the data required by the Coach → Rutinas interface.
 *
 * Replaces every static/mock constant in Rutinas.jsx:
 *   MOCK_CLIENTS, MOCK_ROUTINES, INITIAL_EXERCISES, PLAN_OPTIONS
 */
class CoachRutinasSeeder extends Seeder
{
    public function run(): void
    {
        // ── Resolve the demo coach (created by CloudFitDemoSeeder) ───────
        $coach = User::where('email', 'coach.demo@cloudfit.test')->first();
        if (! $coach) {
            $this->command->warn('⚠ Coach demo user not found — skipping CoachRutinasSeeder.');

            return;
        }

        $coachId = $coach->user_id;

        // ── Ensure 4 clients exist for this coach ───────────────────────
        $clientRoleId = Role::where('name', 'cliente')->value('role_id');

        $clientDefs = [
            [
                'email' => 'cliente.alejandro@cloudfit.test',
                'name' => 'Alejandro García',
                'goal' => 'Hipertrofia',
                'height' => 1.80,
                'birth_date' => '1996-03-15',
            ],
            [
                'email' => 'cliente.lucia@cloudfit.test',
                'name' => 'Lucía Méndez',
                'goal' => 'Pérdida de Grasa',
                'height' => 1.62,
                'birth_date' => '1999-07-22',
            ],
            [
                'email' => 'cliente.carlos@cloudfit.test',
                'name' => 'Carlos Ruiz',
                'goal' => 'Fuerza Máxima',
                'height' => 1.75,
                'birth_date' => '1994-11-08',
            ],
            [
                'email' => 'cliente.sofia@cloudfit.test',
                'name' => 'Sofía Bernal',
                'goal' => 'Resistencia',
                'height' => 1.58,
                'birth_date' => '2001-02-14',
            ],
        ];

        $clientUsers = collect();

        foreach ($clientDefs as $def) {
            $user = User::updateOrCreate(
                ['email' => $def['email']],
                [
                    'name' => $def['name'],
                    'password' => bcrypt('password'),
                    'role_id' => $clientRoleId,
                    'email_verified_at' => now(),
                ]
            );

            DB::table('clients')->updateOrInsert(
                ['user_id' => $user->user_id],
                [
                    'coach_id' => $coachId,
                    'nutritionist_id' => null,
                    'birth_date' => $def['birth_date'],
                    'height' => $def['height'],
                    'goal' => $def['goal'],
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );

            $clientUsers->push($user);
        }

        // ── Routines ────────────────────────────────────────────────────
        // Matches MOCK_ROUTINES from Rutinas.jsx

        $routineDefs = [
            [
                'name' => 'Full Body Power',
                'description' => 'Rutina completa de potencia para todo el cuerpo, diseñada para desarrollar fuerza explosiva y masa muscular.',
                'tag' => 'HIERRO & FUEGO',
                'icon_type' => 'dumbbell',
                'accent_color' => '#cafd00',
                'difficulty' => 66,
                'difficulty_label' => 'Dificultad',
                'duration_label' => '8 semanas · 4 días/semana',
                'training_plan' => 'Fuerza Max',
                'exercises' => [
                    ['name' => 'Sentadilla con Barra', 'sets' => 4, 'reps' => '12', 'weight' => '80',  'rest_time' => '90s',  'order' => 1],
                    ['name' => 'Prensa de Piernas',    'sets' => 3, 'reps' => '15', 'weight' => '120', 'rest_time' => '60s',  'order' => 2],
                    ['name' => 'Press de Banca',       'sets' => 4, 'reps' => '10', 'weight' => '70',  'rest_time' => '90s',  'order' => 3],
                    ['name' => 'Remo con Barra',       'sets' => 4, 'reps' => '10', 'weight' => '60',  'rest_time' => '60s',  'order' => 4],
                    ['name' => 'Press Militar',        'sets' => 3, 'reps' => '12', 'weight' => '40',  'rest_time' => '60s',  'order' => 5],
                ],
            ],
            [
                'name' => 'Functional Elite',
                'description' => 'Entrenamiento funcional de alta intensidad con énfasis en cardio y explosividad.',
                'tag' => 'CARDIO VORTEX',
                'icon_type' => 'zap',
                'accent_color' => '#ac8aff',
                'difficulty' => 100,
                'difficulty_label' => 'Experto',
                'duration_label' => '6 semanas · 5 días/semana',
                'training_plan' => 'Cardio Hit',
                'exercises' => [
                    ['name' => 'Burpees',              'sets' => 5, 'reps' => '15', 'weight' => '',   'rest_time' => '30s',  'order' => 1],
                    ['name' => 'Box Jumps',            'sets' => 4, 'reps' => '12', 'weight' => '',   'rest_time' => '45s',  'order' => 2],
                    ['name' => 'Kettlebell Swings',    'sets' => 4, 'reps' => '20', 'weight' => '24', 'rest_time' => '45s',  'order' => 3],
                    ['name' => 'Mountain Climbers',    'sets' => 4, 'reps' => '30', 'weight' => '',   'rest_time' => '30s',  'order' => 4],
                    ['name' => 'Battle Ropes',         'sets' => 3, 'reps' => '20', 'weight' => '',   'rest_time' => '60s',  'order' => 5],
                    ['name' => 'Turkish Get-Up',       'sets' => 3, 'reps' => '8',  'weight' => '16', 'rest_time' => '90s',  'order' => 6],
                ],
            ],
            [
                'name' => 'Yoga for Strength',
                'description' => 'Rutina de yoga orientada a fuerza y flexibilidad, ideal para principiantes.',
                'tag' => 'ZEN CORE',
                'icon_type' => 'heart',
                'accent_color' => '#ac8aff',
                'difficulty' => 33,
                'difficulty_label' => 'Básico',
                'duration_label' => '4 semanas · 3 días/semana',
                'training_plan' => 'Resistencia Elite',
                'exercises' => [
                    ['name' => 'Plancha Frontal',      'sets' => 3, 'reps' => '60', 'weight' => '',   'rest_time' => '60s',  'order' => 1],
                    ['name' => 'Warrior Pose Hold',    'sets' => 3, 'reps' => '30', 'weight' => '',   'rest_time' => '30s',  'order' => 2],
                    ['name' => 'Chaturanga Push-ups',  'sets' => 3, 'reps' => '12', 'weight' => '',   'rest_time' => '45s',  'order' => 3],
                ],
            ],
        ];

        foreach ($routineDefs as $def) {
            $routine = Routine::updateOrCreate(
                [
                    'coach_id' => $coachId,
                    'name' => $def['name'],
                ],
                [
                    'description' => $def['description'],
                    'tag' => $def['tag'],
                    'icon_type' => $def['icon_type'],
                    'accent_color' => $def['accent_color'],
                    'difficulty' => $def['difficulty'],
                    'difficulty_label' => $def['difficulty_label'],
                    'duration_label' => $def['duration_label'],
                    'training_plan' => $def['training_plan'],
                    'is_active' => true,
                    'client_id' => null,
                ]
            );

            // Clear previous exercises for idempotency
            RoutineExercise::where('routine_id', $routine->id)->delete();

            foreach ($def['exercises'] as $ex) {
                // Ensure exercise is in catalog
                DB::table('exercise_catalog')->updateOrInsert(
                    ['name' => $ex['name']],
                    ['created_at' => now(), 'updated_at' => now()]
                );

                $catalogId = DB::table('exercise_catalog')
                    ->where('name', $ex['name'])
                    ->value('exercise_id');

                RoutineExercise::create([
                    'routine_id' => $routine->id,
                    'exercise_id' => $catalogId,
                    'exercise_name' => $ex['name'],
                    'sets' => $ex['sets'],
                    'reps' => $ex['reps'],
                    'weight' => $ex['weight'] ?: null,
                    'rest_time' => $ex['rest_time'],
                    'order' => $ex['order'],
                ]);
            }
        }

        // ── Assignments ─────────────────────────────────────────────────
        // Assign "Full Body Power" to Alejandro, "Yoga for Strength" to Sofía

        $fullBody = Routine::where('coach_id', $coachId)->where('name', 'Full Body Power')->first();
        $yoga = Routine::where('coach_id', $coachId)->where('name', 'Yoga for Strength')->first();

        $alejandro = $clientUsers->firstWhere('email', 'cliente.alejandro@cloudfit.test');
        $sofia = $clientUsers->firstWhere('email', 'cliente.sofia@cloudfit.test');

        if ($fullBody && $alejandro) {
            RoutineAssignment::updateOrCreate(
                [
                    'client_id' => $alejandro->user_id,
                    'routine_id' => $fullBody->id,
                    'coach_id' => $coachId,
                ],
                [
                    'status' => 'active',
                    'assigned_at' => now(),
                ]
            );
        }

        if ($yoga && $sofia) {
            RoutineAssignment::updateOrCreate(
                [
                    'client_id' => $sofia->user_id,
                    'routine_id' => $yoga->id,
                    'coach_id' => $coachId,
                ],
                [
                    'status' => 'active',
                    'assigned_at' => now(),
                ]
            );
        }

        $this->command->info('✓ CoachRutinasSeeder completed — 4 clients, 3 routines, 2 assignments.');
    }
}
