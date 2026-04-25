<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProgressRecord extends Model
{
    protected $fillable = [
        'client_id',
        'author_id',
        'author_role',
        'date',
        'weight_kg',
        'bmi',
        'body_fat_pct',
        'muscle_mass_kg',
        'calories_target',
        'adherence_pct',
        'notes',
    ];

    protected $casts = [
        'date'           => 'date',
        'weight_kg'      => 'decimal:2',
        'bmi'            => 'decimal:2',
        'body_fat_pct'   => 'decimal:2',
        'muscle_mass_kg' => 'decimal:2',
    ];

    public function client(): BelongsTo
    {
        return $this->belongsTo(User::class, 'client_id', 'user_id');
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id', 'user_id');
    }

    public function scopeByClient($query, int $clientId)
    {
        return $query->where('client_id', $clientId);
    }

    public function scopeByAuthor($query, int $authorId)
    {
        return $query->where('author_id', $authorId);
    }

    public function scopeByRole($query, string $role)
    {
        return $query->where('author_role', $role);
    }
}
