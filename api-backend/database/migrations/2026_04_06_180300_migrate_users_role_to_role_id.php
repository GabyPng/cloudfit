<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('users', 'role_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->foreignId('role_id')->nullable()->after('email')->constrained('roles')->nullOnDelete();
            });
        }

        DB::statement("\n            UPDATE users\n            SET role_id = roles.id\n            FROM roles\n            WHERE LOWER(CAST(users.role AS TEXT)) = LOWER(roles.name)\n        ");

        $clienteRoleId = DB::table('roles')->where('name', 'cliente')->value('id');
        if ($clienteRoleId) {
            DB::table('users')->whereNull('role_id')->update(['role_id' => $clienteRoleId]);
        }

        if (Schema::hasColumn('users', 'role')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('role');
            });
        }
    }

    public function down(): void
    {
        if (!Schema::hasColumn('users', 'role')) {
            Schema::table('users', function (Blueprint $table) {
                $table->enum('role', ['admin', 'coach', 'nutriologo', 'cliente'])->default('cliente')->after('email');
            });
        }

        DB::statement("\n            UPDATE users\n            SET role = roles.name\n            FROM roles\n            WHERE users.role_id = roles.id\n        ");

        DB::statement('ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_id_foreign');

        if (Schema::hasColumn('users', 'role_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('role_id');
            });
        }
    }
};