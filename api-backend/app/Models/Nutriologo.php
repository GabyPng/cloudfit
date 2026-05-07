<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Nutriologo extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'license_number',
        'focus',
        'certificate_uploads',
        'bio',
        'specialties',
        'experience_years',
        'location',
        'consultation_price',
        'profile_visible',
        'social_links',
        'phone',
        'is_verified',
        'verified_at',
        'verified_by',
        'rejection_reason',
    ];

    protected $casts = [
        'certificate_uploads' => 'array',
        'specialties'         => 'array',
        'social_links'        => 'array',
        'profile_visible'     => 'boolean',
        'consultation_price'  => 'decimal:2',
        'is_verified'         => 'boolean',
        'verified_at'         => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function nutritionPlans()
    {
        return $this->hasMany(NutritionPlan::class, 'nutriologo_id');
    }

    public function nutritionPlanAssignments()
    {
        return $this->hasMany(NutritionPlanAssignment::class, 'nutriologo_id');
    }
}