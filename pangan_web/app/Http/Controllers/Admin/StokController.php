<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class StokController extends Controller
{
    public function index()
    {
        return view('admin.stok.index');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'jenis' => 'required|in:masuk,keluar',
            'komoditas' => 'required|string',
            'jumlah' => 'required|numeric|min:0',
            // allow nullable so we can auto-fill with current datetime when empty
            'tanggal' => 'nullable|date',
            'tujuan_distribusi' => 'nullable|string',
            'keterangan' => 'nullable|string',
            'catatan' => 'nullable|string',
        ]);

        // Normalize datetime-local (2026-05-21T05:40) → 'Y-m-d H:i:s'
        if (! empty($data['tanggal'])) {
            $tanggal = str_replace('T', ' ', $data['tanggal']);
            // append seconds if missing
            if (preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/', $tanggal)) {
                $tanggal .= ':00';
            }
        } else {
            // auto-fill current datetime when user didn't provide one
            $tanggal = now()->format('Y-m-d H:i:s');
        }

        // Build payload with safe defaults
        $payload = [
            'gudang_id' => 1,
            'jenis_transaksi' => $data['jenis'],
            'komoditas' => $data['komoditas'],
            'jumlah' => $data['jumlah'],
            'keterangan' => trim(($data['tujuan_distribusi'] ?? '') . ' ' . ($data['keterangan'] ?? '')) ?: null,
            'catatan' => $data['catatan'] ?? null,
            'created_at' => now(),
            'updated_at' => now(),
        ];

        // Store datetime to whichever column exists in this install
        if (Schema::hasColumn('stok_beras', 'tanggal_update')) {
            $payload['tanggal_update'] = $tanggal;
        } elseif (Schema::hasColumn('stok_beras', 'tanggal')) {
            $payload['tanggal'] = $tanggal;
        }

        DB::table('stok_beras')->insert($payload);

        return redirect()->back()->with('success', 'Transaksi stok tersimpan.');
    }

    public function show($id)
    {
        //
    }
}