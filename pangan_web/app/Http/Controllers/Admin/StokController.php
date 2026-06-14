<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use App\Models\AlertConfiguration;
use App\Models\Stok;
use App\Models\TujuanDistribusi;
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
            // show all transactions in list (including dibatalkan) but ensure stock calculations below use only 'aktif'
            ->orderByDesc($dateColumn)
            ->get();

        $currentMonth = now()->month;
        $currentYear = now()->year;

        $stokBeras = $this->getCurrentStock('Beras');
        $stokGabah = $this->getCurrentStock('Gabah');

        $masukBerasBulanIni = Stok::where('komoditas', 'Beras')
            ->where('status', 'aktif')
            ->where('jenis_transaksi', 'masuk')
            ->whereYear($dateColumn, $currentYear)
            ->whereMonth($dateColumn, $currentMonth)
            ->sum('jumlah');

        $masukGabahBulanIni = Stok::where('komoditas', 'Gabah')
            ->where('status', 'aktif')
            ->where('jenis_transaksi', 'masuk')
            ->whereYear($dateColumn, $currentYear)
            ->whereMonth($dateColumn, $currentMonth)
            ->sum('jumlah');

        $keluarBerasBulanIni = Stok::where('komoditas', 'Beras')
            ->where('status', 'aktif')
            ->where('jenis_transaksi', 'keluar')
            ->whereYear($dateColumn, $currentYear)
            ->whereMonth($dateColumn, $currentMonth)
            ->sum('jumlah');

        $keluarGabahBulanIni = Stok::where('komoditas', 'Gabah')
            ->where('status', 'aktif')
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
            'tujuans' => TujuanDistribusi::orderBy('nama')->get(),
        ]);
    }

    private function getCurrentStock(string $komoditas): float
    {
        $dateColumn = Schema::hasColumn('stok_beras', 'tanggal_update')
            ? 'tanggal_update'
            : (Schema::hasColumn('stok_beras', 'tanggal') ? 'tanggal' : 'created_at');

        $query = Stok::where('komoditas', $komoditas)
            ->where('status', 'aktif');

        if ($dateColumn) {
            $query->orderByDesc($dateColumn);
        }
        $query->orderByDesc('id');

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
            'foto_bukti' => 'required_if:jenis,keluar|image|mimes:jpeg,jpg,png,webp|max:2048',
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
            ->where('komoditas', $data['komoditas'])
            ->where('status', 'aktif');

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

        // Handle uploaded foto bukti for distribusi (keluar)
        if ($request->hasFile('foto_bukti')) {
            $file = $request->file('foto_bukti');
            $ext = $file->getClientOriginalExtension();
            $filename = time() . '_' . bin2hex(random_bytes(6)) . '.' . $ext;
            // store in storage/app/public/bukti-distribusi
$path = $file->storeAs('bukti-distribusi', $filename, 'public');            // save relative path without 'public/' prefix so asset('storage/...') works
            $payload['foto_bukti'] = 'bukti-distribusi/' . $filename;
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

    /**
     * Toggle status antara 'aktif' dan 'dibatalkan' untuk sebuah transaksi stok.
     * Recalculate saldo setelah update.
     */
    public function toggleStatus(int $id)
    {
        $stok = Stok::findOrFail($id);

        $stok->status = ($stok->status === 'aktif') ? 'dibatalkan' : 'aktif';
        $stok->save();

        // Recalculate saldo for this komoditas
        $this->recalculateSaldo($stok->komoditas);

        // also include updated summary so other pages can update without reload
        $stokBeras = $this->getCurrentStock('Beras');
        $stokGabah = $this->getCurrentStock('Gabah');

        return response()->json([
            'success' => true,
            'status' => $stok->status,
            'message' => 'Status transaksi diperbarui',
            'summary' => [
                'stokBeras' => max(0, $stokBeras),
                'stokGabah' => max(0, $stokGabah),
            ],
        ]);
    }

    /**
     * Return a small JSON summary of current stocks for dashboard updates.
     */
    public function summary()
    {
        $stokBeras = $this->getCurrentStock('Beras');
        $stokGabah = $this->getCurrentStock('Gabah');

        return response()->json([
            'stokBeras' => max(0, $stokBeras),
            'stokGabah' => max(0, $stokGabah),
        ]);
    }

    /**
     * Recalculate saldo_setelah untuk semua transaksi aktif dari komoditas tertentu.
     */
    public function recalculateSaldo(string $komoditas)
    {
        $saldo = 0;
        $transaksi = Stok::where('komoditas', $komoditas)
            ->where('status', 'aktif')
            ->orderBy('tanggal_update')
            ->orderBy('id')
            ->get();

        foreach ($transaksi as $t) {
            $saldo += $t->jenis_transaksi === 'masuk' ? $t->jumlah : -$t->jumlah;
            $t->jumlah_stok = $saldo;
            if (Schema::hasColumn('stok_beras', 'saldo_setelah')) {
                $t->saldo_setelah = $saldo;
            }
            $t->save();
        }
    }

    public function show(int $id)
    {
        $stok = Stok::with('user')->findOrFail($id);

        return view('admin.stok.show', [
            'stok' => $stok,
        ]);
    }
}