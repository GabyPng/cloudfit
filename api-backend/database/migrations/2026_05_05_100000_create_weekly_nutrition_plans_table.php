<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('weekly_nutrition_plans', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('client_id');
            $table->foreign('client_id')->references('user_id')->on('users')->cascadeOnDelete();
            $table->foreignId('nutriologo_id')->constrained('nutriologos')->cascadeOnDelete();
            $table->foreignId('nutrition_plan_id')->constrained('nutrition_plans')->cascadeOnDelete();
            $table->string('day_of_week', 3); // Mon Tue Wed Thu Fri Sat Sun
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['client_id', 'nutriologo_id']);
        });

        Schema::table('clients', function (Blueprint $table) {
            if (! Schema::hasColumn('clients', 'weekly_nutrition_notes')) {
                $table->text('weekly_nutrition_notes')->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('weekly_nutrition_plans');

        Schema::table('clients', function (Blueprint $table) {
            if (Schema::hasColumn('clients', 'weekly_nutrition_notes')) {
                $table->dropColumn('weekly_nutrition_notes');
            }
        });
    }
};
