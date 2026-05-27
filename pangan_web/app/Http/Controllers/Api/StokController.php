<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Admin\AlertController;
use App\Models\Gudang;
use App\Models\Stok;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class StokController extends Controller
{
    public function index()
    {
        return Stok::with('gudang')->paginate(15);
    }

    public function show(Stok $stok)
    {
        return $stok->load('gudang');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'gudang_id'      => 'required|integer|exists:gudang,id',
            'jumlah_stok'    => 'required|numeric|min:0',
            'batas_minimum'  => 'required|numeric|min:0',
            'tanggal_update' => 'required|date',
            'catatan'        => 'nullable|string',
        ]);

        $stok = Stok::create($data);

        if (! empty($stok->komoditas)) {
            $config       = \Illuminate\Support\Facades\Schema::hasTable('alert_configurations')
                ? \App\Models\AlertConfiguration::first()
                : null;
            $batasMinimum = $stok->komoditas === 'Beras'
                ? ($config?->batas_min_beras ?? 400)
                : ($config?->batas_min_gabah ?? 1000);

            AlertController::checkAndCreateAlert($stok->komoditas, (float) $stok->jumlah_stok, (int) $batasMinimum);
        }

        return response()->json($stok, 201);
    }

    public function update(Request $request, Stok $stok)
    {
        $data = $request->validate([
            'gudang_id'      => 'sometimes|required|integer|exists:gudang,id',
            'jumlah_stok'    => 'sometimes|required|numeric|min:0',
            'batas_minimum'  => 'sometimes|required|numeric|min:0',
            'tanggal_update' => 'sometimes|required|date',
            'catatan'        => 'nullable|string',
        ]);

        $stok->update($data);

        if (! empty($stok->komoditas) && isset($stok->jumlah_stok)) {
            $config       = \Illuminate\Support\Facades\Schema::hasTable('alert_configurations')
                ? \App\Models\AlertConfiguration::first()
                : null;
            $batasMinimum = $stok->komoditas === 'Beras'
                ? ($config?->batas_min_beras ?? 400)
                : ($config?->batas_min_gabah ?? 1000);

            AlertController::checkAndCreateAlert($stok->komoditas, (float) $stok->jumlah_stok, (int) $batasMinimum);
        }

        return response()->json($stok);
    }

    public function destroy(Stok $stok)
    {
        $stok->delete();

        return response()->json(null, 204);
    }

    public function monitoring()
    {
        // Ambil hanya 1 baris terbaru per gudang (saldo terkini)
        $latestIds = Stok::selectRaw('MAX(id) as id')
            ->groupBy('gudang_id')
            ->pluck('id');

        $stocks = Stok::with('gudang')
            ->whereIn('id', $latestIds)
            ->where('jumlah_stok', '>=', 0)          // abaikan nilai negatif (data rusak)
            ->get()
            ->map(function ($item) {
                $item->status = $item->jumlah_stok < $item->batas_minimum ? 'low' : 'ok';
                return $item;
            });

        return response()->json($stocks);
    }

    // ──────────────────────────────────────────────────────────────────────
    // GET /api/stok/summary
    // Ringkasan statistik: saldo per komoditas, masuk/keluar bulan ini
    // ──────────────────────────────────────────────────────────────────────
    public function summary()
    {
        $now        = now();
        $bulanIni   = $now->month;
        $tahunIni   = $now->year;

        // Saldo terkini per komoditas = jumlah_stok dari baris terakhir per komoditas
        $saldoBeras = (float) Stok::where('komoditas', 'Beras')
            ->latest('tanggal_update')
            ->value('jumlah_stok') ?? 0;

        $saldoGabah = (float) Stok::where('komoditas', 'Gabah')
            ->latest('tanggal_update')
            ->value('jumlah_stok') ?? 0;

        // Kapasitas gudang (sum dari semua gudang aktif)
        $kapasitasTotal = (float) Gudang::where('status', 'aktif')->sum('kapasitas');
        // Bagi rata 50-50 jika tidak ada pemisahan per komoditas
        $kapasitasBeras = $kapasitasTotal / 2;
        $kapasitasGabah = $kapasitasTotal / 2;

        // Transaksi bulan ini
        $transaksiBase = Stok::whereMonth('tanggal_update', $bulanIni)
            ->whereYear('tanggal_update', $tahunIni)
            ->whereNotNull('jenis_transaksi');

        $masukBulanIni = (float) (clone $transaksiBase)
            ->where('jenis_transaksi', 'masuk')
            ->sum('jumlah');

        $keluarBulanIni = (float) (clone $transaksiBase)
            ->where('jenis_transaksi', 'keluar')
            ->sum('jumlah');

        $masukBerasBulanIni = (float) (clone $transaksiBase)
            ->where('jenis_transaksi', 'masuk')
            ->where('komoditas', 'Beras')
            ->sum('jumlah');

        $masukGabahBulanIni = (float) (clone $transaksiBase)
            ->where('jenis_transaksi', 'masuk')
            ->where('komoditas', 'Gabah')
            ->sum('jumlah');

        $keluarBerasBulanIni = (float) (clone $transaksiBase)
            ->where('jenis_transaksi', 'keluar')
            ->where('komoditas', 'Beras')
            ->sum('jumlah');

        $keluarGabahBulanIni = (float) (clone $transaksiBase)
            ->where('jenis_transaksi', 'keluar')
            ->where('komoditas', 'Gabah')
            ->sum('jumlah');

        return response()->json([
            'saldo_beras'            => $saldoBeras,
            'saldo_gabah'            => $saldoGabah,
            'kapasitas_beras'        => $kapasitasBeras ?: 1000,
            'kapasitas_gabah'        => $kapasitasGabah ?: 2000,
            'masuk_bulan_ini'        => $masukBulanIni,
            'keluar_bulan_ini'       => $keluarBulanIni,
            'masuk_beras_bulan_ini'  => $masukBerasBulanIni,
            'masuk_gabah_bulan_ini'  => $masukGabahBulanIni,
            'keluar_beras_bulan_ini' => $keluarBerasBulanIni,
            'keluar_gabah_bulan_ini' => $keluarGabahBulanIni,
            'bulan'                  => $now->translatedFormat('F Y'),
        ]);
    }

    // ──────────────────────────────────────────────────────────────────────
    // GET /api/stok/transaksi
    // Daftar mutasi dengan filter: jenis, komoditas, q (search), tanggal
    // ──────────────────────────────────────────────────────────────────────
    public function transaksi(Request $request)
    {
        $query = Stok::with(['gudang', 'user'])
            ->whereNotNull('jenis_transaksi')
            ->latest('tanggal_update');

        if ($request->filled('jenis')) {
            $query->where('jenis_transaksi', strtolower($request->jenis));
        }

        if ($request->filled('komoditas')) {
            $query->where('komoditas', $request->komoditas);
        }

        if ($request->filled('tanggal')) {
            $query->whereDate('tanggal_update', $request->tanggal);
        }

        if ($request->filled('q')) {
            $q = $request->q;
            $query->where(function ($sub) use ($q) {
                $sub->where('komoditas', 'like', "%{$q}%")
                    ->orWhere('keterangan', 'like', "%{$q}%")
                    ->orWhere('catatan', 'like', "%{$q}%")
                    ->orWhereHas('gudang', function ($g) use ($q) {
                        $g->where('nama_gudang', 'like', "%{$q}%")
                          ->orWhere('lokasi', 'like', "%{$q}%");
                    });
            });
        }

        $paginated = $query->paginate(20);

        // Tambahkan field tambahan per item
        $paginated->getCollection()->transform(function ($item) {
            $item->dicatat_oleh  = $item->user?->name ?? 'Admin';
            $item->tanggal_label = $item->tanggal_update
                ? \Carbon\Carbon::parse($item->tanggal_update)->format('Y-m-d H:i')
                : null;
            return $item;
        });

        return response()->json($paginated);
    }

    // ──────────────────────────────────────────────────────────────────────
    // POST /api/stok/catat
    // Catat transaksi masuk/keluar dan hitung saldo berjalan
    // ──────────────────────────────────────────────────────────────────────
    public function catat(Request $request)
    {
        $data = $request->validate([
            'jenis_transaksi'   => 'required|in:masuk,keluar',
            'komoditas'         => 'required|string',
            'jumlah'            => 'required|numeric|min:0.01',
            'gudang_id'         => 'nullable|integer|exists:gudang,id',
            'keterangan'        => 'nullable|string|max:500',
            'catatan'           => 'nullable|string|max:1000',
            'tanggal'           => 'nullable|date',
        ]);

        // Tentukan gudang (pakai pertama jika tidak dikirim)
        $gudangId = $data['gudang_id'] ?? Gudang::first()?->id;
        if (! $gudangId) {
            return response()->json(['message' => 'Tidak ada gudang tersedia.'], 422);
        }

        // Hitung saldo terkini untuk komoditas ini
        $saldoSekarang = (float) Stok::where('komoditas', $data['komoditas'])
            ->latest('tanggal_update')
            ->value('jumlah_stok') ?? 0;

        $jumlah = (float) $data['jumlah'];
        $saldoBaru = $data['jenis_transaksi'] === 'masuk'
            ? $saldoSekarang + $jumlah
            : $saldoSekarang - $jumlah;

        // Ambil batas minimum dari entri sebelumnya
        $batasMin = (float) Stok::where('komoditas', $data['komoditas'])
            ->latest('tanggal_update')
            ->value('batas_minimum') ?? 500;

        $tanggal = isset($data['tanggal'])
            ? \Carbon\Carbon::parse($data['tanggal'])
            : now();

        $stok = Stok::create([
            'gudang_id'       => $gudangId,
            'jenis_transaksi' => $data['jenis_transaksi'],
            'komoditas'       => $data['komoditas'],
            'jumlah'          => $jumlah,
            'keterangan'      => $data['keterangan'] ?? null,
            'catatan'         => $data['catatan'] ?? null,
            'user_id'         => Auth::id(),
            'jumlah_stok'     => $saldoBaru,
            'batas_minimum'   => $batasMin,
            'tanggal_update'  => $tanggal,
        ]);

        // Cek dan buat alert otomatis jika stok rendah
        $config       = \Illuminate\Support\Facades\Schema::hasTable('alert_configurations')
            ? \App\Models\AlertConfiguration::first()
            : null;
        $batasMinimum = $data['komoditas'] === 'Beras'
            ? ($config?->batas_min_beras ?? 400)
            : ($config?->batas_min_gabah ?? 1000);

        AlertController::checkAndCreateAlert(
            $data['komoditas'],
            $saldoBaru,
            (int) $batasMinimum
        );

        $stok->load(['gudang', 'user']);
        $stok->dicatat_oleh  = $stok->user?->name ?? 'Admin';
        $stok->tanggal_label = $tanggal->format('Y-m-d H:i');

        return response()->json($stok, 201);
    }
}
