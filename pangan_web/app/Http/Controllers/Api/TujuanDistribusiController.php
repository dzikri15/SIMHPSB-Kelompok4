<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TujuanDistribusi;
use Illuminate\Http\Request;

class TujuanDistribusiController extends Controller
{
    /**
     * GET /api/tujuan-distribusi
     * Ambil semua tujuan distribusi
     */
    public function index()
    {
        $tujuanList = TujuanDistribusi::orderBy('nama')->get();
        return response()->json($tujuanList);
    }

    /**
     * GET /api/tujuan-distribusi/{id}
     */
    public function show(TujuanDistribusi $tujuanDistribusi)
    {
        return response()->json($tujuanDistribusi);
    }

    /**
     * POST /api/tujuan-distribusi
     * Buat tujuan distribusi baru (admin only)
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:255|unique:tujuan_distribusi,nama',
        ]);

        $tujuan = TujuanDistribusi::create($data);

        return response()->json($tujuan, 201);
    }

    /**
     * PUT /api/tujuan-distribusi/{id}
     * Update tujuan distribusi (admin only)
     */
    public function update(Request $request, TujuanDistribusi $tujuanDistribusi)
    {
        $data = $request->validate([
            'nama' => 'sometimes|required|string|max:255|unique:tujuan_distribusi,nama,' . $tujuanDistribusi->id,
        ]);

        $tujuanDistribusi->update($data);

        return response()->json($tujuanDistribusi);
    }

    /**
     * DELETE /api/tujuan-distribusi/{id}
     * Hapus tujuan distribusi (admin only)
     */
    public function destroy(TujuanDistribusi $tujuanDistribusi)
    {
        $tujuanDistribusi->delete();

        return response()->json(null, 204);
    }
}
