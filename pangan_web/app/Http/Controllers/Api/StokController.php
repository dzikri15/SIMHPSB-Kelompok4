<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Stok;
use Illuminate\Http\Request;

class StokController extends Controller
{
    public function index()
    {
        return Stok::with('gudang')->paginate(15);
    }

    public function show(Stok $stok)
    {
        return $stok->load('gudang');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'gudang_id' => 'required|integer|exists:gudang,id',
            'jumlah_stok' => 'required|numeric|min:0',
            'batas_minimum' => 'required|numeric|min:0',
            'tanggal_update' => 'required|date',
            'catatan' => 'nullable|string',
        ]);

        $stok = Stok::create($data);

        return response()->json($stok, 201);
    }

    public function update(Request $request, Stok $stok)
    {
        $data = $request->validate([
            'gudang_id' => 'sometimes|required|integer|exists:gudang,id',
            'jumlah_stok' => 'sometimes|required|numeric|min:0',
            'batas_minimum' => 'sometimes|required|numeric|min:0',
            'tanggal_update' => 'sometimes|required|date',
            'catatan' => 'nullable|string',
        ]);

        $stok->update($data);

        return response()->json($stok);
    }

    public function destroy(Stok $stok)
    {
        $stok->delete();

        return response()->json(null, 204);
    }

    public function monitoring()
    {
        $stocks = Stok::with('gudang')
            ->get()
            ->map(function ($item) {
                $item->status = $item->jumlah_stok < $item->batas_minimum ? 'low' : 'ok';
                return $item;
            });

        return response()->json($stocks);
    }
}
