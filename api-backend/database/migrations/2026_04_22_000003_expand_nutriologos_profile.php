<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('nutriologos', function (Blueprint $table) {
            $table->text('bio')->nullable()->after('focus');
            $table->json('specialties')->nullable()->after('bio');
            $table->unsignedSmallInteger('experience_years')->nullable()->after('specialties');
            $table->string('location', 100)->nullable()->after('experience_years');
            $table->decimal('consultation_price', 8, 2)->nullable()->after('location');
            $table->boolean('profile_visible')->default(true)->after('consultation_price');
            $table->json('social_links')->nullable()->after('profile_visible');
            $table->string('phone', 20)->nullable()->after('social_links');
        });
    }

    public function down(): void
    {
        Schema::table('nutriologos', function (Blueprint $table) {
            $table->dropColumn([
                'bio', 'specialties', 'experience_years', 'location',
                'consultation_price', 'profile_visible', 'social_links', 'phone',
            ]);
        });
    }
};
