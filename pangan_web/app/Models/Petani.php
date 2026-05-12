<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Petani extends Model
{
    protected $fillable = [
        'nama',
        'alamat',
        'no_hp',
        'email',
        'tanggal_lahir',
        'status',
    ];

    public function lahan()
    {
        return $this->hasMany(Lahan::class);
    }
}
