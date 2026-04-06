<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NutritionPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'nutriologo_id',
        'title',
        'description',
        'goal',
        'daily_calories',
        'macro_targets',
        'is_active',
        'starts_at',
        'ends_at',
    ];

    protected $casts = [
        'macro_targets' => 'array',
        'is_active' => 'boolean',
        'starts_at' => 'date',
        'ends_at' => 'date',
    ];

    public function nutriologo()
    {
        return $this->belongsTo(Nutriologo::class, 'nutriologo_id');
    }

    public function meals()
    {
        return $this->hasMany(NutritionPlanMeal::class)->orderBy('position');
    }

    public function assignments()
    {
        return $this->hasMany(NutritionPlanAssignment::class);
    }
}
