<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Api\PetaniController;
use App\Http\Controllers\Api\LahanController;
use App\Http\Controllers\Api\PanenController;
use App\Http\Controllers\Api\StokController;
use App\Http\Controllers\Api\HargaController;
use App\Http\Controllers\Api\AlertController;use App\Http\Controllers\ChatbotController;use App\Http\Controllers\Api\DistribusiController;
use App\Http\Controllers\Api\TujuanDistribusiController;
use App\Http\Controllers\Api\LaporanController;
use App\Http\Controllers\Api\PetaniProfileController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// JWT Auth Routes
Route::prefix('auth')->group(function () {
    Route::post('register',         [AuthController::class, 'register']);
    Route::post('register-petani',  [AuthController::class, 'registerPetani']);
    Route::post('login',            [AuthController::class, 'login']);
    Route::post('logout',           [AuthController::class, 'logout'])->middleware('auth:api');
    Route::get('me',                [AuthController::class, 'me'])->middleware('auth:api');
    Route::post('refresh',          [AuthController::class, 'refresh'])->middleware('auth:api');
});

Route::middleware('auth:api')->group(function () {

    // ── Petani & Lahan ──────────────────────────────────────────────────
    Route::get('petani/export-pdf', [PetaniController::class, 'exportPdf']);
    Route::patch('petani/{id}/toggle-status', [PetaniController::class, 'toggleStatus']);
    Route::apiResource('petani', PetaniController::class);
    Route::apiResource('lahan',  LahanController::class);

    // ── Panen ───────────────────────────────────────────────────────────
    Route::apiResource('panen', PanenController::class);

    // ── Stok (custom routes BEFORE apiResource to avoid /stok/{id} clash)
    Route::get('stok/monitoring',  [StokController::class, 'monitoring']);
    Route::get('stok/summary',     [StokController::class, 'summary']);
    Route::get('stok/current',     [StokController::class, 'current']);
    Route::get('stok/transaksi',   [StokController::class, 'transaksi']);
    Route::post('stok/catat',      [StokController::class, 'catat']);
    Route::patch('stok/{id}/toggle-status', [StokController::class, 'toggleStatus']);
    Route::apiResource('stok', StokController::class);

    // ── Harga (custom route BEFORE apiResource)
    Route::post('harga/calculate', [HargaController::class, 'calculate']);
    Route::get('harga/aktif',      [HargaController::class, 'aktif']);
    Route::apiResource('harga', HargaController::class);

    // ── Alert (custom route BEFORE apiResource)
    Route::get('alert/minimum',        [AlertController::class, 'minimum']);
    Route::get('alert/konfigurasi',    [AlertController::class, 'getKonfigurasi']);
    Route::put('alert/konfigurasi',    [AlertController::class, 'saveKonfigurasi']);
    Route::apiResource('alert', AlertController::class);

    // ── Laporan ─────────────────────────────────────────────────────────
    Route::get('laporan/panen',  [LaporanController::class, 'panen']);
    Route::get('laporan/stok',   [LaporanController::class, 'stok']);
    Route::get('laporan/margin', [LaporanController::class, 'margin']);

    // ── Petani Profile (untuk role 'petani' di Flutter) ───────────────
    Route::prefix('petani-profile')->group(function () {
        Route::get('/',           [PetaniProfileController::class, 'profile']);
        Route::get('/panen',      [PetaniProfileController::class, 'panen']);
        Route::get('/panen/{id}', [PetaniProfileController::class, 'panenDetail']);
        Route::get('/ringkasan',  [PetaniProfileController::class, 'ringkasan']);
    });

    // ── Distribusi (admin & petugas only) ──────────────────────────────
    Route::apiResource('distribusi', DistribusiController::class)
        ->middleware('role:admin,petugas');

    // ── Tujuan Distribusi ──────────────────────────────────────────────
    // GET list - semua yang terauth bisa lihat
    Route::get('tujuan-distribusi', [TujuanDistribusiController::class, 'index']);
    Route::get('tujuan-distribusi/{tujuanDistribusi}', [TujuanDistribusiController::class, 'show']);

    // POST/PUT/DELETE - admin & petugas (allow petugas to manage distribution targets)
    Route::middleware('role:admin,petugas')->group(function () {
        Route::post('tujuan-distribusi', [TujuanDistribusiController::class, 'store']);
        Route::put('tujuan-distribusi/{tujuanDistribusi}', [TujuanDistribusiController::class, 'update']);
        Route::delete('tujuan-distribusi/{tujuanDistribusi}', [TujuanDistribusiController::class, 'destroy']);
    });
});
// ── Public file proxy (CORS-friendly, for Flutter Web preview images) ─────
Route::get('file/{path}', function (string $path) {
    if (! Storage::disk('public')->exists($path)) {
        abort(404);
    }

    $fullPath = Storage::disk('public')->path($path);
    $mime = Storage::disk('public')->mimeType($path) ?: 'application/octet-stream';

    return response()->file($fullPath, [
        'Content-Type' => $mime,
        'Access-Control-Allow-Origin' => '*',
    ]);
})->where('path', '.*');