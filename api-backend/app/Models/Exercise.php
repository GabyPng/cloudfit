<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Exercise extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'category',
        'description',
        'image_url',
        'sets',
        'reps',
        'difficulty',
        'duration',
        'instructions',
    ];

    protected $casts = [
        'sets' => 'integer',
        'reps' => 'integer',
        'duration' => 'integer',
    ];

    public function toArray()
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'category' => $this->category,
            'description' => $this->description,
            'imageUrl' => $this->image_url,
            'sets' => $this->sets,
            'reps' => $this->reps,
            'difficulty' => $this->difficulty,
            'duration' => $this->duration,
            'instructions' => $this->instructions,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
