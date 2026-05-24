<?php

// ============================================================
//  routes/web.php  –  SIMHPSB Admin Routes
// ============================================================

use Illuminate\Support\Facades\Route;use Illuminate\Support\Facades\Auth;use App\Http\Controllers\Admin\{
    DashboardController,
    PetaniController,
    PanenController,
    StokController,
    HargaController,
    AlertController,
    LaporanController,
    PenggunaController,
    PengaturanController,
};
use App\Http\Controllers\PetaniDashboardController;

Route::get('/', function () {
    if (!Auth::check()) {
        return redirect()->route('login');
    }

    return Auth::user()->role === 'petani'
        ? redirect()->route('petani.dashboard')
        : redirect()->route('admin.dashboard');
});

Route::middleware(['auth', 'role:petani'])->prefix('petani')->name('petani.')->group(function () {
    Route::get('/', [PetaniDashboardController::class, 'index'])->name('dashboard');
});
// AUTH
Route::middleware('guest')->group(function () {
    Route::get('/login',  [\App\Http\Controllers\Auth\LoginController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [\App\Http\Controllers\Auth\LoginController::class, 'login']);
    Route::get('/password/reset', fn() => view('auth.passwords.email'))->name('password.request');
});

Route::post('/logout', [\App\Http\Controllers\Auth\LoginController::class, 'logout'])->name('logout');

// ADMIN PANEL  (auth + role:admin)
Route::prefix('admin')->name('admin.')->middleware(['auth', 'role:admin,petugas'])->group(function () {

    // Dashboard
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

    // Petani
    Route::get('petani/export', [PetaniController::class, 'export'])->name('petani.export');
    Route::resource('petani', PetaniController::class);

    // Panen
    Route::resource('panen', PanenController::class)->names('panen');

    // Stok Gudang
    Route::get ('stok',       [StokController::class, 'index'])->name('stok.index');
    Route::post('stok',       [StokController::class, 'store'])->name('stok.store');
    Route::get ('stok/{id}',  [StokController::class, 'show'])->name('stok.show');

    // Alert, Laporan, Manajemen Harga, Pengguna, dan Pengaturan hanya untuk admin
    Route::middleware('role:admin')->group(function () {
        // Manajemen Harga
        Route::get('harga', [HargaController::class, 'index'])->name('harga.index');
        Route::get('harga/create', [HargaController::class, 'create'])->name('harga.create');
        Route::post('harga', [HargaController::class, 'store'])->name('harga.store');
        Route::get('harga/{harga}/edit', [HargaController::class, 'edit'])->name('harga.edit');
        Route::put('harga/{harga}', [HargaController::class, 'update'])->name('harga.update');
        Route::delete('harga/{harga}', [HargaController::class, 'destroy'])->name('harga.destroy');
        Route::patch('harga/{harga}/rasio', [HargaController::class, 'updateRasio'])->name('harga.updateRasio');
        Route::patch('harga/{harga}/activate', [HargaController::class, 'activate'])->name('harga.activate');

        // Alert
        Route::get  ('alert',                    [AlertController::class, 'index'])    ->name('alert.index');
        Route::put  ('alert/konfigurasi',        [AlertController::class, 'konfigurasi'])->name('alert.konfigurasi');
        Route::patch('alert/{alert}/tangani',    [AlertController::class, 'tangani'])  ->name('alert.tangani');

        // Laporan
        Route::get('laporan',        [LaporanController::class, 'index']) ->name('laporan.index');
        Route::get('laporan/export', [LaporanController::class, 'export'])->name('laporan.export');

        // Pengguna
        Route::resource('pengguna', PenggunaController::class)->names('pengguna');

        // Pengaturan
        Route::get('pengaturan', [PengaturanController::class, 'index'])->name('pengaturan');
        Route::put('pengaturan', [PengaturanController::class, 'update'])->name('pengaturan.update');
    });
});
