<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ── Enhance routines table ──────────────────────────────────────
        Schema::table('routines', function (Blueprint $table) {
            // The frontend needs these extra columns for the routine cards
            if (! Schema::hasColumn('routines', 'tag')) {
                $table->string('tag')->nullable()->after('name');
            }
            if (! Schema::hasColumn('routines', 'icon_type')) {
                $table->string('icon_type')->default('dumbbell')->after('tag');
                // "dumbbell" | "zap" | "heart"
            }
            if (! Schema::hasColumn('routines', 'accent_color')) {
                $table->string('accent_color')->default('#cafd00')->after('icon_type');
            }
            if (! Schema::hasColumn('routines', 'difficulty')) {
                $table->unsignedSmallInteger('difficulty')->default(50)->after('accent_color');
                // 0-100 scale; <=40 = basics, >40 = advanced
            }
            if (! Schema::hasColumn('routines', 'difficulty_label')) {
                $table->string('difficulty_label')->default('Intermedio')->after('difficulty');
            }
            if (! Schema::hasColumn('routines', 'duration_label')) {
                $table->string('duration_label')->nullable()->after('difficulty_label');
                // e.g. "8 semanas · 4 días/semana"
            }
            if (! Schema::hasColumn('routines', 'training_plan')) {
                $table->string('training_plan')->nullable()->after('duration_label');
                // e.g. "Fuerza Max", "Cardio Hit"
            }
        });

        // ── Add weight column to routine_exercises ──────────────────────
        Schema::table('routine_exercises', function (Blueprint $table) {
            if (! Schema::hasColumn('routine_exercises', 'weight')) {
                $table->string('weight')->nullable()->after('rest_time');
                // nullable = bodyweight exercises
            }
        });

        // ── Assignments table ───────────────────────────────────────────
        if (! Schema::hasTable('routine_assignments')) {
            Schema::create('routine_assignments', function (Blueprint $table) {
                $table->id();
                $table->foreignId('client_id')
                    ->constrained('clients', 'user_id')
                    ->cascadeOnDelete();
                $table->foreignId('routine_id')
                    ->constrained('routines', 'id')
                    ->cascadeOnDelete();
                $table->foreignId('coach_id')
                    ->constrained('coaches', 'user_id')
                    ->cascadeOnDelete();
                $table->string('status')->default('active');
                // "active" | "paused" | "completed"
                $table->timestamp('assigned_at')->useCurrent();
                $table->timestamps();

                // A client can only have one active assignment at a time
                // (enforced in business logic, not unique constraint,
                //  because historical records are kept)
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('routine_assignments');

        Schema::table('routine_exercises', function (Blueprint $table) {
            if (Schema::hasColumn('routine_exercises', 'weight')) {
                $table->dropColumn('weight');
            }
        });

        Schema::table('routines', function (Blueprint $table) {
            $cols = ['tag', 'icon_type', 'accent_color', 'difficulty', 'difficulty_label', 'duration_label', 'training_plan'];
            foreach ($cols as $col) {
                if (Schema::hasColumn('routines', $col)) {
                    $table->dropColumn($col);
                }
            }
        });
    }
};
