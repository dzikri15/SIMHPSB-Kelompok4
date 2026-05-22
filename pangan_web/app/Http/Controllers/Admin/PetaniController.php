<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Petani;
use Illuminate\Http\Request;

class PetaniController extends Controller
{
    public function index()
    {
        $petani = Petani::paginate(10);
        return view('admin.petani.index', compact('petani'));
    }

    public function create()
    {
        return view('admin.petani.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:255',
            'nik' => 'nullable|string|max:32',
            'alamat' => 'required|string',
            'telepon' => 'nullable|string|max:50',
            'no_hp' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:255|unique:petani,email',
            'tanggal_lahir' => 'nullable|date',
            'status' => 'required|string|in:aktif,non-aktif,nonaktif',
            'luas_lahan' => 'nullable|integer|min:0',
            'komoditas' => 'required|string|in:Padi,Jagung,Padi & Jagung',
            'catatan' => 'nullable|string',
        ]);

        if ($data['status'] === 'non-aktif') {
            $data['status'] = 'nonaktif';
        }

        Petani::create($data);

        return redirect()->route('admin.petani.index')->with('success', 'Petani berhasil ditambahkan');
    }

    public function show(Petani $petani)
    {
        $petani->load('lahan');
        return view('admin.petani.show', compact('petani'));
    }

    public function edit(Petani $petani)
    {
        return view('admin.petani.edit', compact('petani'));
    }

    public function update(Request $request, Petani $petani)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:255',
            'nik' => 'nullable|string|max:32',
            'alamat' => 'required|string',
            'telepon' => 'nullable|string|max:50',
            'no_hp' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:255|unique:petani,email,' . $petani->id,
            'tanggal_lahir' => 'nullable|date',
            'status' => 'required|string|in:aktif,non-aktif,nonaktif',
            'luas_lahan' => 'nullable|integer|min:0',
            'komoditas' => 'required|string|in:Padi,Jagung,Padi & Jagung',
            'catatan' => 'nullable|string',
        ]);

        if ($data['status'] === 'non-aktif') {
            $data['status'] = 'nonaktif';
        }

        $petani->update($data);

        return redirect()->route('admin.petani.index')->with('success', 'Petani berhasil diperbarui');
    }

    public function destroy(Petani $petani)
    {
        $petani->delete();
        return redirect()->route('admin.petani.index')->with('success', 'Petani berhasil dihapus');
    }

    public function export()
    {
        $petani = Petani::all();
        $csv = "Nama,Alamat,No HP,Email,Tanggal Lahir,Status\n";
        
        foreach ($petani as $p) {
            $csv .= "\"{$p->nama}\",\"{$p->alamat}\",\"{$p->no_hp}\",\"{$p->email}\",\"{$p->tanggal_lahir}\",\"{$p->status}\"\n";
        }

        return response($csv)
            ->header('Content-Type', 'text/csv')
            ->header('Content-Disposition', 'attachment; filename=petani.csv');
    }
}