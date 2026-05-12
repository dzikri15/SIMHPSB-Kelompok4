<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Stok extends Model
{
    protected $table = 'stok_beras';

    protected $fillable = [
        'gudang_id',
        'jumlah_stok',
        'batas_minimum',
        'tanggal_update',
        'catatan',
    ];

    protected $casts = [
        'tanggal_update' => 'date',
    ];

    public function gudang()
    {
        return $this->belongsTo(Gudang::class);
    }
}
