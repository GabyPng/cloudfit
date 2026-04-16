<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Client extends Model
{
    protected $primaryKey = 'user_id';
    public $incrementing = false;

    protected $fillable = [
        'user_id',
        'coach_id',
        'nutritionist_id',
        'birth_date',
        'height',
        'goal',
    ];

    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
            'height'     => 'decimal:2',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'user_id');
    }

    public function coach()
    {
        return $this->belongsTo(Coach::class, 'coach_id', 'user_id');
    }

    public function routines()
    {
        return $this->hasMany(Routine::class, 'client_id', 'user_id');
    }

    public function workoutLogs()
    {
        return $this->hasMany(WorkoutLog::class, 'client_id', 'user_id');
    }

    public function progressRecords()
    {
        return $this->hasMany(Progress::class, 'client_id', 'user_id');
    }

    public function latestProgress()
    {
        return $this->hasOne(Progress::class, 'client_id', 'user_id')->latestOfMany('date');
    }
}
