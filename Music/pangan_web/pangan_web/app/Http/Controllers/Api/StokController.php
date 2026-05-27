<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Admin\AlertController;
use App\Models\AlertConfiguration;
use App\Models\Stok;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class StokController extends Controller
{
    // ─────────────────────────────────────────────────────────
    // Helper: deteksi nama kolom tanggal yang dipakai
    // ─────────────────────────────────────────────────────────
    private function dateColumn(): string
    {
        if (Schema::hasColumn('stok_beras', 'tanggal_update')) return 'tanggal_update';
        if (Schema::hasColumn('stok_beras', 'tanggal'))        return 'tanggal';
        return 'created_at';
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/stok
    // Kembalikan semua stok (dengan relasi gudang), paginasi 15
    // ─────────────────────────────────────────────────────────
    public function index()
    {
        return Stok::with('gudang')->paginate(15);
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/stok/{id}
    // ─────────────────────────────────────────────────────────
    public function show(Stok $stok)
    {
        return $stok->load('gudang');
    }

    // ─────────────────────────────────────────────────────────
    // POST /api/stok
    // Buat record stok monitoring (batas minimum, kapasitas, dsb.)
    // ─────────────────────────────────────────────────────────
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
            $config       = Schema::hasTable('alert_configurations') ? AlertConfiguration::first() : null;
            $batasMinimum = $stok->komoditas === 'Beras'
                ? ($config?->batas_min_beras ?? 400)
                : ($config?->batas_min_gabah ?? 1000);
            AlertController::checkAndCreateAlert($stok->komoditas, (float) $stok->jumlah_stok, (int) $batasMinimum);
        }

        return response()->json($stok, 201);
    }

    // ─────────────────────────────────────────────────────────
    // PUT/PATCH /api/stok/{id}
    // ─────────────────────────────────────────────────────────
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
            $config       = Schema::hasTable('alert_configurations') ? AlertConfiguration::first() : null;
            $batasMinimum = $stok->komoditas === 'Beras'
                ? ($config?->batas_min_beras ?? 400)
                : ($config?->batas_min_gabah ?? 1000);
            AlertController::checkAndCreateAlert($stok->komoditas, (float) $stok->jumlah_stok, (int) $batasMinimum);
        }

        return response()->json($stok);
    }

    // ─────────────────────────────────────────────────────────
    // DELETE /api/stok/{id}
    // ─────────────────────────────────────────────────────────
    public function destroy(Stok $stok)
    {
        $stok->delete();
        return response()->json(null, 204);
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/stok/monitoring
    // Status stok per gudang (rendah / aman)
    // ─────────────────────────────────────────────────────────
    public function monitoring()
    {
        $stocks = Stok::with('gudang')
            ->get()
            ->map(function ($item) {
                $item->status = $item->jumlah_stok < $item->batas_minimum ? 'low' : 'ok';
                return $item;
            });

        return response()->json($stocks);
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/stok/summary
    // Ringkasan: saldo per komoditas + statistik bulan ini
    // ─────────────────────────────────────────────────────────
    public function summary()
    {
        $dc    = $this->dateColumn();
        $month = now()->month;
        $year  = now()->year;

        // Saldo terkini = jumlah_stok dari record transaksi terakhir per komoditas
        $saldoBeras = (float) (Stok::where('komoditas', 'Beras')
            ->orderByDesc($dc)->value('jumlah_stok') ?? 0);
        $saldoGabah = (float) (Stok::where('komoditas', 'Gabah')
            ->orderByDesc($dc)->value('jumlah_stok') ?? 0);

        // Masuk bulan ini
        $masukBeras = (float) Stok::where('komoditas', 'Beras')
            ->where('jenis_transaksi', 'masuk')
            ->whereYear($dc, $year)->whereMonth($dc, $month)
            ->sum('jumlah');
        $masukGabah = (float) Stok::where('komoditas', 'Gabah')
            ->where('jenis_transaksi', 'masuk')
            ->whereYear($dc, $year)->whereMonth($dc, $month)
            ->sum('jumlah');

        // Keluar bulan ini
        $keluarBeras = (float) Stok::where('komoditas', 'Beras')
            ->where('jenis_transaksi', 'keluar')
            ->whereYear($dc, $year)->whereMonth($dc, $month)
            ->sum('jumlah');
        $keluarGabah = (float) Stok::where('komoditas', 'Gabah')
            ->where('jenis_transaksi', 'keluar')
            ->whereYear($dc, $year)->whereMonth($dc, $month)
            ->sum('jumlah');

        // Kapasitas gudang (untuk bar progress) — ambil dari tabel gudang
        $kapasitasBeras = (float) DB::table('gudang')->where('id', 1)->value('kapasitas') ?? 1000;
        $kapasitasGabah = (float) DB::table('gudang')->where('id', 2)->value('kapasitas') ?? 2000;

        return response()->json([
            'saldo_beras'           => $saldoBeras,
            'saldo_gabah'           => $saldoGabah,
            'kapasitas_beras'       => $kapasitasBeras,
            'kapasitas_gabah'       => $kapasitasGabah,
            'masuk_bulan_ini'       => $masukBeras + $masukGabah,
            'keluar_bulan_ini'      => $keluarBeras + $keluarGabah,
            'masuk_beras_bulan_ini' => $masukBeras,
            'masuk_gabah_bulan_ini' => $masukGabah,
            'keluar_beras_bulan_ini'=> $keluarBeras,
            'keluar_gabah_bulan_ini'=> $keluarGabah,
            'bulan'                 => now()->translatedFormat('F Y'),
        ]);
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/stok/transaksi
    // Daftar transaksi mutasi stok (paginated, filterable)
    // Query params: jenis, komoditas, tanggal, q (search)
    // ─────────────────────────────────────────────────────────
    public function transaksiList(Request $request)
    {
        $dc    = $this->dateColumn();
        $query = Stok::with(['gudang', 'user'])
            ->whereNotNull('jenis_transaksi')
            ->orderByDesc($dc);

        if ($request->filled('jenis')) {
            $query->where('jenis_transaksi', strtolower($request->jenis));
        }
        if ($request->filled('komoditas')) {
            $query->where('komoditas', $request->komoditas);
        }
        if ($request->filled('tanggal')) {
            try {
                $tgl = Carbon::parse($request->tanggal);
                $query->whereDate($dc, $tgl->toDateString());
            } catch (\Exception $e) {}
        }
        if ($request->filled('q')) {
            $q = $request->q;
            $query->where(function ($sub) use ($q) {
                $sub->where('komoditas',   'like', "%$q%")
                    ->orWhere('keterangan','like', "%$q%")
                    ->orWhere('catatan',   'like', "%$q%");
            });
        }

        $transaksi = $query->paginate(20);

        // Tambahkan field tambahan agar Flutter bisa render langsung
        $transaksi->getCollection()->transform(function ($item) use ($dc) {
            $raw = $item->{$dc} ?? $item->created_at;
            $item->tanggal_label = $raw
                ? Carbon::parse($raw)->format('Y-m-d H:i')
                : '-';
            $item->dicatat_oleh = $item->user?->name ?? 'Admin';
            return $item;
        });

        return response()->json($transaksi);
    }

    // ─────────────────────────────────────────────────────────
    // POST /api/stok/catat
    // Catat transaksi baru (masuk / keluar) — sama persis dgn
    // logika Admin\StokController@store di web
    // ─────────────────────────────────────────────────────────
    public function catatTransaksi(Request $request)
    {
        $data = $request->validate([
            'jenis'              => 'required|in:masuk,keluar',
            'komoditas'          => 'required|string',
            'jumlah'             => 'required|numeric|min:0.01',
            'tanggal'            => 'nullable|string',
            'tujuan_distribusi'  => 'nullable|string|max:255',
            'keterangan'         => 'nullable|string|max:255',
            'catatan'            => 'nullable|string',
            'gudang_id'          => 'nullable|integer|exists:gudang,id',
        ]);

        $dc      = $this->dateColumn();
        $gudangId = $data['gudang_id'] ?? 1;

        // Normalisasi tanggal
        if (! empty($data['tanggal'])) {
            $tanggal = str_replace('T', ' ', $data['tanggal']);
            if (preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/', $tanggal)) {
                $tanggal .= ':00';
            }
        } else {
            $tanggal = now()->format('Y-m-d H:i:s');
        }

        // Hitung running stock
        $previousStock = (float) (Stok::where('gudang_id', $gudangId)
            ->where('komoditas', $data['komoditas'])
            ->orderByDesc($dc)
            ->value('jumlah_stok') ?? 0);

        $jumlahStok = $data['jenis'] === 'keluar'
            ? $previousStock - (float) $data['jumlah']
            : $previousStock + (float) $data['jumlah'];

        $keterangan = trim(
            ($data['tujuan_distribusi'] ?? '') . ' ' . ($data['keterangan'] ?? '')
        ) ?: null;

        $payload = [
            'gudang_id'        => $gudangId,
            'jenis_transaksi'  => $data['jenis'],
            'komoditas'        => $data['komoditas'],
            'jumlah'           => (float) $data['jumlah'],
            'jumlah_stok'      => $jumlahStok,
            'keterangan'       => $keterangan,
            'catatan'          => $data['catatan'] ?? null,
            'created_at'       => now(),
            'updated_at'       => now(),
        ];

        // Tambahkan user_id jika kolom ada
        if (Schema::hasColumn('stok_beras', 'user_id') && Auth::check()) {
            $payload['user_id'] = Auth::id();
        }

        // Simpan ke kolom tanggal yang sesuai
        $payload[$dc] = $tanggal;

        $id = DB::table('stok_beras')->insertGetId($payload);

        // Cek alert jika jenis keluar
        if ($data['jenis'] === 'keluar') {
            $config       = Schema::hasTable('alert_configurations') ? AlertConfiguration::first() : null;
            $batasMinimum = $data['komoditas'] === 'Beras'
                ? ($config?->batas_min_beras ?? 400)
                : ($config?->batas_min_gabah ?? 1000);
            AlertController::checkAndCreateAlert($data['komoditas'], $jumlahStok, (int) $batasMinimum);
        }

        $stok = Stok::with('gudang')->find($id);
        return response()->json($stok, 201);
    }
}
