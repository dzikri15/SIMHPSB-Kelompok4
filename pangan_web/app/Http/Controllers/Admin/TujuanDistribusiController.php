<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\TujuanDistribusi;
use App\Models\Stok;
use Illuminate\Http\Request;

class TujuanDistribusiController extends Controller
{
    public function index()
    {
        $tujuans = TujuanDistribusi::orderBy('nama')->get();

        return view('admin.tujuan-distribusi.index', [
            'tujuans' => $tujuans,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:255|unique:tujuan_distribusi,nama',
        ]);

        $tujuan = TujuanDistribusi::create(['nama' => trim($data['nama'])]);

        if ($request->wantsJson() || $request->ajax()) {
            return response()->json(['success' => true, 'data' => $tujuan]);
        }

        return redirect()->back()->with('success', 'Tujuan distribusi ditambahkan.');
    }

    public function destroy(int $id)
    {
        $tujuan = TujuanDistribusi::findOrFail($id);

        // Prevent deletion if used in stok_beras.keterangan
        $used = Stok::whereNotNull('keterangan')->where('keterangan', 'like', "%{$tujuan->nama}%")->exists();
        if ($used) {
            return redirect()->back()->with('error', 'Tujuan distribusi tidak dapat dihapus karena sudah digunakan di transaksi.');
        }

        $tujuan->delete();

        return redirect()->back()->with('success', 'Tujuan distribusi dihapus.');
    }
}
