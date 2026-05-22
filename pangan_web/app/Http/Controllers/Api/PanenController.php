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
            'lahan_id' => 'required|integer|exists:lahan,id',
            'tanggal_panen' => 'required|date',
            'jumlah_gabah' => 'required|numeric|min:0',
            'harga_gabah_per_kg' => 'nullable|numeric|min:0',
            'konversi_factor' => 'nullable|numeric|min:0|max:1',
            'catatan' => 'nullable|string',
        ]);

        $factor = $data['konversi_factor'] ?? 0.6;
        $data['konversi_beras'] = round($data['jumlah_gabah'] * $factor, 2);
        unset($data['konversi_factor']);

        $panen = Panen::create($data);

        return response()->json($panen, 201);
    }

    public function update(Request $request, Panen $panen)
    {
        $data = $request->validate([
            'lahan_id' => 'sometimes|required|integer|exists:lahan,id',
            'tanggal_panen' => 'sometimes|required|date',
            'jumlah_gabah' => 'sometimes|required|numeric|min:0',
            'harga_gabah_per_kg' => 'nullable|numeric|min:0',
            'konversi_factor' => 'nullable|numeric|min:0|max:1',
            'catatan' => 'nullable|string',
        ]);

        if (isset($data['konversi_factor']) || isset($data['jumlah_gabah'])) {
            $factor = $data['konversi_factor'] ?? 0.6;
            $jumlahGabah = $data['jumlah_gabah'] ?? $panen->jumlah_gabah;
            $data['konversi_beras'] = round($jumlahGabah * $factor, 2);
        }

        unset($data['konversi_factor']);
        $panen->update($data);

        return response()->json($panen);
    }

    public function destroy(Panen $panen)
    {
        $panen->delete();

        return response()->json(null, 204);
    }
}
