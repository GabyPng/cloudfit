<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    use HasFactory;

    protected $primaryKey = 'role_id';

    protected $fillable = [
        'name',
        'description',
    ];

    public function getIdAttribute(): ?int
    {
        return $this->attributes['role_id'] ?? null;
    }

    public function users()
    {
        return $this->hasMany(User::class, 'role_id', 'role_id');
    }
}