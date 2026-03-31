<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('routine_exercises', function (Blueprint $table) {
            $table->id();
            // Relación con la rutina principal
            $table->foreignId('routine_id')->constrained('routines')->onDelete('cascade');
            
            $table->string('exercise_name'); // Ej: Press de Banca
            $table->integer('sets');          // Ej: 4
            $table->string('reps');          // Usamos string por si es "10-12" o "Al fallo"
            $table->string('rest_time')->nullable(); // Ej: "90 seg"
            $table->text('notes')->nullable();       // Ej: "Controlar el descenso"
            
            $table->integer('order')->default(0);    // Para ordenar los ejercicios en la lista
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('routine_exercises');
    }
};