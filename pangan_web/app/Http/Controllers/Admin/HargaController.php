<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KonfigurasiHarga;
use Illuminate\Http\Request;

class HargaController extends Controller
{
    public function index()
    {
        $konfigurasi = KonfigurasiHarga::orderBy('berlaku_mulai', 'desc')->get();
        $activeConfig = $konfigurasi->firstWhere('is_active', true);
        return view('admin.harga.index', compact('konfigurasi', 'activeConfig'));
    }

    public function create()
    {
        return view('admin.harga.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'harga_beli_gabah' => 'required|numeric|min:0',
            'ongkos_giling' => 'required|numeric|min:0',
            'harga_jual_beras' => 'required|numeric|min:0',
            'rasio_konversi' => 'required|numeric|min:0|max:100',
            'berlaku_mulai' => 'required|date',
            'is_active' => 'nullable|boolean',
        ]);

        $isActive = $request->has('is_active');
        $validated['is_active'] = $isActive;

        if ($isActive) {
            KonfigurasiHarga::query()->update(['is_active' => false]);
        }

        KonfigurasiHarga::create($validated);

        return redirect()
            ->route('admin.harga.index')
            ->with('success', 'Konfigurasi Harga berhasil ditambahkan');
    }

    public function edit(KonfigurasiHarga $harga)
    {
        return view('admin.harga.edit', compact('harga'));
    }

    public function update(Request $request, KonfigurasiHarga $harga)
    {
        $validated = $request->validate([
            'harga_beli_gabah' => 'required|numeric|min:0',
            'ongkos_giling' => 'required|numeric|min:0',
            'harga_jual_beras' => 'required|numeric|min:0',
            'rasio_konversi' => 'required|numeric|min:0|max:100',
            'berlaku_mulai' => 'required|date',
            'is_active' => 'nullable|boolean',
        ]);

        $isActive = $request->has('is_active');
        $validated['is_active'] = $isActive;

        if ($isActive) {
            KonfigurasiHarga::query()->update(['is_active' => false]);
        }

        $harga->update($validated);

        return redirect()
            ->route('admin.harga.index')
            ->with('success', 'Konfigurasi Harga berhasil diperbarui');
    }

    public function destroy(KonfigurasiHarga $harga)
    {
        if ($harga->is_active) {
            return redirect()->back()->with('error', 'Tidak dapat menghapus konfigurasi yang sedang aktif!');
        }

        $harga->delete();
        return redirect()->back()->with('success', 'Konfigurasi Harga berhasil dihapus');
    }

    public function updateRasio(Request $request, KonfigurasiHarga $harga)
    {
        $validated = $request->validate([
            'rasio_konversi' => 'required|numeric|min:0|max:100',
        ]);

        $harga->update($validated);

        return redirect()
            ->route('admin.harga.index')
            ->with('success', 'Rasio Konversi Gabah → Beras berhasil disimpan');
    }

    public function activate(KonfigurasiHarga $harga)
    {
        KonfigurasiHarga::query()->update(['is_active' => false]);
        $harga->update(['is_active' => true]);

        return redirect()->back()->with('success', 'Konfigurasi Harga berhasil diaktifkan');
    }
}