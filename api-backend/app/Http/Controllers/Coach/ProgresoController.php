<?php

namespace App\Http\Controllers\Coach;

use App\Http\Controllers\Controller;
use App\Models\Client;
use App\Models\ProgressRecord;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class ProgresoController extends Controller
{
    private function coachId(Request $request): ?int
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) return null;

        return Cache::remember('coach_uid_' . md5($email), 300, fn() => User::where('email', $email)->value('user_id'));
    }

    private function verifyClientBelongsToCoach(int $clientId, int $coachId): bool
    {
        return Client::where('user_id', $clientId)->where('coach_id', $coachId)->exists();
    }

    /**
     * GET /coach/progreso/clients
     */
    public function clientsList(Request $request): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $clients = Client::where('clients.coach_id', $coachId)
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->select(['clients.user_id as id', 'users.name', 'users.avatar_url', 'clients.goal as objetivo'])
            ->orderBy('users.name')
            ->get()
            ->map(function ($c) {
                $parts = explode(' ', $c->name);
                $initials = '';
                foreach (array_slice($parts, 0, 2) as $p) {
                    $initials .= strtoupper($p[0] ?? '');
                }
                return [
                    'id'       => $c->id,
                    'name'     => $c->name,
                    'initials' => $initials ?: '?',
                    'avatar'   => $c->avatar_url,
                    'objetivo' => $c->objetivo,
                ];
            });

        return response()->json($clients);
    }

    /**
     * GET /coach/progreso/clients/{id}/composicion
     */
    public function composicion(Request $request, int $clientId): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) return response()->json(['error' => 'No autorizado'], 403);

        if (!$this->verifyClientBelongsToCoach($clientId, $coachId)) {
            return response()->json(['error' => 'Cliente no encontrado'], 404);
        }

        $records = ProgressRecord::where('client_id', $clientId)
            ->orderBy('date')
            ->select(['date', 'weight_kg', 'body_fat_pct', 'muscle_mass_kg'])
            ->limit(365)
            ->get()
            ->map(fn($r) => [
                'fecha'   => $r->date->format('Y-m-d'),
                'peso'    => (float) $r->weight_kg,
                'grasa'   => (float) $r->body_fat_pct,
                'musculo' => (float) $r->muscle_mass_kg,
            ]);

        $monthAgo = now()->subDays(30)->format('Y-m-d');
        $recent   = $records->filter(fn($r) => $r['fecha'] >= $monthAgo);
        $rFirst   = $recent->first();
        $rLast    = $recent->last();
        $last     = $records->last();

        $kpis = [
            'peso_actual'    => $last ? $last['peso']    : null,
            'grasa_actual'   => $last ? $last['grasa']   : null,
            'musculo_actual' => $last ? $last['musculo'] : null,
            'cambio_peso'    => $rFirst && $rLast ? round($rLast['peso']    - $rFirst['peso'], 1)    : 0,
            'cambio_grasa'   => $rFirst && $rLast ? round($rLast['grasa']   - $rFirst['grasa'], 1)   : 0,
            'cambio_musculo' => $rFirst && $rLast ? round($rLast['musculo'] - $rFirst['musculo'], 1) : 0,
        ];

        return response()->json(['datos' => $records->values(), 'kpis' => $kpis]);
    }

    /**
     * GET /coach/progreso/clients/{id}/fuerza?ejercicio=sentadilla
     */
    public function fuerza(Request $request, int $clientId): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) return response()->json(['error' => 'No autorizado'], 403);

        if (!$this->verifyClientBelongsToCoach($clientId, $coachId)) {
            return response()->json(['error' => 'Cliente no encontrado'], 404);
        }

        $ejercicio = $request->query('ejercicio', 'sentadilla');

        $searchTermMap = [
            'sentadilla'  => ['sentadilla', 'squat'],
            'press_banca' => ['press banca', 'bench press', 'press de banca'],
            'peso_muerto' => ['peso muerto', 'deadlift'],
        ];

        $terms = $searchTermMap[$ejercicio] ?? [$ejercicio];

        $logs = DB::table('workout_logs as wl')
            ->join('routine_exercises as re', 're.routine_id', '=', 'wl.routine_id')
            ->where('wl.client_id', $clientId)
            ->where('wl.is_complete', true)
            ->where('wl.date', '>=', now()->subDays(730)->toDateString())
            ->where(function ($q) use ($terms) {
                foreach ($terms as $term) {
                    $q->orWhereRaw('LOWER(re.exercise_name) LIKE ?', ['%' . strtolower($term) . '%']);
                }
            })
            ->orderBy('wl.date')
            ->select(['wl.date', DB::raw('MAX(re.weight) as peso_max'), DB::raw('MAX(re.reps) as reps')])
            ->groupBy('wl.date')
            ->limit(200)
            ->get()
            ->map(function ($log) {
                $peso = (float) ($log->peso_max ?? 0);
                $reps = (int)   ($log->reps    ?? 1);
                // Epley formula: 1RM ≈ peso × (1 + reps/30)
                $orm = $reps > 1 ? round($peso * (1 + $reps / 30), 1) : $peso;
                return ['fecha' => $log->date, 'peso_max' => $peso, 'reps' => $reps, '1rm_estimado' => $orm];
            });

        $monthAgo    = now()->subDays(30)->format('Y-m-d');
        $recent      = $logs->filter(fn($l) => $l['fecha'] >= $monthAgo);
        $rFirst      = $recent->first();
        $rLast       = $recent->last();

        return response()->json([
            'ejercicio'       => $ejercicio,
            'historial'       => $logs->values(),
            'mejor_historico' => $logs->max('1rm_estimado') ?? 0,
            'mejora_mensual'  => $rFirst && $rLast ? round($rLast['1rm_estimado'] - $rFirst['1rm_estimado'], 1) : 0,
        ]);
    }

    /**
     * GET /coach/progreso/clients/{id}/fatiga
     */
    public function fatiga(Request $request, int $clientId): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) return response()->json(['error' => 'No autorizado'], 403);

        if (!$this->verifyClientBelongsToCoach($clientId, $coachId)) {
            return response()->json(['error' => 'Cliente no encontrado'], 404);
        }

        $sevenDaysAgo = now()->subDays(7)->format('Y-m-d');

        $exercises = DB::table('workout_logs as wl')
            ->join('routine_exercises as re', 're.routine_id', '=', 'wl.routine_id')
            ->where('wl.client_id', $clientId)
            ->where('wl.is_complete', true)
            ->where('wl.date', '>=', $sevenDaysAgo)
            ->select([DB::raw('LOWER(re.exercise_name) as exercise_name'), 're.sets', 're.reps', 're.weight'])
            ->limit(500)
            ->get();

        $muscleMappings = [
            'pecho'          => ['press banca', 'bench press', 'press de banca', 'press inclinado', 'peck deck', 'aperturas', 'fondos'],
            'espalda'        => ['dominadas', 'remo', 'jalón', 'jalon', 'pull-up', 'pulldown', 'lat pull', 'jalonamiento'],
            'hombros'        => ['press militar', 'elevaciones laterales', 'lateral raise', 'press arnés', 'face pull'],
            'biceps'         => ['curl', 'bicep', 'martillo', 'hammer'],
            'triceps'        => ['tríceps', 'triceps', 'extensión de tríceps', 'press cerrado', 'jalón tríceps'],
            'abdomen'        => ['crunch', 'plancha', 'plank', 'abs', 'abdomen', 'elevación de piernas', 'russian twist'],
            'cuadriceps'     => ['sentadilla', 'squat', 'prensa', 'press de piernas', 'zancada', 'lunges', 'lunge'],
            'isquiotibiales' => ['peso muerto', 'deadlift', 'curl de piernas', 'leg curl', 'rdl'],
            'gluteos'        => ['hip thrust', 'glute bridge', 'sentadilla', 'squat', 'peso muerto', 'deadlift', 'zancada'],
            'pantorrillas'   => ['gemelos', 'calf raise', 'pantorrilla', 'heel raise'],
            'espalda_baja'   => ['peso muerto', 'deadlift', 'hiperextensión', 'hyperextension', 'back extension'],
            'trapecio'       => ['encogimientos', 'shrugs', 'remo al mentón', 'upright row'],
        ];

        $muscleData = array_fill_keys(array_keys($muscleMappings), ['series' => 0, 'volumen' => 0]);

        foreach ($exercises as $ex) {
            $name    = $ex->exercise_name;
            $series  = (int)   ($ex->sets   ?? 0);
            $reps    = (int)   ($ex->reps   ?? 0);
            $weight  = (float) ($ex->weight ?? 0);
            $volume  = $series * $reps * $weight;

            foreach ($muscleMappings as $muscle => $keywords) {
                foreach ($keywords as $kw) {
                    if (str_contains($name, $kw)) {
                        $muscleData[$muscle]['series'] += $series;
                        $muscleData[$muscle]['volumen'] += $volume;
                        break;
                    }
                }
            }
        }

        foreach ($muscleData as &$data) {
            $s = $data['series'];
            $data['nivel'] = match(true) {
                $s === 0    => 'recuperado',
                $s <= 6     => 'bajo',
                $s <= 12    => 'moderado',
                default     => 'alto',
            };
        }
        unset($data);

        return response()->json(['semana' => $muscleData]);
    }
}
