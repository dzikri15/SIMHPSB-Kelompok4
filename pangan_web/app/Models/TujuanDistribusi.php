<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TujuanDistribusi extends Model
{
    use HasFactory;

    protected $table = 'tujuan_distribusi';

    protected $fillable = ['nama'];
}
