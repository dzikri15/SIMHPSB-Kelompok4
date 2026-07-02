<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\KonfigurasiHarga;
use App\Models\Panen;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PetaniDashboardController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        $petani = $user->petani;

        if (!$petani) {
            abort(404, 'Data petani tidak ditemukan.');
        }

        $totalLahan = $petani->lahan()->count();
        $totalPanen = Panen::whereHas('lahan', function ($query) use ($petani) {
            $query->where('petani_id', $petani->id);
        })->count();

        $panens = Panen::whereHas('lahan', function ($query) use ($petani) {
            $query->where('petani_id', $petani->id);
        })
        ->with('lahan')
        ->orderByDesc('tanggal_panen')
        ->orderByDesc('id')
        ->get();

        $activePrice = KonfigurasiHarga::where('is_active', true)->first();
        $totalGabah = $panens->sum('jumlah_gabah');

        return view('petani.dashboard', compact('petani', 'totalLahan', 'totalPanen', 'panens', 'activePrice', 'totalGabah'));
    }
}
