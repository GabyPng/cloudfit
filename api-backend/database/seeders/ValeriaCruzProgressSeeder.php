<?php

namespace Database\Seeders;

use App\Models\ProgressRecord;
use App\Models\Routine;
use App\Models\RoutineExercise;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Seeds body‑composition (progress_records) and workout_logs data
 * for "Valeria Cruz" (valeria.c@cloudfit.test) — a client of coach1@gmail.com.
 *
 * Run with:  php artisan db:seed --class=ValeriaCruzProgressSeeder
 */
class ValeriaCruzProgressSeeder extends Seeder
{
    public function run(): void
    {
        // ── 1. Resolve the real coach ──────────────────────────────────
        $coach = User::where('email', 'coach1@gmail.com')->first();
        if (! $coach) {
            $this->command->warn('⚠ coach1@gmail.com not found — skipping.');

            return;
        }

        $coachId = $coach->user_id;

        // ── 2. Find Valeria Cruz ───────────────────────────────────────
        $valeria = User::where('email', 'valeria.c@cloudfit.test')->first();
        if (! $valeria) {
            $this->command->warn('⚠ Valeria Cruz (valeria.c@cloudfit.test) not found — skipping.');

            return;
        }

        $clientId = $valeria->user_id;
        $this->command->info("  Found Valeria Cruz (user_id={$clientId}), coach={$coach->name} (id={$coachId})");

        // ── 3. Body Composition — progress_records ─────────────────────
        //    9 entries over 8 weeks showing gradual fat loss + muscle gain
        ProgressRecord::where('client_id', $clientId)->delete();

        $compositionData = [
            ['weeks_ago' => 8, 'weight' => 68.5, 'fat' => 28.0, 'muscle' => 25.8],
            ['weeks_ago' => 7, 'weight' => 68.0, 'fat' => 27.5, 'muscle' => 26.0],
            ['weeks_ago' => 6, 'weight' => 67.3, 'fat' => 27.0, 'muscle' => 26.2],
            ['weeks_ago' => 5, 'weight' => 67.0, 'fat' => 26.3, 'muscle' => 26.5],
            ['weeks_ago' => 4, 'weight' => 66.5, 'fat' => 25.8, 'muscle' => 26.8],
            ['weeks_ago' => 3, 'weight' => 66.0, 'fat' => 25.2, 'muscle' => 27.0],
            ['weeks_ago' => 2, 'weight' => 65.6, 'fat' => 24.8, 'muscle' => 27.3],
            ['weeks_ago' => 1, 'weight' => 65.2, 'fat' => 24.3, 'muscle' => 27.5],
            ['weeks_ago' => 0, 'weight' => 64.8, 'fat' => 23.9, 'muscle' => 27.8],
        ];

        foreach ($compositionData as $entry) {
            ProgressRecord::create([
                'client_id' => $clientId,
                'author_id' => $coachId,
                'author_role' => 'nutriologo',
                'date' => Carbon::now()->subWeeks($entry['weeks_ago'])->format('Y-m-d'),
                'weight_kg' => $entry['weight'],
                'bmi' => round($entry['weight'] / (1.65 * 1.65), 2),
                'body_fat_pct' => $entry['fat'],
                'muscle_mass_kg' => $entry['muscle'],
                'calories_target' => 1900,
                'adherence_pct' => rand(78, 95),
                'notes' => $entry['weeks_ago'] === 0
                    ? 'Excelente progreso, manteniendo adherencia al plan.'
                    : null,
            ]);
        }

        $this->command->info('  ✓ 9 progress_records created.');

        // ── 4. Routine with exercises that map to the fatigue keywords ──
        $routine = Routine::updateOrCreate(
            [
                'coach_id' => $coachId,
                'name' => 'Total Body Valeria',
            ],
            [
                'description' => 'Rutina full‑body de tonificación para Valeria',
                'tag' => 'TONIFICACIÓN',
                'icon_type' => 'dumbbell',
                'accent_color' => '#cafd00',
                'difficulty' => 55,
                'difficulty_label' => 'Intermedio',
                'duration_label' => '8 semanas · 4 días/semana',
                'training_plan' => 'Tonificación',
                'is_active' => true,
                'client_id' => $clientId,
            ]
        );

        RoutineExercise::where('routine_id', $routine->id)->delete();

        // Exercises chosen to trigger all fatigue‑map muscle groups
        $exercises = [
            ['name' => 'Sentadilla con Barra',       'sets' => 4, 'reps' => '12', 'weight' => '50',  'rest' => '90s',  'order' => 1],
            ['name' => 'Press de Banca',              'sets' => 3, 'reps' => '10', 'weight' => '30',  'rest' => '90s',  'order' => 2],
            ['name' => 'Remo con Mancuerna',          'sets' => 4, 'reps' => '10', 'weight' => '18',  'rest' => '60s',  'order' => 3],
            ['name' => 'Press Militar',               'sets' => 3, 'reps' => '12', 'weight' => '20',  'rest' => '60s',  'order' => 4],
            ['name' => 'Peso Muerto Rumano',          'sets' => 3, 'reps' => '10', 'weight' => '40',  'rest' => '90s',  'order' => 5],
            ['name' => 'Curl con Mancuernas',         'sets' => 3, 'reps' => '12', 'weight' => '10',  'rest' => '45s',  'order' => 6],
            ['name' => 'Extensión de Tríceps',        'sets' => 3, 'reps' => '12', 'weight' => '12',  'rest' => '45s',  'order' => 7],
            ['name' => 'Plancha Frontal',             'sets' => 3, 'reps' => '45', 'weight' => '',    'rest' => '30s',  'order' => 8],
            ['name' => 'Elevaciones Laterales',       'sets' => 3, 'reps' => '15', 'weight' => '8',   'rest' => '45s',  'order' => 9],
            ['name' => 'Gemelos en Máquina',          'sets' => 4, 'reps' => '15', 'weight' => '40',  'rest' => '45s',  'order' => 10],
            ['name' => 'Encogimientos con Mancuernas', 'sets' => 3, 'reps' => '12', 'weight' => '16',  'rest' => '45s',  'order' => 11],
        ];

        foreach ($exercises as $ex) {
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
                'rest_time' => $ex['rest'],
                'order' => $ex['order'],
            ]);
        }

        $this->command->info("  ✓ Routine '{$routine->name}' (id={$routine->id}) with 11 exercises.");

        // ── 5. Workout Logs — 4 sessions in the last 7 days ────────────
        DB::table('workout_logs')->where('client_id', $clientId)->delete();

        $logDates = [
            Carbon::now()->subDays(1)->format('Y-m-d'),
            Carbon::now()->subDays(3)->format('Y-m-d'),
            Carbon::now()->subDays(5)->format('Y-m-d'),
            Carbon::now()->subDays(6)->format('Y-m-d'),
        ];

        foreach ($logDates as $date) {
            DB::table('workout_logs')->insert([
                'client_id' => $clientId,
                'routine_id' => $routine->id,
                'date' => $date,
                'is_complete' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->command->info('  ✓ 4 completed workout_logs in the last 7 days.');
        $this->command->info('');
        $this->command->info("✅ Valeria Cruz (user_id={$clientId}) ready for coach1@gmail.com:");
        $this->command->info('   — Composición: 9 registros (8 semanas)');
        $this->command->info('   — Fatiga: 4 sesiones → all 12 muscle groups active');
    }
}
