<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DietChangeRequest extends Model
{
    protected $fillable = [
        'client_id',
        'proposed_by',
        'assignment_id',
        'change_type',
        'previous_value',
        'new_value',
        'reason',
        'status',
        'client_response',
        'responded_at',
        'date',
    ];

    protected $casts = [
        'previous_value' => 'array',
        'new_value'      => 'array',
        'date'           => 'date',
        'responded_at'   => 'datetime',
    ];

    public function client(): BelongsTo
    {
        return $this->belongsTo(User::class, 'client_id', 'user_id');
    }

    public function proposer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'proposed_by', 'user_id');
    }

    public function assignment(): BelongsTo
    {
        return $this->belongsTo(NutritionPlanAssignment::class, 'assignment_id');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeByClient($query, int $clientId)
    {
        return $query->where('client_id', $clientId);
    }

    public function scopeByProposer($query, int $proposerId)
    {
        return $query->where('proposed_by', $proposerId);
    }
}
