<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('nutriologo_contact_requests', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('nutriologo_id');
            $table->foreign('nutriologo_id')->references('id')->on('nutriologos')->cascadeOnDelete();
            $table->unsignedBigInteger('client_id');
            $table->foreign('client_id')->references('user_id')->on('users')->cascadeOnDelete();
            $table->text('message')->nullable();
            $table->enum('status', ['pending', 'accepted', 'rejected'])->default('pending');
            $table->text('nutriologo_response')->nullable();
            $table->timestamp('responded_at')->nullable();
            $table->timestamps();

            $table->unique(['nutriologo_id', 'client_id']);
            $table->index(['nutriologo_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nutriologo_contact_requests');
    }
};
