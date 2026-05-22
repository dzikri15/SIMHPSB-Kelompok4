<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

class Stok extends Model
{
    protected $table = 'stok_beras';

    protected $fillable = [
        'gudang_id',
        'jumlah_stok',
        'batas_minimum',
        'tanggal_update',
        'tanggal',
        'catatan',
    ];

    protected $casts = [
        'tanggal_update' => 'datetime',
        'tanggal' => 'datetime',
    ];

    public function getTanggalAttribute($value)
    {
        if ($value) {
            return Carbon::parse($value)->format('Y-m-d H:i:s');
        }

        if (! empty($this->attributes['tanggal_update'])) {
            return Carbon::parse($this->attributes['tanggal_update'])->format('Y-m-d H:i:s');
        }

        return null;
    }

    public function gudang()
    {
        return $this->belongsTo(Gudang::class);
    }
}
