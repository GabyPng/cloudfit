<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('daily_water_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('client_id');
            $table->foreign('client_id')->references('user_id')->on('users')->cascadeOnDelete();
            $table->date('date');
            $table->unsignedTinyInteger('glasses_consumed')->default(0);
            $table->unsignedTinyInteger('glasses_target')->default(8);
            $table->timestamps();

            $table->unique(['client_id', 'date']);
            $table->index(['client_id', 'date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_water_logs');
    }
};
