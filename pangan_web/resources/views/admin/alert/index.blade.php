{{-- ALERT PAGE --}}
@extends('layout.admin')

@section('title', 'Alert Stok')
@section('page-title', 'Alert Stok')
@section('page-subtitle', 'Notifikasi otomatis saat stok mendekati batas minimum')

@section('content')

{{-- BATAS MINIMUM KONFIGURASI --}}
<div class="grid-2" style="margin-bottom:24px;">
    <div class="card">
        <div class="card-header">
            <div>
                <div class="card-title">Konfigurasi Batas Minimum</div>
                <div class="card-subtitle">Sistem akan memicu alert jika stok ≤ nilai ini</div>
            </div>
            <button class="btn btn-primary btn-sm" onclick="openModal('modalKonfigAlert')">
                <i class="fas fa-cog"></i> Ubah
            </button>
        </div>
        <div class="card-body">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                <div style="background:var(--surface-2);border-radius:10px;padding:16px;text-align:center;">
                    <div style="font-size:13px;color:var(--text-muted);margin-bottom:8px;">🌾 Beras</div>
                    <div style="font-size:28px;font-weight:800;color:var(--red-500);">{{ $batasMinBeras ?? 200 }}</div>
                    <div style="font-size:12px;color:var(--text-muted);">kg minimum</div>
                    <div style="margin-top:10px;font-size:12px;">
                        Stok saat ini: <strong style="color:var(--green-600);">{{ $stokBeras ?? 450 }} kg</strong>
                    </div>
                </div>
                <div style="background:var(--surface-2);border-radius:10px;padding:16px;text-align:center;">
                    <div style="font-size:13px;color:var(--text-muted);margin-bottom:8px;">🌾 Gabah</div>
                    <div style="font-size:28px;font-weight:800;color:var(--amber-500);">{{ $batasMinGabah ?? 500 }}</div>
                    <div style="font-size:12px;color:var(--text-muted);">kg minimum</div>
                    <div style="margin-top:10px;font-size:12px;">
                        Stok saat ini: <strong style="color:var(--green-600);">{{ $stokGabah ?? 800 }} kg</strong>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div class="card-title">Ringkasan Status Alert</div>
        </div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:14px;">
                <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px;background:var(--red-100);border-radius:10px;">
                    <div style="display:flex;align-items:center;gap:10px;">
                        <i class="fas fa-circle-exclamation" style="color:var(--red-500);font-size:18px;"></i>
                        <span style="font-weight:600;color:#991b1b;">Alert Aktif</span>
                    </div>
                    <span style="font-size:22px;font-weight:800;color:var(--red-500);">{{ $alertAktif ?? 0 }}</span>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px;background:var(--amber-100);border-radius:10px;">
                    <div style="display:flex;align-items:center;gap:10px;">
                        <i class="fas fa-clock" style="color:var(--amber-500);font-size:18px;"></i>
                        <span style="font-weight:600;color:#92400e;">Dalam Penanganan</span>
                    </div>
                    <span style="font-size:22px;font-weight:800;color:var(--amber-500);">{{ $alertProses ?? 1 }}</span>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px;background:var(--green-100);border-radius:10px;">
                    <div style="display:flex;align-items:center;gap:10px;">
                        <i class="fas fa-check-circle" style="color:var(--green-600);font-size:18px;"></i>
                        <span style="font-weight:600;color:var(--green-700);">Sudah Ditangani</span>
                    </div>
                    <span style="font-size:22px;font-weight:800;color:var(--green-600);">{{ $alertSelesai ?? 5 }}</span>
                </div>
            </div>
        </div>
    </div>
</div>

{{-- DAFTAR ALERT --}}
<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Riwayat Alert</div>
            <div class="card-subtitle">Semua notifikasi sistem, terbaru di atas</div>
        </div>
        <div style="display:flex;gap:8px;">
            <select id="filterStatus" onchange="filterAlert()" style="width:auto;min-width:160px;padding:8px 12px;border-radius:8px;border:1.5px solid var(--border);font-size:13px;font-family:inherit;">
                <option value="">Semua Status</option>
                <option value="aktif">Aktif</option>
                <option value="proses">Dalam Proses</option>
                <option value="selesai">Sudah Ditangani</option>
            </select>
        </div>
    </div>

    <div class="table-container">
        <table class="data-table" id="tableAlert">
            <thead>
                <tr>
                    <th>Waktu</th>
                    <th>Komoditas</th>
                    <th>Stok Saat Alert</th>
                    <th>Batas Minimum</th>
                    <th>Status</th>
                    <th>Ditangani Oleh</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @php
                    $alerts = [
                        ['Hari ini 07:25', 'Beras', 195, 200, 'aktif',   '-'],
                        ['3 hari lalu',    'Gabah', 450, 500, 'selesai', 'Admin'],
                        ['1 minggu lalu',  'Beras', 180, 200, 'selesai', 'Petugas A'],
                        ['2 minggu lalu',  'Beras', 150, 200, 'selesai', 'Admin'],
                    ];
                @endphp
                @foreach(($alertList ?? $alerts) as $a)
                    @php
                        $status = is_array($a) ? $a[4] : $a->status;
                        $komoditas = is_array($a) ? $a[1] : $a->komoditas;
                        $stok = is_array($a) ? $a[2] : $a->stok_saat_ini;
                        $batas = is_array($a) ? $a[3] : $a->batas_minimum;
                        $waktu = is_array($a) ? $a[0] : $a->created_at;
                        $handler = is_array($a) ? $a[5] : ($a->handler->name ?? '-');
                        $id = is_array($a) ? null : $a->id;
                    @endphp
                    <tr>
                        <td style="font-size:12.5px;">{{ $waktu }}</td>
                        <td>
                            <span class="badge badge-{{ $komoditas == 'Beras' ? 'blue' : 'amber' }}">
                                {{ $komoditas }}
                            </span>
                        </td>
                        <td>
                            <strong style="color:var(--red-500);">{{ number_format($stok) }} kg</strong>
                        </td>
                        <td><strong>{{ number_format($batas) }} kg</strong></td>
                        <td>
                            <span class="badge badge-{{ $status == 'aktif' ? 'red' : ($status == 'proses' ? 'amber' : 'green') }}">
                                <i class="fas fa-{{ $status == 'aktif' ? 'circle-exclamation' : ($status == 'proses' ? 'clock' : 'check') }}"></i>
                                {{ $status == 'aktif' ? 'Aktif' : ($status == 'proses' ? 'Dalam Proses' : 'Ditangani') }}
                            </span>
                        </td>
                        <td style="font-size:12.5px;color:var(--text-secondary);">{{ $handler }}</td>
                        <td>
                            @if($status == 'aktif')
                                <form method="POST" action="{{ $id ? route('admin.alert.tangani', $id) : '#' }}" style="display:inline;">
                                    @csrf @method('PATCH')
                                    <button type="submit" class="btn btn-primary btn-sm">
                                        <i class="fas fa-check"></i> Tandai Ditangani
                                    </button>
                                </form>
                            @else
                                <span style="font-size:12px;color:var(--text-muted);">—</span>
                            @endif
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>

{{-- MODAL KONFIGURASI ALERT --}}
<div class="modal-overlay" id="modalKonfigAlert">
    <div class="modal">
        <div class="modal-header">
            <div class="modal-title">Konfigurasi Batas Minimum Alert</div>
            <button class="modal-close" onclick="closeModal('modalKonfigAlert')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="{{ route('admin.alert.konfigurasi') }}">
            @csrf @method('PUT')
            <div class="modal-body">
                <div class="alert-banner warning" style="margin-bottom:20px;">
                    <i class="fas fa-info-circle"></i>
                    <div>Sistem menggunakan nilai default (200 kg beras, 500 kg gabah) jika belum dikonfigurasi.</div>
                </div>
                <div class="grid-2">
                    <div class="form-group">
                        <label>Batas Minimum Beras (kg)</label>
                        <input type="number" name="batas_min_beras" value="{{ $batasMinBeras ?? 200 }}" min="0" required>
                        <div class="form-hint">Default: 200 kg</div>
                    </div>
                    <div class="form-group">
                        <label>Batas Minimum Gabah (kg)</label>
                        <input type="number" name="batas_min_gabah" value="{{ $batasMinGabah ?? 500 }}" min="0" required>
                        <div class="form-hint">Default: 500 kg</div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalKonfigAlert')">Batal</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Simpan Konfigurasi</button>
            </div>
        </form>
    </div>
</div>

@endsection

@push('scripts')
<script>
function filterAlert() {
    const s = document.getElementById('filterStatus').value.toLowerCase();
    document.querySelectorAll('#tableAlert tbody tr').forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = (s === '' || text.includes(s)) ? '' : 'none';
    });
}
</script>
@endpush
