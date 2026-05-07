<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tickets', function (Blueprint $table) {
            if (!Schema::hasColumn('tickets', 'category')) {
                $table->enum('category', ['bug', 'duda', 'sugerencia'])->default('duda')->after('subject');
            }
            if (!Schema::hasColumn('tickets', 'urgency')) {
                $table->enum('urgency', ['baja', 'media', 'alta'])->default('media')->after('category');
            }
            if (!Schema::hasColumn('tickets', 'resolved_at')) {
                $table->timestamp('resolved_at')->nullable()->after('urgency');
            }
            if (!Schema::hasColumn('tickets', 'assigned_admin_id')) {
                $table->unsignedBigInteger('assigned_admin_id')->nullable()->after('resolved_at');
            }
        });
    }

    public function down(): void
    {
        Schema::table('tickets', function (Blueprint $table) {
            $table->dropColumn(['category', 'urgency', 'resolved_at', 'assigned_admin_id']);
        });
    }
};
