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
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// JWT Auth Routes
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:api');
    Route::get('me', [AuthController::class, 'me'])->middleware('auth:api');
});

Route::middleware('auth:api')->group(function () {
    Route::apiResource('petani', PetaniController::class);
    Route::apiResource('lahan', LahanController::class);
    Route::apiResource('panen', PanenController::class);
    Route::apiResource('stok', StokController::class);
    Route::apiResource('harga', HargaController::class);
    Route::get('alert/minimum', [AlertController::class, 'minimum']);
    Route::apiResource('alert', AlertController::class);
    Route::apiResource('distribusi', DistribusiController::class)->middleware('role:admin,petugas');

    Route::get('stok/monitoring', [StokController::class, 'monitoring']);
    Route::post('harga/calculate', [HargaController::class, 'calculate']);
});