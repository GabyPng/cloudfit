<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('diet_change_requests', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('client_id');
            $table->foreign('client_id')->references('user_id')->on('users')->cascadeOnDelete();
            $table->unsignedBigInteger('proposed_by');
            $table->foreign('proposed_by')->references('user_id')->on('users')->cascadeOnDelete();
            $table->foreignId('assignment_id')->nullable()->constrained('nutrition_plan_assignments')->nullOnDelete();
            $table->enum('change_type', ['plan_change', 'meal_update', 'macro_adjust', 'calorie_adjust', 'observation']);
            $table->json('previous_value')->nullable();
            $table->json('new_value')->nullable();
            $table->text('reason');
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->text('client_response')->nullable();
            $table->timestamp('responded_at')->nullable();
            $table->date('date');
            $table->timestamps();

            $table->index(['client_id', 'status']);
            $table->index(['proposed_by', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('diet_change_requests');
    }
};
