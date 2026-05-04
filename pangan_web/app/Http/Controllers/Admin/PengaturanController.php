<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PengaturanController extends Controller
{
    public function index()
    {
        return view('admin.pengaturan.index');
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
        // Handle settings update
        return redirect()->back()->with('success', 'Pengaturan berhasil disimpan');
    }

    public function destroy($id)
    {
        //
    }
}