<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WorkoutLog extends Model
{
    protected $primaryKey = 'log_id';

    protected $fillable = [
        'client_id',
        'routine_id',
        'date',
        'is_complete',
    ];

    protected function casts(): array
    {
        return [
            'date'        => 'date',
            'is_complete' => 'boolean',
        ];
    }

    public function client()
    {
        return $this->belongsTo(Client::class, 'client_id', 'user_id');
    }

    public function routine()
    {
        return $this->belongsTo(Routine::class, 'routine_id');
    }
}
