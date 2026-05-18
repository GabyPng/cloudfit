<?php

namespace App\Http\Controllers\Coach;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class WeeklyPlanController extends Controller
{
    private const VALID_DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    private function coachId(Request $request): ?int
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return null;
        }

        return Cache::remember('coach_uid_'.md5($email), 300, fn () => User::where('email', $email)->value('user_id'));
    }

    /**
     * GET /api/coach/weekly-plan/{clientId}
     *
     * Returns the weekly plan for a client as:
     * { plan: { Mon: [routineId, ...], Tue: [], ... }, notes: "..." }
     */
    public function show(Request $request, int $clientId): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (! $coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $entries = DB::table('weekly_plans')
            ->where('client_id', $clientId)
            ->where('coach_id', $coachId)
            ->orderBy('day_of_week')
            ->orderBy('sort_order')
            ->get(['day_of_week', 'routine_id']);

        $plan = array_fill_keys(self::VALID_DAYS, []);
        foreach ($entries as $entry) {
            $plan[$entry->day_of_week][] = $entry->routine_id;
        }

        $notes = DB::table('clients')
            ->where('user_id', $clientId)
            ->value('weekly_plan_notes') ?? '';

        return response()->json(compact('plan', 'notes'));
    }

    /**
     * POST /api/coach/weekly-plan/{clientId}
     *
     * Full-replace save. Body:
     * { plan: { Mon: [routineId, ...], ... }, notes: "..." }
     */
    public function save(Request $request, int $clientId): JsonResponse
    {
        $coachId = $this->coachId($request);
        if (! $coachId) {
            return response()->json(['error' => 'Coach no encontrado'], 404);
        }

        $validated = $request->validate([
            'plan' => 'required|array',
            'plan.*' => 'array',
            'plan.*.*' => 'integer|exists:routines,id',
            'notes' => 'nullable|string|max:2000',
        ]);

        DB::transaction(function () use ($clientId, $coachId, $validated) {
            DB::table('weekly_plans')
                ->where('client_id', $clientId)
                ->where('coach_id', $coachId)
                ->delete();

            $rows = [];
            $now = now();

            foreach (self::VALID_DAYS as $day) {
                foreach (($validated['plan'][$day] ?? []) as $order => $routineId) {
                    $rows[] = [
                        'client_id' => $clientId,
                        'coach_id' => $coachId,
                        'routine_id' => $routineId,
                        'day_of_week' => $day,
                        'sort_order' => $order,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ];
                }
            }

            if ($rows) {
                DB::table('weekly_plans')->insert($rows);
            }

            DB::table('clients')
                ->where('user_id', $clientId)
                ->update(['weekly_plan_notes' => $validated['notes'] ?: null]);
        });

        return response()->json(['ok' => true]);
    }
}
