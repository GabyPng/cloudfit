<?php

namespace App\Http\Controllers\Coach;

use App\Http\Controllers\Controller;
use App\Models\Client;
use App\Models\Routine;
use App\Models\RoutineAssignment;
use App\Models\User;
use App\Models\WorkoutLog;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class CoachController extends Controller
{
    /**
     * Resuelve el user_id local del coach a partir del supabase_uid del token.
     */
    private function resolveCoachId(Request $request): ?int
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return null;
        }

        return Cache::remember('coach_uid_'.md5($email), 300, fn () => User::where('email', $email)->value('user_id'));
    }

    public function dashboard(Request $request)
    {
        $coachId = $this->resolveCoachId($request);
        if (! $coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $today = Carbon::today();

        // ── 1. Client IDs — single pluck reused in all subsequent queries ──
        $clientIds = Client::where('coach_id', $coachId)->pluck('user_id');

        // ── 2. KPIs: totalAtletas + nuevosEsteMes in one aggregate query ──
        $clientStats = DB::table('clients')
            ->where('coach_id', $coachId)
            ->selectRaw('COUNT(*) as total')
            ->selectRaw('SUM(CASE WHEN created_at >= ? AND created_at < ? THEN 1 ELSE 0 END) as nuevos', [
                $today->copy()->startOfMonth()->toDateTimeString(),
                $today->copy()->addMonth()->startOfMonth()->toDateTimeString(),
            ])
            ->first();

        $totalAtletas = $clientStats->total ?? 0;
        $nuevosEsteMes = $clientStats->nuevos ?? 0;

        // ── 3. Activity KPIs: all workout + assignment stats in one query ──
        $wlHoy = DB::table('workout_logs')->select('client_id')->where('date', $today)->where('is_complete', true)->distinct();
        $wlSemana = DB::table('workout_logs')->select('client_id')->where('date', '>=', $today->copy()->subDays(7))->where('is_complete', true)->distinct();

        $actStats = DB::table('clients')
            ->where('clients.coach_id', $coachId)
            ->leftJoinSub($wlHoy, 'wl_hoy', 'wl_hoy.client_id', '=', 'clients.user_id')
            ->leftJoinSub($wlSemana, 'wl_semana', 'wl_semana.client_id', '=', 'clients.user_id')
            ->selectRaw('(SELECT COUNT(DISTINCT client_id) FROM routine_assignments WHERE coach_id = ? AND status = ?) as con_rutina', [$coachId, 'active'])
            ->selectRaw('(SELECT COUNT(*) FROM routines WHERE coach_id = ? AND is_active = true) as planes_activos', [$coachId])
            ->selectRaw('COUNT(DISTINCT CASE WHEN wl_hoy.client_id IS NOT NULL THEN clients.user_id END) as entrenaron_hoy')
            ->selectRaw('COUNT(DISTINCT CASE WHEN wl_semana.client_id IS NULL THEN clients.user_id END) as alerta_inactividad')
            ->first();

        $clientesConRutinaActiva = $actStats->con_rutina ?? 0;
        $planesActivos = $actStats->planes_activos ?? 0;
        $entrenaronHoy = $actStats->entrenaron_hoy ?? 0;
        $alertasInactividad = $actStats->alerta_inactividad ?? 0;

        $porcentajeCumplimiento = $clientesConRutinaActiva > 0
            ? round(($entrenaronHoy / $clientesConRutinaActiva) * 100)
            : 0;

        // ── 4. Clientes list ─────────────────────────────────────────────
        // Portable "latest progress per client" — works on MySQL, PostgreSQL, SQLite
        $lastProgress = DB::table('progress as p2')
            ->joinSub(
                DB::table('progress')->selectRaw('client_id, MAX(date) as max_date')->groupBy('client_id'),
                'lp', fn ($join) => $join->on('p2.client_id', '=', 'lp.client_id')->whereColumn('p2.date', 'lp.max_date')
            )
            ->select(['p2.client_id', 'p2.weight', 'p2.body_fat']);

        $clientes = Client::where('clients.coach_id', $coachId)
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->leftJoin(
                DB::raw('(SELECT client_id, MAX(date) as last_date FROM workout_logs GROUP BY client_id) AS last_log'),
                'last_log.client_id', '=', 'clients.user_id'
            )
            ->leftJoinSub($lastProgress, 'last_progress', 'last_progress.client_id', '=', 'clients.user_id')
            ->select([
                'clients.user_id as id',
                'users.name as nombre',
                'users.avatar_url as avatar',
                DB::raw('COALESCE(clients.goal, users.objective) as objetivo'),
                'last_log.last_date',
                'last_progress.weight as peso',
                'last_progress.body_fat as grasa',
            ])
            ->orderBy('users.name')
            ->get();

        // Load active/paused routines for all clients in one query ($clientIds already set above)
        $rutinasPorCliente = RoutineAssignment::whereIn('client_id', $clientIds)
            ->where('coach_id', $coachId)
            ->where('status', 'active')
            ->with('routine:id,name,icon_type,accent_color,tag')
            ->get()
            ->groupBy('client_id');

        // Load direct routines assigned from mobile (routines.client_id set, no assignment record)
        $directRoutinasPorCliente = Routine::whereIn('client_id', $clientIds)
            ->where('is_active', true)
            ->select('id', 'client_id', 'name', 'icon_type', 'accent_color', 'tag')
            ->get()
            ->groupBy('client_id');

        $clientes = $clientes->map(function ($row) use ($today, $rutinasPorCliente, $directRoutinasPorCliente) {
            $lastDate = $row->last_date ? Carbon::parse($row->last_date) : null;
            $inactive = ! $lastDate || $lastDate->lt($today->copy()->subDays(7));

            $assignments = $rutinasPorCliente->get($row->id, collect());
            $assignedRoutineIds = $assignments->pluck('routine_id')->filter()->toArray();
            $rutinas = $assignments->map(fn ($a) => [
                'id' => $a->routine_id,
                'name' => $a->routine->name ?? 'Sin nombre',
                'iconType' => $a->routine->icon_type ?? 'dumbbell',
                'accentColor' => $a->routine->accent_color ?? '#cafd00',
                'tag' => $a->routine->tag ?? null,
            ])->values()->toArray();

            // Add direct mobile routines not already in assignments
            foreach ($directRoutinasPorCliente->get($row->id, collect()) as $r) {
                if (! in_array($r->id, $assignedRoutineIds)) {
                    $rutinas[] = [
                        'id' => $r->id,
                        'name' => $r->name,
                        'iconType' => $r->icon_type ?? 'dumbbell',
                        'accentColor' => $r->accent_color ?? '#cafd00',
                        'tag' => $r->tag ?? null,
                    ];
                }
            }

            return [
                'id' => $row->id,
                'nombre' => $row->nombre,
                'avatar' => $row->avatar,
                'objetivo' => $row->objetivo,
                'rutinas' => $rutinas,
                'estado' => $inactive ? 'inactivo' : 'activo',
                'estado_label' => $inactive ? 'Inactivo' : 'Entrenado',
                'peso' => $row->peso ? (float) $row->peso : null,
                'grasa' => $row->grasa ? (float) $row->grasa : null,
            ];
        });

        // ── Actividad Reciente ──────────────────────────────────────
        $actividades = collect();

        $completadas = WorkoutLog::whereIn('workout_logs.client_id', $clientIds)
            ->where('workout_logs.is_complete', true)
            ->where('workout_logs.date', '>=', $today->copy()->subDays(3))
            ->join('clients', 'clients.user_id', '=', 'workout_logs.client_id')
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->join('routines', 'routines.id', '=', 'workout_logs.routine_id')
            ->select('users.name as cliente_nombre', 'routines.name as rutina_nombre', 'workout_logs.created_at')
            ->orderByDesc('workout_logs.date')
            ->limit(5)
            ->get()
            ->map(fn ($log) => [
                'tipo' => 'rutina_completada',
                'cliente_nombre' => $log->cliente_nombre,
                'detalle' => "completó {$log->rutina_nombre}",
                'tiempo_hace' => Carbon::parse($log->created_at)->diffForHumans(),
            ]);
        $actividades = $actividades->merge($completadas);

        $pesoReciente = DB::table('progress')
            ->whereIn('progress.client_id', $clientIds)
            ->where('progress.date', '>=', $today->copy()->subDays(7))
            ->join('clients', 'clients.user_id', '=', 'progress.client_id')
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->select('users.name as cliente_nombre', 'progress.weight', 'progress.created_at')
            ->orderByDesc('progress.date')
            ->limit(3)
            ->get()
            ->map(fn ($p) => [
                'tipo' => 'peso_registrado',
                'cliente_nombre' => $p->cliente_nombre,
                'detalle' => "registró {$p->weight} kg",
                'tiempo_hace' => Carbon::parse($p->created_at)->diffForHumans(),
            ]);
        $actividades = $actividades->merge($pesoReciente);

        $nuevos = Client::where('clients.coach_id', $coachId)
            ->where('clients.created_at', '>=', $today->copy()->subDays(30))
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->select('users.name as cliente_nombre', 'clients.created_at')
            ->orderByDesc('clients.created_at')
            ->limit(3)
            ->get()
            ->map(fn ($c) => [
                'tipo' => 'nuevo_cliente',
                'cliente_nombre' => $c->cliente_nombre,
                'detalle' => 'se unió a tu equipo',
                'tiempo_hace' => Carbon::parse($c->created_at)->diffForHumans(),
            ]);
        $actividades = $actividades->merge($nuevos);

        $actividades = $actividades->take(8)->values();

        return response()->json([
            'totalAtletas' => $totalAtletas,
            'nuevosEsteMes' => $nuevosEsteMes,
            'porcentajeCumplimiento' => $porcentajeCumplimiento,
            'alertasInactividad' => $alertasInactividad,
            'planesActivos' => $planesActivos,
            'clientes' => $clientes,
            'actividades' => $actividades,
        ]);
    }

    public function clientes(Request $request)
    {
        return response()->json(['message' => 'Listado de clientes — por implementar.'], 501);
    }

    public function planes(Request $request)
    {
        return response()->json(['message' => 'Planes de entrenamiento — por implementar.']);
    }
}
