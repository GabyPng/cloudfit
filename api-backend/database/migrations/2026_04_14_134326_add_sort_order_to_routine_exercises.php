<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('routine_exercises', function (Blueprint $table) {
            if (! Schema::hasColumn('routine_exercises', 'sort_order')) {
                $table->integer('sort_order')->nullable()->after('notes');
            }
        });
    }

    public function down()
    {
        Schema::table('routine_exercises', function (Blueprint $table) {
            $table->dropColumn('sort_order');
        });
    }
};
