<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Progress extends Model
{
    protected $table = 'progress';
    protected $primaryKey = 'progress_id';

    protected $fillable = [
        'client_id',
        'weight',
        'body_fat',
        'bmi',
        'date',
    ];

    protected function casts(): array
    {
        return [
            'weight'   => 'decimal:2',
            'body_fat' => 'decimal:2',
            'bmi'      => 'decimal:2',
            'date'     => 'date',
        ];
    }

    public function client()
    {
        return $this->belongsTo(Client::class, 'client_id', 'user_id');
    }
}
