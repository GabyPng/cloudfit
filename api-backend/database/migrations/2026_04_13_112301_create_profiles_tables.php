<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        if (! Schema::hasTable('coaches')) {
            Schema::create('coaches', function (Blueprint $table) {
                $table->foreignId('user_id')->primary()->constrained('users', 'user_id')->cascadeOnDelete();
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('admins')) {
            Schema::create('admins', function (Blueprint $table) {
                $table->foreignId('user_id')->primary()->constrained('users', 'user_id')->cascadeOnDelete();
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('clients')) {
            Schema::create('clients', function (Blueprint $table) {
                $table->foreignId('user_id')->primary()->constrained('users', 'user_id')->cascadeOnDelete();
                $table->foreignId('coach_id')->nullable()->constrained('coaches', 'user_id')->nullOnDelete();
                $table->foreignId('nutritionist_id')->nullable()->constrained('nutriologos', 'user_id')->nullOnDelete();
                $table->date('birth_date')->nullable();
                $table->decimal('height', 5, 2)->nullable();
                $table->string('goal')->nullable();
                $table->timestamps();
            });
        }

        // Migrate existing users based on role names
        DB::statement("
            INSERT INTO coaches (user_id, created_at, updated_at)
            SELECT u.user_id, u.created_at, u.updated_at
            FROM users u
            JOIN roles r ON u.role_id = r.role_id
            WHERE r.name = 'coach'
            ON CONFLICT (user_id) DO NOTHING
        ");

        DB::statement("
            INSERT INTO admins (user_id, created_at, updated_at)
            SELECT u.user_id, u.created_at, u.updated_at
            FROM users u
            JOIN roles r ON u.role_id = r.role_id
            WHERE r.name = 'admin'
            ON CONFLICT (user_id) DO NOTHING
        ");

        DB::statement("
            INSERT INTO clients (user_id, created_at, updated_at)
            SELECT u.user_id, u.created_at, u.updated_at
            FROM users u
            JOIN roles r ON u.role_id = r.role_id
            WHERE r.name = 'client'
            ON CONFLICT (user_id) DO NOTHING
        ");

        // If you had a coach_id column in users, copy it to clients.coach_id
        if (Schema::hasColumn('users', 'coach_id')) {
            if (DB::getDriverName() === 'sqlite') {
                DB::statement('UPDATE clients SET coach_id = (SELECT coach_id FROM users WHERE clients.user_id = users.user_id AND users.coach_id IS NOT NULL) WHERE EXISTS (SELECT 1 FROM users WHERE clients.user_id = users.user_id AND users.coach_id IS NOT NULL)');
            } else {
                DB::statement('UPDATE clients c SET coach_id = u.coach_id FROM users u WHERE c.user_id = u.user_id AND u.coach_id IS NOT NULL');
            }
            Schema::table('users', function (Blueprint $table) {
                $table->dropForeign(['coach_id']);
                $table->dropColumn('coach_id');
            });
        }
    }

    public function down()
    {
        Schema::dropIfExists('clients');
        Schema::dropIfExists('admins');
        Schema::dropIfExists('coaches');
    }
};
