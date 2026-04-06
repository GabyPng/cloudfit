<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('nutrition_plan_meals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('nutrition_plan_id')->constrained('nutrition_plans')->cascadeOnDelete();
            $table->enum('meal_type', ['desayuno', 'colacion_1', 'comida', 'colacion_2', 'cena']);
            $table->string('name');
            $table->string('portion')->nullable();
            $table->unsignedSmallInteger('calories')->nullable();
            $table->decimal('protein_g', 6, 2)->nullable();
            $table->decimal('carbs_g', 6, 2)->nullable();
            $table->decimal('fat_g', 6, 2)->nullable();
            $table->text('notes')->nullable();
            $table->unsignedSmallInteger('position')->default(0);
            $table->timestamps();

            $table->index(['nutrition_plan_id', 'meal_type']);
            $table->index(['nutrition_plan_id', 'position']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nutrition_plan_meals');
    }
};
