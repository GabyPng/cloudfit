<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Coach extends Model
{
    protected $primaryKey = 'user_id';
    public $incrementing = false;

    protected $fillable = ['user_id'];

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
