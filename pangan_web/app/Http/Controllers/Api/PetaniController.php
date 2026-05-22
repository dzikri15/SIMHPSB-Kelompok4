<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Petani;
use Illuminate\Http\Request;

class PetaniController extends Controller
{
    public function index()
    {
        return Petani::with('lahan')->paginate(15);
    }

    public function show(Petani $petani)
    {
        return $petani->load('lahan');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:255',
            'alamat' => 'required|string',
            'no_hp' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:255|unique:petani,email',
            'tanggal_lahir' => 'nullable|date',
            'status' => 'nullable|in:aktif,nonaktif',
        ]);

        $petani = Petani::create($data);

        return response()->json($petani, 201);
    }

    public function update(Request $request, Petani $petani)
    {
        $data = $request->validate([
            'nama' => 'sometimes|required|string|max:255',
            'alamat' => 'sometimes|required|string',
            'no_hp' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:255|unique:petani,email,' . $petani->id,
            'tanggal_lahir' => 'nullable|date',
            'status' => 'nullable|in:aktif,nonaktif',
        ]);

        $petani->update($data);

        return response()->json($petani);
    }

    public function destroy(Petani $petani)
    {
        $petani->delete();

        return response()->json(null, 204);
    }
}
