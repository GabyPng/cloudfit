<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Routine extends Model
{
    protected $fillable = [
        'name',
        'description',
        'client_id',
        'coach_id',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    public function client()
    {
        return $this->belongsTo(Client::class, 'client_id', 'user_id');
    }

    public function coach()
    {
        return $this->belongsTo(Coach::class, 'coach_id', 'user_id');
    }

    public function workoutLogs()
    {
        return $this->hasMany(WorkoutLog::class, 'routine_id');
    }
}
