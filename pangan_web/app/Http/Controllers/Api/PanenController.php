<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Panen;
use Illuminate\Http\Request;

class PanenController extends Controller
{
    public function index()
    {
        return Panen::with('lahan.petani')->paginate(15);
    }

    public function show(Panen $panen)
    {
        return $panen->load('lahan.petani');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'lahan_id'         => 'required|integer|exists:lahan,id',
            'tanggal_panen'    => 'required|date',
            'jumlah_gabah'     => 'required|numeric|min:0',
            'harga_gabah_per_kg' => 'nullable|numeric|min:0',
            // konversi_factor dikirim Flutter sebagai 0–1 (misal 0.55 = 55%)
            'konversi_factor'  => 'nullable|numeric|min:0|max:1',
            'catatan'          => 'nullable|string',
            // field dari Flutter
            'musim_tanam'      => 'nullable|string|max:100',
            'komoditas'        => 'nullable|string|max:50',
            'petani_id'        => 'nullable|integer|exists:petani,id',
        ]);

        // Hitung beras hasil: gabah × factor
        // Simpan hasil ke konversi_beras (bukan persentase, tapi hasil kg)
        $factor = $data['konversi_factor'] ?? 0.615;
        $data['konversi_beras'] = round($data['jumlah_gabah'] * $factor, 2);

        // Map musim_tanam (Flutter) → musim (DB)
        if (!empty($data['musim_tanam'])) {
            $data['musim'] = $data['musim_tanam'];
        }

        // Bersihkan field yang tidak ada di DB
        unset($data['konversi_factor'], $data['musim_tanam'], $data['komoditas'], $data['petani_id']);

        $panen = Panen::create($data);

        return response()->json($panen->load('lahan.petani'), 201);
    }

    public function update(Request $request, Panen $panen)
    {
        $data = $request->validate([
            'lahan_id'         => 'sometimes|required|integer|exists:lahan,id',
            'tanggal_panen'    => 'sometimes|required|date',
            'jumlah_gabah'     => 'sometimes|required|numeric|min:0',
            'harga_gabah_per_kg' => 'nullable|numeric|min:0',
            'konversi_factor'  => 'nullable|numeric|min:0|max:1',
            'catatan'          => 'nullable|string',
            'musim_tanam'      => 'nullable|string|max:100',
            'komoditas'        => 'nullable|string|max:50',
            'petani_id'        => 'nullable|integer',
        ]);

        if (isset($data['konversi_factor']) || isset($data['jumlah_gabah'])) {
            $factor      = $data['konversi_factor'] ?? 0.615;
            $jumlahGabah = $data['jumlah_gabah'] ?? $panen->jumlah_gabah;
            $data['konversi_beras'] = round($jumlahGabah * $factor, 2);
        }

        if (!empty($data['musim_tanam'])) {
            $data['musim'] = $data['musim_tanam'];
        }

        unset($data['konversi_factor'], $data['musim_tanam'], $data['komoditas'], $data['petani_id']);

        $panen->update($data);

        return response()->json($panen->fresh()->load('lahan.petani'));
    }

    public function destroy(Panen $panen)
    {
        $panen->delete();

        return response()->json(null, 204);
    }
}
