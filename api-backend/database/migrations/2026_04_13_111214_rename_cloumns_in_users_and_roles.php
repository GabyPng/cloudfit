<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // Users table: only rename 'id' to 'user_id'
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'id') && !Schema::hasColumn('users', 'user_id')) {
                $table->renameColumn('id', 'user_id');
            }
            // Drop supabase_id if exists
            if (Schema::hasColumn('users', 'supabase_id')) {
                $table->dropColumn('supabase_id');
            }
            // Do NOT rename name, email, password, etc. – they are already English
        });

        // Roles table: rename 'id' to 'role_id'
        Schema::table('roles', function (Blueprint $table) {
            if (Schema::hasColumn('roles', 'id') && !Schema::hasColumn('roles', 'role_id')) {
                $table->renameColumn('id', 'role_id');
            }
            // 'name' and 'description' stay as is
        });

        // Update foreign key in users: role_id should reference roles.role_id
        Schema::table('users', function (Blueprint $table) {
            // Drop existing foreign key if it references roles.id
            $table->dropForeign(['role_id']);
            // Re-add foreign key referencing roles.role_id
            $table->foreign('role_id')->references('role_id')->on('roles')->nullOnDelete();
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['role_id']);
            if (Schema::hasColumn('users', 'user_id') && !Schema::hasColumn('users', 'id')) {
                $table->renameColumn('user_id', 'id');
            }
        });
        Schema::table('roles', function (Blueprint $table) {
            if (Schema::hasColumn('roles', 'role_id') && !Schema::hasColumn('roles', 'id')) {
                $table->renameColumn('role_id', 'id');
            }
        });
        // Re-add old FK if needed (omitted for brevity)
    }
};