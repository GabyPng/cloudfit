<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ticket extends Model
{
    protected $primaryKey = 'ticket_id';

    protected $fillable = [
        'user_id',
        'subject',
        'status',
        'category',
        'urgency',
        'resolved_at',
        'assigned_admin_id',
    ];

    protected $casts = [
        'resolved_at' => 'datetime',
        'created_at'  => 'datetime',
        'updated_at'  => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'user_id');
    }

    public function messages()
    {
        return $this->hasMany(Message::class, 'ticket_id', 'ticket_id');
    }
}
