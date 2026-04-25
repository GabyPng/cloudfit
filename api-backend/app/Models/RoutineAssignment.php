<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RoutineAssignment extends Model
{
    protected $table = 'routine_assignments';

    protected $fillable = [
        'client_id',
        'routine_id',
        'coach_id',
        'status',
        'assigned_at',
    ];

    protected function casts(): array
    {
        return [
            'assigned_at' => 'datetime',
        ];
    }

    public function client()
    {
        return $this->belongsTo(Client::class, 'client_id', 'user_id');
    }

    public function routine()
    {
        return $this->belongsTo(Routine::class);
    }

    public function coach()
    {
        return $this->belongsTo(Coach::class, 'coach_id', 'user_id');
    }
}
