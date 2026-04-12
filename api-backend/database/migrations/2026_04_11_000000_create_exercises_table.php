<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('exercises', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->string('category');
            $table->text('description')->nullable();
            $table->string('image_url')->nullable();
            $table->integer('sets')->default(3);
            $table->integer('reps')->nullable();
            $table->string('difficulty')->default('intermediate');
            $table->integer('duration')->nullable();
            $table->text('instructions')->nullable();
            $table->timestamps();

            $table->index('category');
            $table->index('difficulty');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exercises');
    }
};
