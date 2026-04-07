<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('nutrition_plan_assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('nutrition_plan_id')->constrained('nutrition_plans')->cascadeOnDelete();
            $table->foreignId('client_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('nutriologo_id')->constrained('nutriologos')->cascadeOnDelete();
            $table->date('assigned_at')->nullable();
            $table->date('starts_at')->nullable();
            $table->date('ends_at')->nullable();
            $table->enum('status', ['active', 'paused', 'completed', 'cancelled'])->default('active');
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['client_id', 'status']);
            $table->index(['nutriologo_id', 'status']);
            $table->unique(['nutrition_plan_id', 'client_id', 'starts_at'], 'nutrition_plan_client_start_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nutrition_plan_assignments');
    }
};
