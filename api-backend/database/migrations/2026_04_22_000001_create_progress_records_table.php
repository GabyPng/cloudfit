<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('progress_records', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('client_id');
            $table->foreign('client_id')->references('user_id')->on('users')->cascadeOnDelete();
            $table->unsignedBigInteger('author_id');
            $table->foreign('author_id')->references('user_id')->on('users')->cascadeOnDelete();
            $table->enum('author_role', ['coach', 'nutriologo', 'cliente']);
            $table->date('date');
            $table->decimal('weight_kg', 5, 2)->nullable();
            $table->decimal('bmi', 5, 2)->nullable();
            $table->decimal('body_fat_pct', 5, 2)->nullable();
            $table->decimal('muscle_mass_kg', 5, 2)->nullable();
            $table->integer('calories_target')->nullable();
            $table->integer('adherence_pct')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['client_id', 'date']);
            $table->index(['author_id', 'author_role']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('progress_records');
    }
};
