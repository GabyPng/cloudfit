<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // workout_logs: dashboard filters by (client_id, date, is_complete) and (client_id, date)
        if (Schema::hasTable('workout_logs')) {
            Schema::table('workout_logs', function (Blueprint $table) {
                if (!$this->indexExists('workout_logs', 'wl_client_date_complete_idx')) {
                    $table->index(['client_id', 'date', 'is_complete'], 'wl_client_date_complete_idx');
                }
            });
        }

        // progress (coach table): subquery orders by (client_id, date DESC)
        if (Schema::hasTable('progress')) {
            Schema::table('progress', function (Blueprint $table) {
                if (!$this->indexExists('progress', 'progress_client_date_idx')) {
                    $table->index(['client_id', 'date'], 'progress_client_date_idx');
                }
            });
        }

        // routine_assignments: filters by (coach_id, status) and (client_id, coach_id, status)
        if (Schema::hasTable('routine_assignments')) {
            Schema::table('routine_assignments', function (Blueprint $table) {
                if (!$this->indexExists('routine_assignments', 'ra_coach_status_idx')) {
                    $table->index(['coach_id', 'status'], 'ra_coach_status_idx');
                }
                if (!$this->indexExists('routine_assignments', 'ra_client_coach_status_idx')) {
                    $table->index(['client_id', 'coach_id', 'status'], 'ra_client_coach_status_idx');
                }
            });
        }

        // nutrition_plan_assignments: dashboard aggregates by (nutriologo_id, status)
        if (Schema::hasTable('nutrition_plan_assignments')) {
            Schema::table('nutrition_plan_assignments', function (Blueprint $table) {
                if (!$this->indexExists('nutrition_plan_assignments', 'npa_nutriologo_status_idx')) {
                    $table->index(['nutriologo_id', 'status'], 'npa_nutriologo_status_idx');
                }
            });
        }

        // routine_exercises: eager-loaded ordered by (routine_id, order)
        if (Schema::hasTable('routine_exercises')) {
            Schema::table('routine_exercises', function (Blueprint $table) {
                if (!$this->indexExists('routine_exercises', 're_routine_order_idx')) {
                    $table->index(['routine_id', 'order'], 're_routine_order_idx');
                }
            });
        }

        // clients: nuevos-este-mes count filters by (coach_id, created_at)
        if (Schema::hasTable('clients')) {
            Schema::table('clients', function (Blueprint $table) {
                if (!$this->indexExists('clients', 'clients_coach_created_idx')) {
                    $table->index(['coach_id', 'created_at'], 'clients_coach_created_idx');
                }
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('workout_logs')) {
            Schema::table('workout_logs', fn ($t) => $t->dropIndexIfExists('wl_client_date_complete_idx'));
        }
        if (Schema::hasTable('progress')) {
            Schema::table('progress', fn ($t) => $t->dropIndexIfExists('progress_client_date_idx'));
        }
        if (Schema::hasTable('routine_assignments')) {
            Schema::table('routine_assignments', function ($t) {
                $t->dropIndexIfExists('ra_coach_status_idx');
                $t->dropIndexIfExists('ra_client_coach_status_idx');
            });
        }
        if (Schema::hasTable('nutrition_plan_assignments')) {
            Schema::table('nutrition_plan_assignments', fn ($t) => $t->dropIndexIfExists('npa_nutriologo_status_idx'));
        }
        if (Schema::hasTable('routine_exercises')) {
            Schema::table('routine_exercises', fn ($t) => $t->dropIndexIfExists('re_routine_order_idx'));
        }
        if (Schema::hasTable('clients')) {
            Schema::table('clients', fn ($t) => $t->dropIndexIfExists('clients_coach_created_idx'));
        }
    }

    private function indexExists(string $table, string $index): bool
    {
        return match (DB::getDriverName()) {
            'pgsql' => collect(DB::select(
                'SELECT 1 FROM pg_indexes WHERE schemaname = ANY(current_schemas(false)) AND tablename = ? AND indexname = ?',
                [$table, $index]
            ))->isNotEmpty(),
            'mysql' => collect(DB::select("SHOW INDEX FROM `{$table}` WHERE Key_name = ?", [$index]))->isNotEmpty(),
            'sqlite' => collect(DB::select("PRAGMA index_list('{$table}')"))->contains(fn ($r) => ($r->name ?? null) === $index),
            default => false,
        };
    }
};
