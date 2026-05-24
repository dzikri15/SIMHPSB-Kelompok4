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
        $activeConfig = $konfigurasi->firstWhere('is_active', true) ?? $konfigurasi->first();
        return view('admin.harga.index', compact('konfigurasi', 'activeConfig'));
    }

    public function create()
    {
        return view('admin.harga.create');
    }

    public function store(Request $request)
    {
        $this->normalizeNumericInputs($request);
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
        $this->normalizeNumericInputs($request);
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
        $this->normalizeNumericInputs($request);
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

    /**
     * Normalize currency / formatted numeric inputs to plain numeric strings
     * so validation accepts locale-formatted values like "760.000" or "13.500".
     */
    private function normalizeNumericInputs(Request $request)
    {
        $fields = ['harga_beli_gabah', 'ongkos_giling', 'harga_jual_beras', 'rasio_konversi'];
        foreach ($fields as $f) {
            if (!$request->has($f)) continue;
            $val = $request->input($f);
            if (is_null($val)) continue;
            // Remove any non-digit, non-comma, non-dot, non-minus chars
            $clean = preg_replace('/[^0-9,\.\-]/', '', (string) $val);
            // If there's a comma and no dot, convert comma to dot (e.g. "12,5")
            if (strpos($clean, ',') !== false && strpos($clean, '.') === false) {
                $clean = str_replace(',', '.', $clean);
            }
            // For currency inputs that use dot as thousands separator (e.g. "13.500"), remove dots
            // but keep decimal point if present (e.g. "1.234,56" -> "1234.56")
            // First, if both dot and comma exist, assume dot thousands and comma decimal
            if (strpos($clean, '.') !== false && strpos($clean, ',') !== false) {
                $clean = str_replace('.', '', $clean);
                $clean = str_replace(',', '.', $clean);
            } else {
                // If only dots present and there is no decimal part (common thousands sep), remove all dots
                if (strpos($clean, '.') !== false && preg_match('/\.\d{3}$/', $clean) === 1) {
                    $clean = str_replace('.', '', $clean);
                }
            }
            // Finally, if the cleaned value is numeric, merge back to request
            if (is_numeric($clean)) {
                // For integer-like fields, cast to appropriate format
                $request->merge([$f => $clean]);
            } else {
                // Fallback: strip all non-digits
                $digits = preg_replace('/\D/', '', $clean);
                $request->merge([$f => $digits]);
            }
        }
    }
}