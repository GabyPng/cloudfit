<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NutritionPlanMeal extends Model
{
    use HasFactory;

    protected $fillable = [
        'nutrition_plan_id',
        'meal_type',
        'name',
        'portion',
        'calories',
        'protein_g',
        'carbs_g',
        'fat_g',
        'notes',
        'position',
    ];

    protected $casts = [
        'calories' => 'integer',
        'protein_g' => 'float',
        'carbs_g' => 'float',
        'fat_g' => 'float',
        'position' => 'integer',
    ];

    public function nutritionPlan()
    {
        return $this->belongsTo(NutritionPlan::class);
    }
}
