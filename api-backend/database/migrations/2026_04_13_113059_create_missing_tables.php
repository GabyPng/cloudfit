<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        if (!Schema::hasTable('workout_logs')) {
            Schema::create('workout_logs', function (Blueprint $table) {
                $table->id('log_id');
                $table->foreignId('client_id')->constrained('clients', 'user_id')->cascadeOnDelete();
                $table->foreignId('routine_id')->constrained('routines', 'id')->cascadeOnDelete();
                $table->date('date');
                $table->boolean('is_complete')->default(false);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('progress')) {
            Schema::create('progress', function (Blueprint $table) {
                $table->id('progress_id');
                $table->foreignId('client_id')->constrained('clients', 'user_id')->cascadeOnDelete();
                $table->decimal('weight', 5, 2)->nullable();
                $table->decimal('bmi', 5, 2)->nullable();
                $table->date('date');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tickets')) {
            Schema::create('tickets', function (Blueprint $table) {
                $table->id('ticket_id');
                $table->foreignId('user_id')->constrained('users', 'user_id')->cascadeOnDelete();
                $table->string('subject');
                $table->string('status')->default('open');
                $table->date('created_date')->useCurrent();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('messages')) {
            Schema::create('messages', function (Blueprint $table) {
                $table->id('message_id');
                $table->foreignId('ticket_id')->constrained('tickets', 'ticket_id')->cascadeOnDelete();
                $table->foreignId('sender_id')->constrained('users', 'user_id')->cascadeOnDelete();
                $table->text('content');
                $table->timestamp('sent_at')->useCurrent();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('managements')) {
            Schema::create('managements', function (Blueprint $table) {
                $table->id('management_id');
                $table->foreignId('admin_id')->constrained('admins', 'user_id')->cascadeOnDelete();
                $table->foreignId('user_id')->constrained('users', 'user_id')->cascadeOnDelete();
                $table->date('date')->useCurrent();
                $table->string('control_type');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('certificates')) {
            Schema::create('certificates', function (Blueprint $table) {
                $table->id('certificate_id');
                $table->foreignId('admin_id')->constrained('admins', 'user_id')->cascadeOnDelete();
                $table->foreignId('user_id')->constrained('users', 'user_id')->cascadeOnDelete();
                $table->string('title');
                $table->date('approval_date');
                $table->timestamps();
            });
        }
    }

    public function down()
    {
        Schema::dropIfExists('certificates');
        Schema::dropIfExists('managements');
        Schema::dropIfExists('messages');
        Schema::dropIfExists('tickets');
        Schema::dropIfExists('progress');
        Schema::dropIfExists('workout_logs');
    }
};
