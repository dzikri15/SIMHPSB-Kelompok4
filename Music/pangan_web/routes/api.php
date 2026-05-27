<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Api\PetaniController;
use App\Http\Controllers\Api\LahanController;
use App\Http\Controllers\Api\PanenController;
use App\Http\Controllers\Api\StokController;
use App\Http\Controllers\Api\HargaController;
use App\Http\Controllers\Api\AlertController;
use App\Http\Controllers\Api\DistribusiController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// JWT Auth Routes
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login',    [AuthController::class, 'login']);
    Route::post('logout',   [AuthController::class, 'logout'])->middleware('auth:api');
    Route::get('me',        [AuthController::class, 'me'])->middleware('auth:api');
    Route::post('refresh',  [AuthController::class, 'refresh'])->middleware('auth:api');
});

Route::middleware('auth:api')->group(function () {

    // ── Petani & Lahan ──────────────────────────────────────────────────
    Route::apiResource('petani', PetaniController::class);
    Route::apiResource('lahan',  LahanController::class);

    // ── Panen ───────────────────────────────────────────────────────────
    Route::apiResource('panen', PanenController::class);

    // ── Stok (custom routes BEFORE apiResource to avoid clash) ──────────
    Route::get('stok/summary',    [StokController::class, 'summary']);       // ringkasan statistik
    Route::get('stok/monitoring', [StokController::class, 'monitoring']);    // status per gudang
    Route::get('stok/transaksi',  [StokController::class, 'transaksiList']); // daftar mutasi
    Route::post('stok/catat',     [StokController::class, 'catatTransaksi']); // catat transaksi baru
    Route::apiResource('stok', StokController::class);

    // ── Harga (custom route BEFORE apiResource) ──────────────────────────
    Route::post('harga/calculate', [HargaController::class, 'calculate']);
    Route::apiResource('harga', HargaController::class);

    // ── Alert (custom route BEFORE apiResource) ──────────────────────────
    Route::get('alert/minimum', [AlertController::class, 'minimum']);
    Route::apiResource('alert', AlertController::class);

    // ── Distribusi (admin & petugas only) ───────────────────────────────
    Route::apiResource('distribusi', DistribusiController::class)
        ->middleware('role:admin,petugas');
});
