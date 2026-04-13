<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // Drop the exercises table only if it exists
        if (Schema::hasTable('exercises')) {
            Schema::drop('exercises');
        }
    }

    public function down()
    {
        // If you ever need to restore it, you can recreate the schema
        // But since it was unused, we leave the down() empty or optional.
        // To be safe, we provide a minimal recreation (without foreign keys).
        if (!Schema::hasTable('exercises')) {
            Schema::create('exercises', function ($table) {
                $table->id();
                $table->string('name');
                $table->string('category')->nullable();
                $table->text('description')->nullable();
                $table->string('image_url')->nullable();
                $table->integer('sets')->nullable();
                $table->integer('reps')->nullable();
                $table->string('difficulty')->nullable();
                $table->integer('duration')->nullable();
                $table->text('instructions')->nullable();
                $table->timestamps();
            });
        }
    }
};