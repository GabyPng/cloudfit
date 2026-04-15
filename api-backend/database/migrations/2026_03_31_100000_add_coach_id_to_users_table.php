<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('users', 'coach_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->foreignId('coach_id')->nullable()->constrained('users')->onDelete('set null');
            });
        }
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE users DROP CONSTRAINT IF EXISTS users_coach_id_foreign');

        if (Schema::hasColumn('users', 'coach_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('coach_id');
            });
        }
    }
};