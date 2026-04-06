<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     * Roles disponibles: admin, coach, nutriologo, cliente
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role_id',
        'avatar_url',
        'objective',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed',
        ];
    }

    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function nutriologoProfile()
    {
        return $this->hasOne(Nutriologo::class);
    }

    public function hasRole($roleName)
    {
        return $this->role && $this->role->name === (string) $roleName;
    }

    public function hasAnyRole(array $roleNames)
    {
        return $this->role && in_array($this->role->name, $roleNames, true);
    }

    public function nutritionPlansCreated()
    {
        return $this->hasManyThrough(
            NutritionPlan::class,
            Nutriologo::class,
            'user_id',
            'nutriologo_id',
            'id',
            'id'
        );
    }

    public function nutritionPlanAssignmentsAsClient()
    {
        return $this->hasMany(NutritionPlanAssignment::class, 'client_id');
    }

    public function nutritionPlanAssignmentsAsNutriologo()
    {
        return $this->hasManyThrough(
            NutritionPlanAssignment::class,
            Nutriologo::class,
            'user_id',
            'nutriologo_id',
            'id',
            'id'
        );
    }
}
