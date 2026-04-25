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
use Illuminate\Support\Facades\DB;

class CoachController extends Controller
{
    /**
     * Resuelve el user_id local del coach a partir del supabase_uid del token.
     */
    private function resolveCoachId(Request $request): ?int
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) {
            return null;
        }

        return User::where('email', $email)->value('user_id');
    }

    public function dashboard(Request $request)
    {
        $coachId = $this->resolveCoachId($request);
        if (!$coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $today = Carbon::today();

        // ── KPIs ────────────────────────────────────────────────────
        $totalAtletas = Client::where('coach_id', $coachId)->count();

        $nuevosEsteMes = Client::where('coach_id', $coachId)
            ->whereYear('created_at', $today->year)
            ->whereMonth('created_at', $today->month)
            ->count();

        $clientIds = Client::where('coach_id', $coachId)->pluck('user_id');

        $clientesConRutinaActiva = DB::table('routine_assignments')
            ->where('coach_id', $coachId)
            ->where('status', 'active')
            ->distinct('client_id')
            ->count('client_id');

        $entrenaronHoy = WorkoutLog::whereIn('client_id', $clientIds)
            ->where('date', $today)
            ->where('is_complete', true)
            ->distinct('client_id')
            ->count('client_id');

        $porcentajeCumplimiento = $clientesConRutinaActiva > 0
            ? round(($entrenaronHoy / $clientesConRutinaActiva) * 100)
            : 0;

        $clientesActivos = WorkoutLog::whereIn('client_id', $clientIds)
            ->where('date', '>=', $today->copy()->subDays(7))
            ->distinct('client_id')
            ->pluck('client_id');

        $alertasInactividad = $clientIds->diff($clientesActivos)->count();

        $planesActivos = Routine::where('coach_id', $coachId)
            ->where('is_active', true)
            ->count();

        // ── Clientes ────────────────────────────────────────────────
        $clientes = Client::where('clients.coach_id', $coachId)
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->leftJoin(
                DB::raw('(SELECT client_id, MAX(date) as last_date FROM workout_logs GROUP BY client_id) AS last_log'),
                'last_log.client_id', '=', 'clients.user_id'
            )
            ->leftJoin(
                DB::raw('(SELECT DISTINCT ON (client_id) client_id, weight, body_fat FROM progress ORDER BY client_id, date DESC) AS last_progress'),
                'last_progress.client_id', '=', 'clients.user_id'
            )
            ->select([
                'clients.user_id as id',
                'users.name as nombre',
                'users.avatar_url as avatar',
                'last_log.last_date',
                'last_progress.weight as peso',
                'last_progress.body_fat as grasa',
            ])
            ->orderBy('users.name')
            ->get();

        // Load active/paused routines for all clients in one query
        $clientIds = $clientes->pluck('id');
        $rutinasPorCliente = RoutineAssignment::whereIn('client_id', $clientIds)
            ->where('coach_id', $coachId)
            ->where('status', 'active')
            ->with('routine:id,name,icon_type,accent_color,tag')
            ->get()
            ->groupBy('client_id');

        $clientes = $clientes->map(function ($row) use ($today, $rutinasPorCliente) {
                $lastDate = $row->last_date ? Carbon::parse($row->last_date) : null;
                $inactive = !$lastDate || $lastDate->lt($today->copy()->subDays(7));

                $assignments = $rutinasPorCliente->get($row->id, collect());
                $rutinas = $assignments->map(fn ($a) => [
                    'id'          => $a->routine_id,
                    'name'        => $a->routine->name ?? 'Sin nombre',
                    'iconType'    => $a->routine->icon_type ?? 'dumbbell',
                    'accentColor' => $a->routine->accent_color ?? '#cafd00',
                    'tag'         => $a->routine->tag ?? null,
                ])->values()->toArray();

                return [
                    'id'           => $row->id,
                    'nombre'       => $row->nombre,
                    'avatar'       => $row->avatar,
                    'rutinas'      => $rutinas,
                    'estado'       => $inactive ? 'inactivo' : 'activo',
                    'estado_label' => $inactive ? 'Inactivo' : 'Entrenado',
                    'peso'         => $row->peso ? (float) $row->peso : null,
                    'grasa'        => $row->grasa ? (float) $row->grasa : null,
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
                'tipo'           => 'rutina_completada',
                'cliente_nombre' => $log->cliente_nombre,
                'detalle'        => "completó {$log->rutina_nombre}",
                'tiempo_hace'    => Carbon::parse($log->created_at)->diffForHumans(),
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
                'tipo'           => 'peso_registrado',
                'cliente_nombre' => $p->cliente_nombre,
                'detalle'        => "registró {$p->weight} kg",
                'tiempo_hace'    => Carbon::parse($p->created_at)->diffForHumans(),
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
                'tipo'           => 'nuevo_cliente',
                'cliente_nombre' => $c->cliente_nombre,
                'detalle'        => 'se unió a tu equipo',
                'tiempo_hace'    => Carbon::parse($c->created_at)->diffForHumans(),
            ]);
        $actividades = $actividades->merge($nuevos);

        $actividades = $actividades->take(8)->values();

        return response()->json([
            'totalAtletas'           => $totalAtletas,
            'nuevosEsteMes'          => $nuevosEsteMes,
            'porcentajeCumplimiento' => $porcentajeCumplimiento,
            'alertasInactividad'     => $alertasInactividad,
            'planesActivos'          => $planesActivos,
            'clientes'               => $clientes,
            'actividades'            => $actividades,
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
