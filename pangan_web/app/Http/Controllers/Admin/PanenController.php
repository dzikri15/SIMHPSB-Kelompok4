<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Panen;
use App\Models\Petani;
use App\Models\Lahan;
use Illuminate\Http\Request;

class PanenController extends Controller
{
    public function index()
    {
        $petanis = Petani::orderBy('nama')->get();
        $panenList = Panen::with('lahan.petani')
            ->orderByDesc('tanggal_panen')
            ->limit(10)
            ->get();

        return view('admin.panen.index', compact('petanis', 'panenList'));
    }

    public function create()
    {
        $lahans = Lahan::with('petani')->get();
        return view('admin.panen.create', compact('lahans'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'petani_id'      => 'required|exists:petani,id',
            'musim'          => 'required|string|max:100',
            'tanggal_panen'  => 'required|date',
            'tonase_gabah'   => 'required|numeric|min:0.1',
            'rasio_konversi' => 'required|numeric|min:0|max:100',
            'komoditas'      => 'nullable|string|max:50',
            'catatan'        => 'nullable|string',
        ]);

        $petani = Petani::find($validated['petani_id']);
        $lahan  = $petani?->lahan()->first();

        if (! $lahan) {
            return back()
                ->withErrors(['petani_id' => 'Petani belum memiliki lahan terdaftar.'])
                ->withInput();
        }

        // Hitung hasil beras: gabah × (rasio/100)
        $hasilBeras = round($validated['tonase_gabah'] * ($validated['rasio_konversi'] / 100), 2);

        $catatan = trim(implode(' ', array_filter([
            $validated['komoditas'] ? 'Komoditas: ' . $validated['komoditas'] . '.' : null,
            $validated['catatan'] ?? null,
        ])));

        Panen::create([
            'lahan_id'      => $lahan->id,
            'tanggal_panen' => $validated['tanggal_panen'],
            'jumlah_gabah'  => $validated['tonase_gabah'],
            'konversi_beras' => $hasilBeras,   // <-- Simpan HASIL beras dalam kg
            'musim'         => $validated['musim'],
            'catatan'       => $catatan ?: null,
        ]);

        return redirect()->route('admin.panen.index')
            ->with('success', 'Data panen berhasil ditambahkan');
    }

    public function show($id)
    {
        $panen = Panen::with('lahan.petani')->findOrFail($id);
        return view('admin.panen.show', compact('panen'));
    }

    public function edit($id)
    {
        $panen  = Panen::findOrFail($id);
        $lahans = Lahan::with('petani')->get();
        return view('admin.panen.edit', compact('panen', 'lahans'));
    }

    public function update(Request $request, $id)
    {
        $panen = Panen::findOrFail($id);

        $validated = $request->validate([
            'lahan_id'       => 'required|exists:lahan,id',
            'jumlah_gabah'   => 'required|numeric|min:0.1',
            'tanggal_panen'  => 'required|date',
            'musim'          => 'nullable|string|max:100',
            'rasio_konversi' => 'nullable|numeric|min:0|max:100',
            'catatan'        => 'nullable|string',
        ]);

        // Hitung ulang beras jika ada rasio
        if (isset($validated['rasio_konversi'])) {
            $validated['konversi_beras'] = round(
                $validated['jumlah_gabah'] * ($validated['rasio_konversi'] / 100),
                2
            );
        }
        unset($validated['rasio_konversi']);

        $panen->update($validated);

        return redirect()->route('admin.panen.index')
            ->with('success', 'Data panen berhasil diperbarui');
    }

    public function destroy($id)
    {
        $panen = Panen::findOrFail($id);
        $panen->delete();

        return redirect()->route('admin.panen.index')
            ->with('success', 'Data panen berhasil dihapus');
    }
}
