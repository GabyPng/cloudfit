<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('nutriologos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('license_number', 100);
            $table->string('focus', 100);
            $table->json('certificate_uploads')->nullable();
            $table->timestamps();

            $table->index('focus');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nutriologos');
    }
};
