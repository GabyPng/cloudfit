<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class NutriologoContactRequest extends Model
{
    protected $fillable = [
        'nutriologo_id',
        'client_id',
        'message',
        'status',
        'nutriologo_response',
        'responded_at',
    ];

    protected $casts = [
        'responded_at' => 'datetime',
    ];

    public function nutriologo(): BelongsTo
    {
        return $this->belongsTo(Nutriologo::class, 'nutriologo_id');
    }

    public function client(): BelongsTo
    {
        return $this->belongsTo(User::class, 'client_id', 'user_id');
    }

    public function clientProfile(): BelongsTo
    {
        return $this->belongsTo(Client::class, 'client_id', 'user_id');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeByNutriologo($query, int $nutriologoId)
    {
        return $query->where('nutriologo_id', $nutriologoId);
    }
}
