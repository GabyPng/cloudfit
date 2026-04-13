<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('routines', function (Blueprint $table) {
            // Drop the existing foreign key (it references users.user_id)
            // The default naming convention in Laravel is "table_column_foreign", e.g., "routines_user_id_foreign"
            $table->dropForeign(['user_id']); // this will drop the foreign key by column name

            // Rename the column if it exists and the new name doesn't already exist
            if (Schema::hasColumn('routines', 'user_id') && !Schema::hasColumn('routines', 'client_id')) {
                $table->renameColumn('user_id', 'client_id');
            }

            // Add the new foreign key referencing clients.user_id
            $table->foreign('client_id')->references('user_id')->on('clients')->cascadeOnDelete();
        });
    }

    public function down()
    {
        Schema::table('routines', function (Blueprint $table) {
            $table->dropForeign(['client_id']);
            if (Schema::hasColumn('routines', 'client_id') && !Schema::hasColumn('routines', 'user_id')) {
                $table->renameColumn('client_id', 'user_id');
            }
            $table->foreign('user_id')->references('user_id')->on('users')->cascadeOnDelete();
        });
    }
};