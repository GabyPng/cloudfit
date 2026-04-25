<?php

namespace App\Http\Controllers\Coach;

use App\Http\Controllers\Controller;
use App\Models\Client;
use App\Models\Routine;
use App\Models\RoutineAssignment;
use App\Models\RoutineExercise;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class RutinasController extends Controller
{
    /* ──────────────────────────────────────────────────────────────────────
     |  Helper: resolve the local user_id from the Supabase JWT email.
     |──────────────────────────────────────────────────────────────────── */

    private function coachId(Request $request): ?int
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) {
            return null;
        }

        return User::where('email', $email)->value('user_id');
    }

    /* ══════════════════════════════════════════════════════════════════════
     |  CLIENTS
     |══════════════════════════════════════════════════════════════════════ */

    /**
     * GET /coach/rutinas/clients
     * Lista de clientes del coach para el panel izquierdo.
     */
    public function clientsList(Request $request): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $clients = Client::where('clients.coach_id', $coachId)
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->select([
                'clients.user_id as id',
                'users.name',
                'users.avatar_url',
                'clients.goal as objective',
            ])
            ->orderBy('users.name')
            ->get()
            ->map(function ($c) {
                // Build avatar initials from name
                $parts = explode(' ', $c->name);
                $initials = '';
                foreach (array_slice($parts, 0, 2) as $p) {
                    $initials .= mb_strtoupper(mb_substr($p, 0, 1));
                }

                return [
                    'id'        => $c->id,
                    'name'      => $c->name,
                    'badge'     => null, // can be extended later ("Pro", etc.)
                    'objective' => $c->objective ?? 'Sin objetivo',
                    'avatar'    => $initials,
                ];
            });

        return response()->json($clients);
    }

    /**
     * GET /coach/rutinas/clients/{id}
     * Detalle de un cliente específico.
     */
    public function clientDetail(Request $request, int $id): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $client = Client::where('coach_id', $coachId)
            ->where('user_id', $id)
            ->with('user')
            ->first();

        if (!$client) {
            return response()->json(['error' => 'Cliente no encontrado'], 404);
        }

        $parts = explode(' ', $client->user->name);
        $initials = '';
        foreach (array_slice($parts, 0, 2) as $p) {
            $initials .= mb_strtoupper(mb_substr($p, 0, 1));
        }

        return response()->json([
            'id'        => $client->user_id,
            'name'      => $client->user->name,
            'email'     => $client->user->email,
            'badge'     => null,
            'objective' => $client->goal,
            'avatar'    => $initials,
            'height'    => $client->height,
            'birthDate' => $client->birth_date?->toDateString(),
        ]);
    }

    /* ══════════════════════════════════════════════════════════════════════
     |  ROUTINES
     |══════════════════════════════════════════════════════════════════════ */

    /**
     * GET /coach/rutinas/routines?level=all|basics|advanced
     * Lista de rutinas del coach con filtro de nivel.
     */
    public function routinesList(Request $request): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $level = $request->query('level', 'all');

        $routines = Routine::where('coach_id', $coachId)
            ->level($level)
            ->with('exercises')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (Routine $r) => $this->formatRoutine($r));

        return response()->json($routines);
    }

    /**
     * POST /coach/rutinas/routines
     * Crear una nueva rutina.
     */
    public function routineStore(Request $request): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $data = $request->validate([
            'name'             => 'required|string|max:255',
            'description'      => 'nullable|string',
            'tag'              => 'nullable|string|max:100',
            'icon_type'        => ['nullable', Rule::in(['dumbbell', 'zap', 'heart'])],
            'accent_color'     => 'nullable|string|max:20',
            'difficulty'       => 'nullable|integer|min:0|max:100',
            'difficulty_label' => 'nullable|string|max:50',
            'duration_label'   => 'nullable|string|max:100',
            'training_plan'    => 'nullable|string|max:100',
            'exercises'        => 'nullable|array',
            'exercises.*.name'   => 'required|string|max:255',
            'exercises.*.sets'   => 'required|integer|min:1',
            'exercises.*.reps'   => 'required|integer|min:1',
            'exercises.*.weight' => 'nullable|string|max:20',
            'exercises.*.rest'   => ['required', Rule::in(['30s', '45s', '60s', '90s', '120s', '150s', '180s'])],
        ]);

        return DB::transaction(function () use ($data, $coachId) {
            // Default difficulty label based on value
            $difficulty = $data['difficulty'] ?? 50;
            $difficultyLabel = $data['difficulty_label'] ?? ($difficulty <= 40 ? 'Basico' : ($difficulty <= 70 ? 'Intermedio' : 'Avanzado'));

            $routine = Routine::create([
                'name'             => $data['name'],
                'description'      => $data['description'] ?? null,
                'coach_id'         => $coachId,
                'client_id'        => null,
                'is_active'        => true,
                'tag'              => $data['tag'] ?? strtoupper($data['name']),
                'icon_type'        => $data['icon_type'] ?? 'dumbbell',
                'accent_color'     => $data['accent_color'] ?? '#cafd00',
                'difficulty'       => $difficulty,
                'difficulty_label' => $difficultyLabel,
                'duration_label'   => $data['duration_label'] ?? null,
                'training_plan'    => $data['training_plan'] ?? null,
            ]);

            if (!empty($data['exercises'])) {
                foreach ($data['exercises'] as $index => $ex) {
                    $this->upsertExerciseCatalog($ex['name']);
                    $exerciseId = DB::table('exercise_catalog')->where('name', $ex['name'])->value('exercise_id');

                    RoutineExercise::create([
                        'routine_id'    => $routine->id,
                        'exercise_id'   => $exerciseId,
                        'exercise_name' => $ex['name'],
                        'sets'          => $ex['sets'],
                        'reps'          => (string) $ex['reps'],
                        'weight'        => $ex['weight'] ?? null,
                        'rest_time'     => $ex['rest'],
                        'order'         => $index + 1,
                    ]);
                }
            }

            $routine->load('exercises');

            return response()->json($this->formatRoutine($routine), 201);
        });
    }

    /**
     * PUT /coach/rutinas/routines/{id}
     * Editar rutina existente.
     */
    public function routineUpdate(Request $request, int $id): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $routine = Routine::where('coach_id', $coachId)->findOrFail($id);

        $data = $request->validate([
            'name'             => 'sometimes|required|string|max:255',
            'description'      => 'nullable|string',
            'tag'              => 'nullable|string|max:100',
            'icon_type'        => ['nullable', Rule::in(['dumbbell', 'zap', 'heart'])],
            'accent_color'     => 'nullable|string|max:20',
            'difficulty'       => 'nullable|integer|min:0|max:100',
            'difficulty_label' => 'nullable|string|max:50',
            'duration_label'   => 'nullable|string|max:100',
            'training_plan'    => 'nullable|string|max:100',
            'exercises'        => 'nullable|array',
            'exercises.*.name'   => 'required|string|max:255',
            'exercises.*.sets'   => 'required|integer|min:1',
            'exercises.*.reps'   => 'required|integer|min:1',
            'exercises.*.weight' => 'nullable|string|max:20',
            'exercises.*.rest'   => ['required', Rule::in(['30s', '45s', '60s', '90s', '120s', '150s', '180s'])],
        ]);

        DB::transaction(function () use ($routine, $data) {
            $routine->update([
                'name'             => $data['name'] ?? $routine->name,
                'description'      => $data['description'] ?? $routine->description,
                'tag'              => $data['tag'] ?? $routine->tag,
                'icon_type'        => $data['icon_type'] ?? $routine->icon_type,
                'accent_color'     => $data['accent_color'] ?? $routine->accent_color,
                'difficulty'       => $data['difficulty'] ?? $routine->difficulty,
                'difficulty_label' => $data['difficulty_label'] ?? $routine->difficulty_label,
                'duration_label'   => $data['duration_label'] ?? $routine->duration_label,
                'training_plan'    => $data['training_plan'] ?? $routine->training_plan,
            ]);

            if (isset($data['exercises'])) {
                $routine->exercises()->delete();
                foreach ($data['exercises'] as $index => $ex) {
                    $this->upsertExerciseCatalog($ex['name']);
                    $exerciseId = DB::table('exercise_catalog')->where('name', $ex['name'])->value('exercise_id');

                    RoutineExercise::create([
                        'routine_id'    => $routine->id,
                        'exercise_id'   => $exerciseId,
                        'exercise_name' => $ex['name'],
                        'sets'          => $ex['sets'],
                        'reps'          => (string) $ex['reps'],
                        'weight'        => $ex['weight'] ?? null,
                        'rest_time'     => $ex['rest'],
                        'order'         => $index + 1,
                    ]);
                }
            }
        });
        $routine->load('exercises');

        return response()->json($this->formatRoutine($routine));
    }

    /**
     * DELETE /coach/rutinas/routines/{id}
     */
    public function routineDestroy(Request $request, int $id): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $routine = Routine::where('coach_id', $coachId)->findOrFail($id);
        $routine->delete();

        return response()->json(['message' => 'Rutina eliminada']);
    }

    /* ══════════════════════════════════════════════════════════════════════
     |  EXERCISES (sub-resource of routines)
     |══════════════════════════════════════════════════════════════════════ */

    /**
     * GET /coach/rutinas/routines/{id}/exercises
     */
    public function exercisesList(Request $request, int $routineId): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $routine = Routine::where('coach_id', $coachId)->findOrFail($routineId);

        return response()->json(
            $routine->exercises->map(fn ($ex) => $this->formatExercise($ex))
        );
    }

    /**
     * POST /coach/rutinas/routines/{id}/exercises
     */
    public function exerciseStore(Request $request, int $routineId): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $routine = Routine::where('coach_id', $coachId)->findOrFail($routineId);

        $data = $request->validate([
            'name'   => 'required|string|max:255',
            'sets'   => 'required|integer|min:1',
            'reps'   => 'required|integer|min:1',
            'weight' => 'nullable|string|max:20',
            'rest'   => ['required', Rule::in(['30s', '45s', '60s', '90s', '120s', '150s', '180s'])],
        ]);

        $this->upsertExerciseCatalog($data['name']);
        $exerciseId = DB::table('exercise_catalog')->where('name', $data['name'])->value('exercise_id');

        $maxOrder = $routine->exercises()->max('order') ?? 0;

        $exercise = RoutineExercise::create([
            'routine_id'    => $routine->id,
            'exercise_id'   => $exerciseId,
            'exercise_name' => $data['name'],
            'sets'          => $data['sets'],
            'reps'          => (string) $data['reps'],
            'weight'        => $data['weight'] ?? null,
            'rest_time'     => $data['rest'],
            'order'         => $maxOrder + 1,
        ]);

        return response()->json($this->formatExercise($exercise), 201);
    }

    /**
     * PUT /coach/rutinas/exercises/{id}
     * Update an exercise inline (sets/reps/weight/rest).
     */
    public function exerciseUpdate(Request $request, int $id): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $exercise = RoutineExercise::whereHas('routine', fn ($q) => $q->where('coach_id', $coachId))
            ->findOrFail($id);

        $data = $request->validate([
            'name'   => 'sometimes|required|string|max:255',
            'sets'   => 'sometimes|required|integer|min:1',
            'reps'   => 'sometimes|required|integer|min:1',
            'weight' => 'nullable|string|max:20',
            'rest'   => ['sometimes', 'required', Rule::in(['30s', '45s', '60s', '90s', '120s', '150s', '180s'])],
        ]);

        $updates = [];
        if (isset($data['name'])) {
            $updates['exercise_name'] = $data['name'];
            $this->upsertExerciseCatalog($data['name']);
            $updates['exercise_id'] = DB::table('exercise_catalog')->where('name', $data['name'])->value('exercise_id');
        }
        if (isset($data['sets']))   $updates['sets']      = $data['sets'];
        if (isset($data['reps']))   $updates['reps']      = (string) $data['reps'];
        if (array_key_exists('weight', $data)) $updates['weight'] = $data['weight'];
        if (isset($data['rest']))   $updates['rest_time'] = $data['rest'];

        $exercise->update($updates);

        return response()->json($this->formatExercise($exercise->fresh()));
    }

    /**
     * DELETE /coach/rutinas/exercises/{id}
     */
    public function exerciseDestroy(Request $request, int $id): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $exercise = RoutineExercise::whereHas('routine', fn ($q) => $q->where('coach_id', $coachId))
            ->findOrFail($id);

        $exercise->delete();

        return response()->json(['message' => 'Ejercicio eliminado']);
    }

    /**
     * PATCH /coach/rutinas/routines/{id}/exercises/reorder
     * Reorder exercises via drag & drop.
     */
    public function exercisesReorder(Request $request, int $routineId): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $routine = Routine::where('coach_id', $coachId)->findOrFail($routineId);

        $data = $request->validate([
            'order'        => 'required|array',
            'order.*.id'   => 'required|integer',
            'order.*.order' => 'required|integer|min:1',
        ]);

        DB::transaction(function () use ($data, $routine) {
            foreach ($data['order'] as $item) {
                RoutineExercise::where('routine_id', $routine->id)
                    ->where('id', $item['id'])
                    ->update(['order' => $item['order']]);
            }
        });

        return response()->json(['message' => 'Orden actualizado']);
    }

    /* ══════════════════════════════════════════════════════════════════════
     |  ASSIGNMENTS
     |══════════════════════════════════════════════════════════════════════ */

    /**
     * POST /coach/rutinas/assignments
     * Assign a routine to a client (the "Confirmar Asignación" button).
     */
    public function assignmentStore(Request $request): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $data = $request->validate([
            'clientId'  => 'required|integer',
            'routineId' => 'required|integer',
        ]);

        // Validate coach owns both the client and the routine
        $client = Client::where('coach_id', $coachId)
            ->where('user_id', $data['clientId'])
            ->firstOrFail();

        $routine = Routine::where('coach_id', $coachId)
            ->findOrFail($data['routineId']);

        // Prevent assigning the same routine twice (active)
        $duplicate = RoutineAssignment::where('client_id', $data['clientId'])
            ->where('routine_id', $data['routineId'])
            ->where('status', 'active')
            ->exists();

        if ($duplicate) {
            return response()->json(['error' => 'Esta rutina ya está asignada activamente a este cliente.'], 422);
        }

        $assignment = RoutineAssignment::create([
            'client_id'   => $data['clientId'],
            'routine_id'  => $data['routineId'],
            'coach_id'    => $coachId,
            'status'      => 'active',
            'assigned_at' => now(),
        ]);

        $assignment->load(['client.user', 'routine']);

        return response()->json([
            'id'          => $assignment->id,
            'clientId'    => $assignment->client_id,
            'clientName'  => $assignment->client->user->name ?? null,
            'routineId'   => $assignment->routine_id,
            'routineName' => $assignment->routine->name ?? null,
            'status'      => $assignment->status,
            'assignedAt'  => $assignment->assigned_at->toISOString(),
        ], 201);
    }

    /**
     * GET /coach/rutinas/assignments?clientId=
     * Assignment history for a client.
     */
    public function assignmentsList(Request $request): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $query = RoutineAssignment::where('coach_id', $coachId)
            ->whereIn('status', ['active', 'paused'])
            ->with(['routine', 'client.user']);

        if ($request->has('clientId')) {
            $query->where('client_id', $request->query('clientId'));
        }

        $assignments = $query->orderByDesc('assigned_at')
            ->get()
            ->map(fn ($a) => [
                'id'          => $a->id,
                'clientId'    => $a->client_id,
                'clientName'  => $a->client->user->name ?? null,
                'routineId'   => $a->routine_id,
                'routineName' => $a->routine->name ?? null,
                'status'      => $a->status,
                'assignedAt'  => $a->assigned_at?->toISOString(),
            ]);

        return response()->json($assignments);
    }

    /**
     * PATCH /coach/rutinas/assignments/{id}/status
     * Change assignment status (pause / complete).
     */
    public function assignmentStatus(Request $request, int $id): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $assignment = RoutineAssignment::where('coach_id', $coachId)->findOrFail($id);

        $data = $request->validate([
            'status' => ['required', Rule::in(['active', 'paused'])],
        ]);

        $assignment->update(['status' => $data['status']]);

        return response()->json([
            'id'     => $assignment->id,
            'status' => $assignment->status,
        ]);
    }

    /* ══════════════════════════════════════════════════════════════════════
     |  CLIENT ROUTINES (admin view)
     |══════════════════════════════════════════════════════════════════════ */

    /**
     * GET /coach/rutinas/clients/{id}/routines
     * All assignments (with routine details + exercises) for a specific client.
     */
    public function clientRoutinesList(Request $request, int $clientId): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $client = Client::where('coach_id', $coachId)
            ->where('user_id', $clientId)
            ->with('user')
            ->first();

        if (!$client) {
            return response()->json(['error' => 'Cliente no encontrado'], 404);
        }

        $parts = explode(' ', $client->user->name);
        $initials = '';
        foreach (array_slice($parts, 0, 2) as $p) {
            $initials .= mb_strtoupper(mb_substr($p, 0, 1));
        }

        $assignments = RoutineAssignment::where('client_id', $clientId)
            ->where('coach_id', $coachId)
            ->whereIn('status', ['active', 'paused'])
            ->with(['routine.exercises'])
            ->orderByRaw("CASE status WHEN 'active' THEN 0 ELSE 1 END")
            ->orderByDesc('assigned_at')
            ->get()
            ->map(fn ($a) => [
                'assignmentId' => $a->id,
                'status'       => $a->status,
                'assignedAt'   => $a->assigned_at?->toISOString(),
                'routine'      => $a->routine ? $this->formatRoutine($a->routine) : null,
            ]);

        return response()->json([
            'client' => [
                'id'        => $client->user_id,
                'name'      => $client->user->name,
                'email'     => $client->user->email,
                'avatar'    => $initials,
                'objective' => $client->goal,
                'height'    => $client->height,
                'birthDate' => $client->birth_date?->toDateString(),
            ],
            'assignments' => $assignments,
        ]);
    }

    /* ══════════════════════════════════════════════════════════════════════
     |  PRIVATE HELPERS
     |══════════════════════════════════════════════════════════════════════ */

    private function formatRoutine(Routine $routine): array
    {
        return [
            'id'              => $routine->id,
            'name'            => $routine->name,
            'description'     => $routine->description,
            'tag'             => $routine->tag,
            'iconType'        => $routine->icon_type,
            'accentColor'     => $routine->accent_color,
            'difficulty'      => $routine->difficulty,
            'difficultyLabel' => $routine->difficulty_label,
            'durationLabel'   => $routine->duration_label,
            'trainingPlan'    => $routine->training_plan,
            'isActive'        => $routine->is_active,
            'highlighted'     => $routine->difficulty > 50,
            'totalVolume'     => $routine->total_volume,
            'estDuration'     => $routine->est_duration,
            'exercises'       => $routine->exercises->map(fn ($ex) => $this->formatExercise($ex))->values(),
            'createdAt'       => $routine->created_at?->toISOString(),
        ];
    }

    private function formatExercise(RoutineExercise $ex): array
    {
        return [
            'id'     => $ex->id,
            'name'   => $ex->exercise_name,
            'sets'   => $ex->sets,
            'reps'   => (int) $ex->reps,
            'weight' => $ex->weight ?? '',
            'rest'   => $ex->rest_time,
            'order'  => $ex->order,
        ];
    }

    /**
     * Ensure the exercise name exists in the exercise_catalog.
     */
    private function upsertExerciseCatalog(string $name): void
    {
        DB::table('exercise_catalog')->updateOrInsert(
            ['name' => $name],
            ['created_at' => now(), 'updated_at' => now()]
        );
    }
}
