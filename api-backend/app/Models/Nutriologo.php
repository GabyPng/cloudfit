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
    ];

    protected $casts = [
        'certificate_uploads' => 'array',
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