<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Lahan;
use App\Models\Petani;

class Panen extends Model
{
    protected $table = 'panen';

    protected $fillable = [
        'lahan_id',
        'tanggal_panen',
        'jumlah_gabah',
        'harga_gabah_per_kg',
        'konversi_beras',
        'musim',
        'catatan',
    ];

    protected $casts = [
        'tanggal_panen' => 'date',
    ];

    public function lahan()
    {
        return $this->belongsTo(Lahan::class);
    }

    public function petani()
    {
        return $this->hasOneThrough(
            Petani::class,
            Lahan::class,
            'id',        // Foreign key on Lahan table...
            'id',        // Foreign key on Petani table...
            'lahan_id',  // Local key on Panen table...
            'petani_id'  // Local key on Lahan table...
        );
    }

    public function getTonaseGabahAttribute()
    {
        return $this->jumlah_gabah;
    }

    public function getBerasDihasilkanAttribute()
    {
        if (! $this->jumlah_gabah || ! $this->konversi_beras) {
            return 0;
        }

        return round($this->jumlah_gabah * ($this->konversi_beras / 100), 2);
    }
}
