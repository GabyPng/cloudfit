<?php

namespace App\Http\Controllers\Nutriologo;

use App\Http\Controllers\Controller;
use App\Models\Nutriologo;
use App\Models\NutritionPlanAssignment;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WeeklyNutritionPlanController extends Controller
{
    private const VALID_DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    private const DAY_MAP = [
        0 => 'Sun',
        1 => 'Mon',
        2 => 'Tue',
        3 => 'Wed',
        4 => 'Thu',
        5 => 'Fri',
        6 => 'Sat',
    ];

    private function currentNutriologo(Request $request): ?Nutriologo
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return null;
        }

        $user = User::where('email', $email)->value('user_id');
        if (! $user) {
            return null;
        }

        return Nutriologo::where('user_id', $user)->first();
    }

    /**
     * GET /api/nutriologo/weekly-plan/{clientId}
     */
    public function show(Request $request, int $clientId): JsonResponse
    {
        $nutriologo = $this->currentNutriologo($request);
        if (! $nutriologo) {
            return response()->json(['error' => 'No autorizado'], 401);
        }

        $entries = DB::table('weekly_nutrition_plans')
            ->where('client_id', $clientId)
            ->where('nutriologo_id', $nutriologo->id)
            ->orderBy('day_of_week')
            ->orderBy('sort_order')
            ->get(['day_of_week', 'nutrition_plan_id']);

        $plan = array_fill_keys(self::VALID_DAYS, []);
        foreach ($entries as $entry) {
            $plan[$entry->day_of_week][] = $entry->nutrition_plan_id;
        }

        $notes = DB::table('clients')
            ->where('user_id', $clientId)
            ->value('weekly_nutrition_notes') ?? '';

        return response()->json(compact('plan', 'notes'));
    }

    /**
     * POST /api/nutriologo/weekly-plan/{clientId}
     *
     * Full-replace. Body: { plan: { Mon: [planId,...], ... }, notes: "..." }
     * Also syncs today's plan into nutrition_plan_assignments for Flutter.
     */
    public function save(Request $request, int $clientId): JsonResponse
    {
        $nutriologo = $this->currentNutriologo($request);
        if (! $nutriologo) {
            return response()->json(['error' => 'No autorizado'], 401);
        }

        $validated = $request->validate([
            'plan' => 'required|array',
            'plan.*' => 'array',
            'plan.*.*' => 'integer|exists:nutrition_plans,id',
            'notes' => 'nullable|string|max:2000',
        ]);

        DB::transaction(function () use ($clientId, $nutriologo, $validated) {
            // Full-replace weekly plan
            DB::table('weekly_nutrition_plans')
                ->where('client_id', $clientId)
                ->where('nutriologo_id', $nutriologo->id)
                ->delete();

            $rows = [];
            $now = now();

            foreach (self::VALID_DAYS as $day) {
                foreach (($validated['plan'][$day] ?? []) as $order => $planId) {
                    $rows[] = [
                        'client_id' => $clientId,
                        'nutriologo_id' => $nutriologo->id,
                        'nutrition_plan_id' => $planId,
                        'day_of_week' => $day,
                        'sort_order' => $order,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ];
                }
            }

            if ($rows) {
                DB::table('weekly_nutrition_plans')->insert($rows);
            }

            DB::table('clients')
                ->where('user_id', $clientId)
                ->update(['weekly_nutrition_notes' => $validated['notes'] ?: null]);

            // Sync today's plan to nutrition_plan_assignments for Flutter compatibility
            $todayKey = self::DAY_MAP[(int) now()->dayOfWeek];
            $todayPlans = $validated['plan'][$todayKey] ?? [];

            if (! empty($todayPlans)) {
                $planId = (int) $todayPlans[0]; // Use first plan of the day
                $today = now()->toDateString();

                // Cancel other active assignments for this client by this nutriologo
                NutritionPlanAssignment::query()
                    ->where('client_id', $clientId)
                    ->where('nutriologo_id', $nutriologo->id)
                    ->where('status', 'active')
                    ->update(['status' => 'cancelled']);

                // Create or update today's active assignment
                NutritionPlanAssignment::query()->updateOrCreate(
                    [
                        'nutrition_plan_id' => $planId,
                        'client_id' => $clientId,
                        'starts_at' => $today,
                    ],
                    [
                        'nutriologo_id' => $nutriologo->id,
                        'assigned_at' => $today,
                        'status' => 'active',
                        'notes' => $validated['notes'] ?? null,
                    ]
                );
            }
        });

        return response()->json(['ok' => true]);
    }
}
