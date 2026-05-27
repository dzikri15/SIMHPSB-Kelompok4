<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use Illuminate\Http\Request;

class AlertController extends Controller
{
    public function index()
    {
        return Alert::with('handler')->paginate(15);
    }

    public function show(Alert $alert)
    {
        return $alert->load('handler');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'komoditas' => 'required|string|max:255',
            'stok_saat_ini' => 'required|numeric|min:0',
            'batas_minimum' => 'required|numeric|min:0',
            'status' => 'nullable|in:aktif,proses,selesai',
            'ditangani_oleh' => 'nullable|integer|exists:users,id',
        ]);

        $alert = Alert::create($data);

        return response()->json($alert, 201);
    }

    public function update(Request $request, Alert $alert)
    {
        $data = $request->validate([
            'komoditas' => 'sometimes|required|string|max:255',
            'stok_saat_ini' => 'sometimes|required|numeric|min:0',
            'batas_minimum' => 'sometimes|required|numeric|min:0',
            'status' => 'nullable|in:aktif,proses,selesai',
            'ditangani_oleh' => 'nullable|integer|exists:users,id',
        ]);

        $alert->update($data);

        return response()->json($alert);
    }

    public function destroy(Alert $alert)
    {
        $alert->delete();

        return response()->json(null, 204);
    }

    public function minimum()
    {
        $alerts = Alert::with('handler')
            ->whereColumn('stok_saat_ini', '<', 'batas_minimum')
            ->orWhere('status', 'aktif')
            ->paginate(15);

        return $alerts;
    }
}
