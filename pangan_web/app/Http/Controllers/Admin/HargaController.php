<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class HargaController extends Controller
{
    public function index()
    {
        return view('admin.harga.index');
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

    public function update(Request $request)
    {
        // Update harga configuration
        return redirect()->back()->with('success', 'Harga berhasil diperbarui');
    }

    public function destroy($id)
    {
        //
    }
}