<?php

namespace App\Http\Controllers\Coach;

use App\Http\Controllers\Controller;
use App\Models\Client;
use App\Models\Routine;
use App\Models\WorkoutLog;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class CoachWebController extends Controller
{
    /**
     * Dashboard principal del Coach.
     */
    public function inicio(Request $request)
    {
        $coachId = Auth::id();
        $today   = Carbon::today();

        // ── KPIs ────────────────────────────────────────────────────────

        // Total de atletas asignados a este coach
        $totalAtletas = Client::where('coach_id', $coachId)->count();

        // Nuevos clientes este mes
        $nuevosEsteMes = Client::where('coach_id', $coachId)
            ->whereYear('created_at', $today->year)
            ->whereMonth('created_at', $today->month)
            ->count();

        // Cumplimiento diario: % de clientes que completaron su rutina hoy
        $clientIds = Client::where('coach_id', $coachId)->pluck('user_id');

        $clientesConRutinaActiva = Routine::where('coach_id', $coachId)
            ->where('is_active', true)
            ->distinct('client_id')
            ->count('client_id');

        $entrenaronsHoy = WorkoutLog::whereIn('client_id', $clientIds)
            ->where('date', $today)
            ->where('is_complete', true)
            ->distinct('client_id')
            ->count('client_id');

        $porcentajeCumplimiento = $clientesConRutinaActiva > 0
            ? round(($entrenaronsHoy / $clientesConRutinaActiva) * 100)
            : 0;

        // Alertas de inactividad: clientes sin workout_log en los últimos 7 días
        $clientesActivos = WorkoutLog::whereIn('client_id', $clientIds)
            ->where('date', '>=', $today->copy()->subDays(7))
            ->distinct('client_id')
            ->pluck('client_id');

        $alertasInactividad = $clientIds->diff($clientesActivos)->count();

        // Planes (rutinas) activos
        $planesActivos = Routine::where('coach_id', $coachId)
            ->where('is_active', true)
            ->count();

        // ── Tabla: Monitoreo de Clientes ─────────────────────────────────

        $clientes = Client::where('clients.coach_id', $coachId)
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->leftJoin('routines', function ($join) {
                $join->on('routines.client_id', '=', 'clients.user_id')
                     ->where('routines.is_active', true);
            })
            ->leftJoin(
                DB::raw('(SELECT client_id, MAX(date) as last_date FROM workout_logs GROUP BY client_id) AS last_log'),
                'last_log.client_id', '=', 'clients.user_id'
            )
            ->leftJoin(
                DB::raw('(SELECT DISTINCT ON (client_id) client_id, weight, body_fat FROM progress ORDER BY client_id, date DESC) AS last_progress'),
                'last_progress.client_id', '=', 'clients.user_id'
            )
            ->select([
                'clients.user_id',
                'users.name as nombre',
                'users.avatar_url as avatar',
                'routines.name as plan_nombre',
                'last_log.last_date',
                'last_progress.weight as peso',
                'last_progress.body_fat as grasa',
            ])
            ->groupBy(
                'clients.user_id',
                'users.name',
                'users.avatar_url',
                'routines.name',
                'last_log.last_date',
                'last_progress.weight',
                'last_progress.body_fat'
            )
            ->orderBy('users.name')
            ->paginate(10)
            ->through(function ($row) use ($today) {
                $lastDate = $row->last_date ? Carbon::parse($row->last_date) : null;
                $inactive = !$lastDate || $lastDate->lt($today->copy()->subDays(7));

                $row->estado       = $inactive ? 'inactivo' : 'activo';
                $row->estado_label = $inactive ? 'Inactivo' : 'Entrenado';
                $row->plan_nombre  = $row->plan_nombre ?? 'Sin plan';
                $row->peso         = $row->peso ?? '—';
                $row->grasa        = $row->grasa ?? '—';

                return $row;
            });

        // ── Actividad Reciente ────────────────────────────────────────────

        $actividades = collect();

        // Rutinas completadas hoy/ayer
        $completadas = WorkoutLog::whereIn('workout_logs.client_id', $clientIds)
            ->where('workout_logs.is_complete', true)
            ->where('workout_logs.date', '>=', $today->copy()->subDays(3))
            ->join('clients', 'clients.user_id', '=', 'workout_logs.client_id')
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->join('routines', 'routines.id', '=', 'workout_logs.routine_id')
            ->select('users.name as cliente_nombre', 'routines.name as rutina_nombre', 'workout_logs.date', 'workout_logs.created_at')
            ->orderByDesc('workout_logs.date')
            ->limit(5)
            ->get()
            ->map(fn ($log) => (object) [
                'tipo'           => 'rutina_completada',
                'cliente_nombre' => $log->cliente_nombre,
                'detalle'        => "completó {$log->rutina_nombre}",
                'tiempo_hace'    => Carbon::parse($log->created_at)->diffForHumans(),
            ]);
        $actividades = $actividades->merge($completadas);

        // Registros de peso recientes
        $pesoReciente = DB::table('progress')
            ->whereIn('progress.client_id', $clientIds)
            ->where('progress.date', '>=', $today->copy()->subDays(7))
            ->join('clients', 'clients.user_id', '=', 'progress.client_id')
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->select('users.name as cliente_nombre', 'progress.weight', 'progress.created_at')
            ->orderByDesc('progress.date')
            ->limit(3)
            ->get()
            ->map(fn ($p) => (object) [
                'tipo'           => 'peso_registrado',
                'cliente_nombre' => $p->cliente_nombre,
                'detalle'        => "registró {$p->weight} kg",
                'tiempo_hace'    => Carbon::parse($p->created_at)->diffForHumans(),
            ]);
        $actividades = $actividades->merge($pesoReciente);

        // Nuevos clientes recientes
        $nuevos = Client::where('clients.coach_id', $coachId)
            ->where('clients.created_at', '>=', $today->copy()->subDays(30))
            ->join('users', 'users.user_id', '=', 'clients.user_id')
            ->select('users.name as cliente_nombre', 'clients.created_at')
            ->orderByDesc('clients.created_at')
            ->limit(3)
            ->get()
            ->map(fn ($c) => (object) [
                'tipo'           => 'nuevo_cliente',
                'cliente_nombre' => $c->cliente_nombre,
                'detalle'        => 'se unió a tu equipo',
                'tiempo_hace'    => Carbon::parse($c->created_at)->diffForHumans(),
            ]);
        $actividades = $actividades->merge($nuevos);

        // Ordenar por más reciente
        $actividades = $actividades->sortByDesc('tiempo_hace')->take(8)->values();

        return view('pages.coach.inicio', compact(
            'totalAtletas',
            'nuevosEsteMes',
            'porcentajeCumplimiento',
            'alertasInactividad',
            'planesActivos',
            'clientes',
            'actividades',
        ));
    }

    public function clientes(Request $request)
    {
        // TODO: implementar vista de clientes
        return view('pages.coach.inicio', $this->emptyDashboardData());
    }

    public function rutinas(Request $request)
    {
        // TODO: implementar vista de rutinas
        return view('pages.coach.inicio', $this->emptyDashboardData());
    }

    public function progreso(Request $request)
    {
        // TODO: implementar vista de progreso
        return view('pages.coach.inicio', $this->emptyDashboardData());
    }

    public function perfil(Request $request)
    {
        // TODO: implementar vista de perfil
        return view('pages.coach.inicio', $this->emptyDashboardData());
    }

    private function emptyDashboardData(): array
    {
        return [
            'totalAtletas'           => 0,
            'nuevosEsteMes'          => 0,
            'porcentajeCumplimiento' => 0,
            'alertasInactividad'     => 0,
            'planesActivos'          => 0,
            'clientes'               => new \Illuminate\Pagination\LengthAwarePaginator([], 0, 10),
            'actividades'            => collect(),
        ];
    }
}
