<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Coach extends Model
{
    protected $primaryKey = 'user_id';
    public $incrementing = false;

    protected $fillable = [
        'user_id',
        'certificate_uploads',
        'is_verified',
        'verified_at',
        'verified_by',
        'rejection_reason',
        'bio',
        'specialties',
        'experience_years',
        'location',
        'session_price',
        'profile_visible',
        'social_links',
        'phone',
        'specialty',
    ];

    protected $casts = [
        'certificate_uploads' => 'array',
        'specialties'         => 'array',
        'social_links'        => 'array',
        'profile_visible'     => 'boolean',
        'is_verified'         => 'boolean',
        'session_price'       => 'decimal:2',
        'verified_at'         => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'user_id');
    }

    public function clients()
    {
        return $this->hasMany(Client::class, 'coach_id', 'user_id');
    }

    public function routines()
    {
        return $this->hasMany(Routine::class, 'coach_id', 'user_id');
    }
}
