<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RoutineExercise extends Model
{
    protected $table = 'routine_exercises';

    protected $fillable = [
        'routine_id',
        'exercise_id',
        'exercise_name',
        'sets',
        'reps',
        'rest_time',
        'weight',
        'notes',
        'order',
    ];

    protected function casts(): array
    {
        return [
            'sets' => 'integer',
            'order' => 'integer',
        ];
    }

    public function routine()
    {
        return $this->belongsTo(Routine::class);
    }
}
