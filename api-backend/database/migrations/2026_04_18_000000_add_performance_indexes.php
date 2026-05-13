<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Speed up currentNutriologo() email lookup
        Schema::table('users', function (Blueprint $table) {
            if (! $this->indexExists('users', 'users_email_index')) {
                $table->index('email', 'users_email_index');
            }
        });

        // Speed up the latest-assignment JOIN used in clientes()
        // Covers: WHERE nutriologo_id = ? AND client_id = ? ORDER BY updated_at DESC
        Schema::table('nutrition_plan_assignments', function (Blueprint $table) {
            if (! $this->indexExists('nutrition_plan_assignments', 'npa_nutriologo_client_updated_idx')) {
                $table->index(['nutriologo_id', 'client_id', 'updated_at'], 'npa_nutriologo_client_updated_idx');
            }
        });

        // Speed up clients.nutritionist_id lookup in clientes() WHERE clause
        Schema::table('clients', function (Blueprint $table) {
            if (! $this->indexExists('clients', 'clients_nutritionist_id_index')) {
                $table->index('nutritionist_id', 'clients_nutritionist_id_index');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_email_index');
        });

        Schema::table('nutrition_plan_assignments', function (Blueprint $table) {
            $table->dropIndex('npa_nutriologo_client_updated_idx');
        });

        Schema::table('clients', function (Blueprint $table) {
            $table->dropIndex('clients_nutritionist_id_index');
        });
    }

    private function indexExists(string $table, string $index): bool
    {
        return match (DB::getDriverName()) {
            'mysql' => collect(DB::select(
                "SHOW INDEX FROM `{$table}` WHERE Key_name = ?",
                [$index]
            ))->isNotEmpty(),
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
