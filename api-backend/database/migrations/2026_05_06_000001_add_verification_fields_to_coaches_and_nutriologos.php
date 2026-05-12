<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('coaches', function (Blueprint $table) {
            $table->json('certificate_uploads')->nullable()->after('user_id');
            $table->boolean('is_verified')->default(false)->after('certificate_uploads');
            $table->timestamp('verified_at')->nullable()->after('is_verified');
            $table->unsignedBigInteger('verified_by')->nullable()->after('verified_at');
            $table->text('rejection_reason')->nullable()->after('verified_by');
            $table->text('bio')->nullable()->after('rejection_reason');
            $table->json('specialties')->nullable()->after('bio');
            $table->unsignedSmallInteger('experience_years')->nullable()->after('specialties');
            $table->string('location', 100)->nullable()->after('experience_years');
            $table->decimal('session_price', 8, 2)->nullable()->after('location');
            $table->boolean('profile_visible')->default(true)->after('session_price');
            $table->json('social_links')->nullable()->after('profile_visible');
            $table->string('phone', 20)->nullable()->after('social_links');
            $table->string('specialty', 100)->nullable()->after('phone');
        });

        Schema::table('nutriologos', function (Blueprint $table) {
            $table->boolean('is_verified')->default(false)->after('profile_visible');
            $table->timestamp('verified_at')->nullable()->after('is_verified');
            $table->unsignedBigInteger('verified_by')->nullable()->after('verified_at');
            $table->text('rejection_reason')->nullable()->after('verified_by');
        });
    }

    public function down(): void
    {
        Schema::table('coaches', function (Blueprint $table) {
            $table->dropColumn([
                'certificate_uploads', 'is_verified', 'verified_at', 'verified_by',
                'rejection_reason', 'bio', 'specialties', 'experience_years',
                'location', 'session_price', 'profile_visible', 'social_links',
                'phone', 'specialty',
            ]);
        });

        Schema::table('nutriologos', function (Blueprint $table) {
            $table->dropColumn(['is_verified', 'verified_at', 'verified_by', 'rejection_reason']);
        });
    }
};
