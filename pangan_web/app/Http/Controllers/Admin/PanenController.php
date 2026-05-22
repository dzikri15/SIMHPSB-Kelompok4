<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Panen;
use App\Models\Petani;
use Illuminate\Http\Request;

class PanenController extends Controller
{
    public function index()
    {
        $petanis = Petani::orderBy('nama')->get();
        $panenList = Panen::with('lahan.petani')
            ->orderByDesc('tanggal_panen')
            ->limit(10)
            ->get();

        return view('admin.panen.index', compact('petanis', 'panenList'));
    }

    public function create()
    {
        //
    }

    public function store(Request $request)
    {
        //
    }

    public function show($id)
    {
        //
    }

    public function edit($id)
    {
        //
    }

    public function update(Request $request, $id)
    {
        //
    }

    public function destroy($id)
    {
        //
    }
}