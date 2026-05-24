<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use App\Models\AlertConfiguration;
use App\Models\Stok;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class StokController extends Controller
{
    public function index()
    {
        $dateColumn = Schema::hasColumn('stok_beras', 'tanggal_update')
            ? 'tanggal_update'
            : (Schema::hasColumn('stok_beras', 'tanggal') ? 'tanggal' : 'created_at');

        $transactions = Stok::with('user')
            ->whereNotNull('jenis_transaksi')
            ->orderByDesc($dateColumn)
            ->get();

        $currentMonth = now()->month;
        $currentYear = now()->year;

        $stokBeras = $this->getCurrentStock('Beras');
        $stokGabah = $this->getCurrentStock('Gabah');

        $masukBerasBulanIni = Stok::where('komoditas', 'Beras')
            ->where('jenis_transaksi', 'masuk')
            ->whereYear($dateColumn, $currentYear)
            ->whereMonth($dateColumn, $currentMonth)
            ->sum('jumlah');

        $masukGabahBulanIni = Stok::where('komoditas', 'Gabah')
            ->where('jenis_transaksi', 'masuk')
            ->whereYear($dateColumn, $currentYear)
            ->whereMonth($dateColumn, $currentMonth)
            ->sum('jumlah');

        $keluarBerasBulanIni = Stok::where('komoditas', 'Beras')
            ->where('jenis_transaksi', 'keluar')
            ->whereYear($dateColumn, $currentYear)
            ->whereMonth($dateColumn, $currentMonth)
            ->sum('jumlah');

        $keluarGabahBulanIni = Stok::where('komoditas', 'Gabah')
            ->where('jenis_transaksi', 'keluar')
            ->whereYear($dateColumn, $currentYear)
            ->whereMonth($dateColumn, $currentMonth)
            ->sum('jumlah');

        return view('admin.stok.index', [
            'transaksis' => $transactions,
            'stokBeras' => max(0, $stokBeras),
            'stokGabah' => max(0, $stokGabah),
            'masukBerasBulanIni' => $masukBerasBulanIni,
            'keluarBerasBulanIni' => $keluarBerasBulanIni,
            'masukGabahBulanIni' => $masukGabahBulanIni,
            'keluarGabahBulanIni' => $keluarGabahBulanIni,
        ]);
    }

    private function getCurrentStock(string $komoditas): float
    {
        $dateColumn = Schema::hasColumn('stok_beras', 'tanggal_update')
            ? 'tanggal_update'
            : (Schema::hasColumn('stok_beras', 'tanggal') ? 'tanggal' : 'created_at');

        $query = Stok::where('komoditas', $komoditas);

        if ($dateColumn) {
            $query->orderByDesc($dateColumn);
        }

        return (float) ($query->value('jumlah_stok') ?: 0);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'jenis' => 'required|in:masuk,keluar',
            'komoditas' => 'required|string',
            'jumlah' => 'required|numeric|min:0',
            // allow nullable so we can auto-fill with current datetime when empty
            'tanggal' => 'nullable|date',
            'tujuan_distribusi' => 'nullable|string',
            'keterangan' => 'nullable|string',
            'catatan' => 'nullable|string',
        ]);

        // Normalize datetime-local (2026-05-21T05:40) → 'Y-m-d H:i:s'
        if (! empty($data['tanggal'])) {
            $tanggal = str_replace('T', ' ', $data['tanggal']);
            // append seconds if missing
            if (preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/', $tanggal)) {
                $tanggal .= ':00';
            }
        } else {
            // auto-fill current datetime when user didn't provide one
            $tanggal = now()->format('Y-m-d H:i:s');
        }

        // Calculate running stock after this transaction so jumlah_stok is always present.
        $previousStockQuery = Stok::where('gudang_id', 1)
            ->where('komoditas', $data['komoditas']);

        if (Schema::hasColumn('stok_beras', 'tanggal_update')) {
            $previousStockQuery->orderByDesc('tanggal_update');
        } elseif (Schema::hasColumn('stok_beras', 'tanggal')) {
            $previousStockQuery->orderByDesc('tanggal');
        } else {
            $previousStockQuery->orderByDesc('created_at');
        }

        $previousStock = $previousStockQuery->value('jumlah_stok') ?? 0;
        $jumlahStok = $data['jenis'] === 'keluar'
            ? ($previousStock - $data['jumlah'])
            : ($previousStock + $data['jumlah']);

        // Build payload with safe defaults
        $payload = [
            'gudang_id' => 1,
            'jenis_transaksi' => $data['jenis'],
            'komoditas' => $data['komoditas'],
            'jumlah' => $data['jumlah'],
            'jumlah_stok' => $jumlahStok,
            'keterangan' => trim(($data['tujuan_distribusi'] ?? '') . ' ' . ($data['keterangan'] ?? '')) ?: null,
            'catatan' => $data['catatan'] ?? null,
            'created_at' => now(),
            'updated_at' => now(),
        ];

        if (Schema::hasColumn('stok_beras', 'user_id')) {
            $payload['user_id'] = Auth::id();
        }

        // Store datetime to whichever column exists in this install
        if (Schema::hasColumn('stok_beras', 'tanggal_update')) {
            $payload['tanggal_update'] = $tanggal;
        } elseif (Schema::hasColumn('stok_beras', 'tanggal')) {
            $payload['tanggal'] = $tanggal;
        }

        DB::table('stok_beras')->insert($payload);

        if ($data['jenis'] === 'keluar') {
            $config = Schema::hasTable('alert_configurations') ? AlertConfiguration::first() : null;
            $batasMinimum = $data['komoditas'] === 'Beras'
                ? ($config?->batas_min_beras ?? 400)
                : ($config?->batas_min_gabah ?? 1000);

            AlertController::checkAndCreateAlert($data['komoditas'], $jumlahStok, $batasMinimum);
        }

        return redirect()->back()->with('success', 'Transaksi stok tersimpan.');
    }

    public function show(int $id)
    {
        $stok = Stok::with('user')->findOrFail($id);

        return view('admin.stok.show', [
            'stok' => $stok,
        ]);
    }
}