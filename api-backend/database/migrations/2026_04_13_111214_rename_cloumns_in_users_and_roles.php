<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'id') && !Schema::hasColumn('users', 'user_id')) {
                $table->renameColumn('id', 'user_id');
            }
            if (Schema::hasColumn('users', 'supabase_id')) {
                $table->dropColumn('supabase_id');
            }
        });

        Schema::table('roles', function (Blueprint $table) {
            if (Schema::hasColumn('roles', 'id') && !Schema::hasColumn('roles', 'role_id')) {
                $table->renameColumn('id', 'role_id');
            }
        });

        DB::statement('ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_id_foreign');

        if (Schema::hasColumn('users', 'role_id') && Schema::hasColumn('roles', 'role_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->foreign('role_id')->references('role_id')->on('roles')->nullOnDelete();
            });
        }
    }

    public function down()
    {
        DB::statement('ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_id_foreign');

        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'user_id') && !Schema::hasColumn('users', 'id')) {
                $table->renameColumn('user_id', 'id');
            }
        });

        Schema::table('roles', function (Blueprint $table) {
            if (Schema::hasColumn('roles', 'role_id') && !Schema::hasColumn('roles', 'id')) {
                $table->renameColumn('role_id', 'id');
            }
        });
    }
};