<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('weekly_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')
                  ->constrained('clients', 'user_id')
                  ->cascadeOnDelete();
            $table->foreignId('coach_id')
                  ->constrained('coaches', 'user_id')
                  ->cascadeOnDelete();
            $table->foreignId('routine_id')
                  ->constrained('routines', 'id')
                  ->cascadeOnDelete();
            $table->string('day_of_week', 3); // Mon Tue Wed Thu Fri Sat Sun
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['client_id', 'coach_id']);
        });

        // Notes field for the weekly plan (one per client)
        Schema::table('clients', function (Blueprint $table) {
            if (!Schema::hasColumn('clients', 'weekly_plan_notes')) {
                $table->text('weekly_plan_notes')->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('weekly_plans');

        Schema::table('clients', function (Blueprint $table) {
            if (Schema::hasColumn('clients', 'weekly_plan_notes')) {
                $table->dropColumn('weekly_plan_notes');
            }
        });
    }
};
