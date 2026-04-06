<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('nutrition_plans', function (Blueprint $table) {
            $table->id();
            // Nutriologo que crea el plan.
            $table->foreignId('nutriologo_id')->constrained('nutriologos')->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('goal')->nullable();
            $table->unsignedSmallInteger('daily_calories')->nullable();
            $table->json('macro_targets')->nullable();
            $table->boolean('is_active')->default(true);
            $table->date('starts_at')->nullable();
            $table->date('ends_at')->nullable();
            $table->timestamps();

            $table->index(['nutriologo_id', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nutrition_plans');
    }
};
