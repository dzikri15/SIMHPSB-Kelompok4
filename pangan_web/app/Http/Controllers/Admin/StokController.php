<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class StokController extends Controller
{
    public function index()
    {
        return view('admin.stok.index');
    }

    public function store(Request $request)
    {
        //
    }

    public function show($id)
    {
        //
    }
}