<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NutritionPlanAssignment extends Model
{
    use HasFactory;

    protected $fillable = [
        'nutrition_plan_id',
        'client_id',
        'nutriologo_id',
        'assigned_at',
        'starts_at',
        'ends_at',
        'status',
        'notes',
    ];

    protected $casts = [
        'assigned_at' => 'date',
        'starts_at' => 'date',
        'ends_at' => 'date',
    ];

    public function nutritionPlan()
    {
        return $this->belongsTo(NutritionPlan::class);
    }

    public function client()
    {
        return $this->belongsTo(User::class, 'client_id');
    }

    public function nutriologo()
    {
        return $this->belongsTo(Nutriologo::class, 'nutriologo_id');
    }
}
