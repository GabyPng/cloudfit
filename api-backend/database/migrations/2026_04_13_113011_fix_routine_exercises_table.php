<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('exercise_catalog')) {
            Schema::create('exercise_catalog', function (Blueprint $table) {
                $table->id('exercise_id');
                $table->string('name')->unique();
                $table->timestamps();
            });
        }

        DB::statement("
            INSERT INTO exercise_catalog (name, created_at, updated_at)
            SELECT DISTINCT exercise_name, NOW(), NOW()
            FROM routine_exercises
            WHERE exercise_name IS NOT NULL
            ON CONFLICT (name) DO NOTHING
        ");

        if (!Schema::hasColumn('routine_exercises', 'exercise_id')) {
            Schema::table('routine_exercises', function (Blueprint $table) {
                $table->unsignedBigInteger('exercise_id')->nullable();
            });
        }

        DB::statement("
            UPDATE routine_exercises re
            SET exercise_id = ec.exercise_id
            FROM exercise_catalog ec
            WHERE re.exercise_name = ec.name
        ");

        DB::statement('ALTER TABLE routine_exercises ALTER COLUMN exercise_id SET NOT NULL');
        DB::statement('ALTER TABLE routine_exercises DROP CONSTRAINT IF EXISTS routine_exercises_pkey');
        DB::statement('ALTER TABLE routine_exercises DROP CONSTRAINT IF EXISTS routine_exercises_exercise_id_foreign');

        Schema::table('routine_exercises', function (Blueprint $table) {
            $table->foreign('exercise_id')->references('exercise_id')->on('exercise_catalog')->cascadeOnDelete();
        });

        DB::statement('ALTER TABLE routine_exercises ADD PRIMARY KEY (exercise_id, routine_id)');
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE routine_exercises DROP CONSTRAINT IF EXISTS routine_exercises_exercise_id_foreign');
        DB::statement('ALTER TABLE routine_exercises DROP CONSTRAINT IF EXISTS routine_exercises_pkey');

        if (Schema::hasColumn('routine_exercises', 'exercise_id')) {
            Schema::table('routine_exercises', function (Blueprint $table) {
                $table->dropColumn('exercise_id');
            });
        }

        if (Schema::hasColumn('routine_exercises', 'id')) {
            DB::statement('ALTER TABLE routine_exercises ADD PRIMARY KEY (id)');
        }

        Schema::dropIfExists('exercise_catalog');
    }
};
