<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Routine extends Model
{
    protected $fillable = [
        'name',
        'description',
        'client_id',
        'coach_id',
        'is_active',
        'tag',
        'icon_type',
        'accent_color',
        'difficulty',
        'difficulty_label',
        'duration_label',
        'training_plan',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'difficulty' => 'integer',
        ];
    }

    /* ── Relationships ───────────────────────────────────────────── */

    public function client()
    {
        return $this->belongsTo(Client::class, 'client_id', 'user_id');
    }

    public function coach()
    {
        return $this->belongsTo(Coach::class, 'coach_id', 'user_id');
    }

    public function exercises()
    {
        return $this->hasMany(RoutineExercise::class)->orderBy('order');
    }

    public function assignments()
    {
        return $this->hasMany(RoutineAssignment::class);
    }

    public function workoutLogs()
    {
        return $this->hasMany(WorkoutLog::class, 'routine_id');
    }

    /* ── Scopes ──────────────────────────────────────────────────── */

    /**
     * Filter by level: basics (difficulty <= 40), advanced (difficulty > 40), or all.
     */
    public function scopeLevel($query, string $level)
    {
        return match ($level) {
            'basics' => $query->where('difficulty', '<=', 40),
            'advanced' => $query->where('difficulty', '>', 40),
            default => $query,
        };
    }

    /* ── Computed Attributes ─────────────────────────────────────── */

    /**
     * Total volume = SUM(sets * reps * weight) across exercises.
     */
    public function getTotalVolumeAttribute(): int
    {
        return (int) $this->exercises->sum(function ($ex) {
            return ($ex->sets ?? 0) * ((int) $ex->reps ?: 0) * ((float) $ex->weight ?: 0);
        });
    }

    /**
     * Estimated duration in minutes = COUNT(exercises) * 15.
     */
    public function getEstDurationAttribute(): int
    {
        return $this->exercises->count() * 15;
    }
}
