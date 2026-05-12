<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Panen extends Model
{
    protected $fillable = [
        'lahan_id',
        'tanggal_panen',
        'jumlah_gabah',
        'harga_gabah_per_kg',
        'konversi_beras',
        'catatan',
    ];

    protected $casts = [
        'tanggal_panen' => 'date',
    ];

    public function lahan()
    {
        return $this->belongsTo(Lahan::class);
    }
}
