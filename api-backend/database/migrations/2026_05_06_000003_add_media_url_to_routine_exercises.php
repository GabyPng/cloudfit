<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('routine_exercises', function (Blueprint $table) {
            $table->string('media_url')->nullable()->after('notes');
            $table->enum('media_type', ['gif', 'video', 'image'])->nullable()->after('media_url');
        });
    }

    public function down(): void
    {
        Schema::table('routine_exercises', function (Blueprint $table) {
            $table->dropColumn(['media_url', 'media_type']);
        });
    }
};
