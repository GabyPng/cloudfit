<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AnalyticsController extends Controller
{
    public function overview()
    {
        $totalUsers = User::count();
        $activeUsers7d = User::where('updated_at', '>=', now()->subDays(7))->count();
        $activeUsers30d = User::where('updated_at', '>=', now()->subDays(30))->count();

        $byRole = DB::table('users')
            ->join('roles', 'users.role_id', '=', 'roles.role_id')
            ->select('roles.name as role', DB::raw('count(*) as total'))
            ->groupBy('roles.name')
            ->pluck('total', 'role');

        $pendingVerification = DB::table('coaches')->where('is_verified', false)->count()
            + DB::table('nutriologos')->where('is_verified', false)->count();

        $openTickets = DB::table('tickets')->where('status', 'open')->count();

        $workoutLogsToday = DB::table('workout_logs')
            ->whereDate('date', today())
            ->count();

        return response()->json([
            'data' => [
                'total_users' => $totalUsers,
                'active_users_7d' => $activeUsers7d,
                'active_users_30d' => $activeUsers30d,
                'by_role' => $byRole,
                'pending_verification' => $pendingVerification,
                'open_tickets' => $openTickets,
                'workout_logs_today' => $workoutLogsToday,
            ],
        ]);
    }

    public function growth(Request $request)
    {
        $period = $request->query('period', 'week'); // week | month

        $days = $period === 'month' ? 30 : 7;

        $data = DB::table('users')
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as count'))
            ->where('created_at', '>=', now()->subDays($days))
            ->groupBy(DB::raw('DATE(created_at)'))
            ->orderBy('date')
            ->get();

        return response()->json(['data' => $data, 'period' => $period]);
    }

    public function professionals()
    {
        $coaches = DB::table('coaches')
            ->select(
                DB::raw('count(*) as total'),
                DB::raw('sum(case when is_verified then 1 else 0 end) as verified'),
                DB::raw('sum(case when not is_verified and rejection_reason is null then 1 else 0 end) as pending'),
                DB::raw('sum(case when not is_verified and rejection_reason is not null then 1 else 0 end) as rejected'),
            )
            ->first();

        $nutriologos = DB::table('nutriologos')
            ->select(
                DB::raw('count(*) as total'),
                DB::raw('sum(case when is_verified then 1 else 0 end) as verified'),
                DB::raw('sum(case when not is_verified and rejection_reason is null then 1 else 0 end) as pending'),
                DB::raw('sum(case when not is_verified and rejection_reason is not null then 1 else 0 end) as rejected'),
            )
            ->first();

        return response()->json([
            'data' => [
                'coaches' => $coaches,
                'nutriologos' => $nutriologos,
            ],
        ]);
    }

    public function usage()
    {
        $workoutLogs = DB::table('workout_logs')
            ->select(DB::raw('DATE(date) as date'), DB::raw('count(*) as count'))
            ->where('date', '>=', now()->subDays(14))
            ->groupBy(DB::raw('DATE(date)'))
            ->orderBy('date')
            ->get();

        $activePlans = DB::table('nutrition_plan_assignments')
            ->where('status', 'active')
            ->count();

        $ticketsByStatus = DB::table('tickets')
            ->select('status', DB::raw('count(*) as count'))
            ->groupBy('status')
            ->pluck('count', 'status');

        return response()->json([
            'data' => [
                'workout_logs_14d' => $workoutLogs,
                'active_nutrition_plans' => $activePlans,
                'tickets_by_status' => $ticketsByStatus,
            ],
        ]);
    }
}
