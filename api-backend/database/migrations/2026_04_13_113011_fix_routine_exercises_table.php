<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Create a temporary catalog of exercises
        Schema::create('exercise_catalog', function (Blueprint $table) {
            $table->id('exercise_id');
            $table->string('name')->unique();
            $table->timestamps();
        });

        // Insert unique exercise names from routine_exercises
        DB::statement("
            INSERT INTO exercise_catalog (name, created_at, updated_at)
            SELECT DISTINCT exercise_name, NOW(), NOW()
            FROM routine_exercises
            WHERE exercise_name IS NOT NULL
            ON CONFLICT (name) DO NOTHING
        ");

        // Add exercise_id column
        Schema::table('routine_exercises', function (Blueprint $table) {
            $table->unsignedBigInteger('exercise_id')->nullable();
        });

        // Update exercise_id from catalog
        DB::statement("
            UPDATE routine_exercises re
            SET exercise_id = ec.exercise_id
            FROM exercise_catalog ec
            WHERE re.exercise_name = ec.name
        ");

        // Make exercise_id NOT NULL, drop old PK, add composite PK
        Schema::table('routine_exercises', function (Blueprint $table) {
            $table->unsignedBigInteger('exercise_id')->nullable(false)->change();
            $table->dropPrimary('routine_exercises_pkey'); // adjust name if needed
            $table->primary(['exercise_id', 'routine_id']);
            $table->foreign('exercise_id')->references('exercise_id')->on('exercise_catalog')->cascadeOnDelete();
        });
    }

    public function down()
    {
        Schema::table('routine_exercises', function (Blueprint $table) {
            $table->dropForeign(['exercise_id']);
            $table->dropPrimary(['exercise_id', 'routine_id']);
            $table->dropColumn('exercise_id');
            $table->id()->first();
        });
        Schema::dropIfExists('exercise_catalog');
    }
};