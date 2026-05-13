<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // workout_logs(client_id, date) — used in fuerza(), fatiga(), entrenaronHoy, clientesActivos
        Schema::table('workout_logs', function (Blueprint $table) {
            if (! $this->indexExists('workout_logs', 'wl_client_date_idx')) {
                $table->index(['client_id', 'date'], 'wl_client_date_idx');
            }
        });

        // routines(coach_id, is_active) — used in planesActivos count and routines list
        Schema::table('routines', function (Blueprint $table) {
            if (! $this->indexExists('routines', 'routines_coach_active_idx')) {
                $table->index(['coach_id', 'is_active'], 'routines_coach_active_idx');
            }
            if (! $this->indexExists('routines', 'routines_client_active_idx')) {
                $table->index(['client_id', 'is_active'], 'routines_client_active_idx');
            }
        });

        // routine_assignments(coach_id, status) — used in clientesConRutinaActiva
        Schema::table('routine_assignments', function (Blueprint $table) {
            if (! $this->indexExists('routine_assignments', 'ra_coach_status_idx')) {
                $table->index(['coach_id', 'status'], 'ra_coach_status_idx');
            }
        });

        // users(role_id) — used in role resolution middleware and hasRole checks
        Schema::table('users', function (Blueprint $table) {
            if (! $this->indexExists('users', 'users_role_id_idx')) {
                $table->index('role_id', 'users_role_id_idx');
            }
        });
    }

    public function down(): void
    {
        Schema::table('workout_logs', function (Blueprint $table) {
            $table->dropIndex('wl_client_date_idx');
        });
        Schema::table('routines', function (Blueprint $table) {
            $table->dropIndex('routines_coach_active_idx');
            $table->dropIndex('routines_client_active_idx');
        });
        Schema::table('routine_assignments', function (Blueprint $table) {
            $table->dropIndex('ra_coach_status_idx');
        });
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_role_id_idx');
        });
    }

    private function indexExists(string $table, string $index): bool
    {
        return match (DB::getDriverName()) {
            'mysql' => collect(DB::select("SHOW INDEX FROM `{$table}` WHERE Key_name = ?", [$index]))->isNotEmpty(),
            'pgsql' => collect(DB::select(
                'SELECT 1 FROM pg_indexes WHERE schemaname = ANY (current_schemas(false)) AND tablename = ? AND indexname = ?',
                [$table, $index]
            ))->isNotEmpty(),
            'sqlite' => collect(DB::select("PRAGMA index_list('{$table}')"))
                ->contains(fn ($row) => ($row->name ?? null) === $index),
            default => false,
        };
    }
};
