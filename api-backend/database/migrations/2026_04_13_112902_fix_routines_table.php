<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        if (Schema::hasColumn('routines', 'client_id')) {
            return;
        }

        Schema::table('routines', function (Blueprint $table) {
            $table->dropForeign(['user_id']);

            if (Schema::hasColumn('routines', 'user_id') && ! Schema::hasColumn('routines', 'client_id')) {
                $table->renameColumn('user_id', 'client_id');
            }

            $table->foreign('client_id')->references('user_id')->on('clients')->cascadeOnDelete();
        });
    }

    public function down()
    {
        if (Schema::hasColumn('routines', 'user_id')) {
            return;
        }

        Schema::table('routines', function (Blueprint $table) {
            $table->dropForeign(['client_id']);
            if (Schema::hasColumn('routines', 'client_id') && ! Schema::hasColumn('routines', 'user_id')) {
                $table->renameColumn('client_id', 'user_id');
            }
            $table->foreign('user_id')->references('user_id')->on('users')->cascadeOnDelete();
        });
    }
};
