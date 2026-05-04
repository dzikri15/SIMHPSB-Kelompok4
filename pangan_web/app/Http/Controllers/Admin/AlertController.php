<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AlertController extends Controller
{
    public function index()
    {
        return view('admin.alert.index');
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

    public function konfigurasi(Request $request)
    {
        // Save alert configuration
        return redirect()->back()->with('success', 'Konfigurasi alert berhasil disimpan');
    }

    public function tangani(Request $request, $id)
    {
        // Mark alert as handled
        return redirect()->back()->with('success', 'Alert sudah ditandai sebagai ditangani');
    }
}