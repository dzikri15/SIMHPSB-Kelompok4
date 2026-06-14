<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TujuanDistribusi;
use Illuminate\Http\Request;

class TujuanDistribusiController extends Controller
{
    /**
     * GET /api/tujuan-distribusi
     * Ambil semua tujuan distribusi (untuk dropdown Flutter)
     */
    public function index()
    {
        $tujuans = TujuanDistribusi::orderBy('nama')->get();

        return response()->json($tujuans);
    }

    /**
     * POST /api/tujuan-distribusi
     * Tambah tujuan distribusi baru
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:255|unique:tujuan_distribusi,nama',
        ]);

        $tujuan = TujuanDistribusi::create(['nama' => trim($data['nama'])]);

        return response()->json($tujuan, 201);
    }

    /**
     * DELETE /api/tujuan-distribusi/{id}
     * Hapus tujuan distribusi (hanya jika belum dipakai di transaksi)
     */
    public function destroy(int $id)
    {
        $tujuan = TujuanDistribusi::findOrFail($id);

        // Cek apakah sudah dipakai di kolom keterangan stok
        $used = \App\Models\Stok::whereNotNull('keterangan')
            ->where('keterangan', 'like', "%{$tujuan->nama}%")
            ->exists();

        if ($used) {
            return response()->json([
                'message' => 'Tujuan distribusi tidak dapat dihapus karena sudah digunakan di transaksi.',
            ], 422);
        }

        $tujuan->delete();

        return response()->json(null, 204);
    }
}
