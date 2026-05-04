{{-- DASHBOARD PAGE --}}
@extends('layout.admin')

@section('title', 'Dashboard')
@section('page-title', 'Dashboard')
@section('page-subtitle', 'Ringkasan stok, tren panen, dan monitoring real-time')

@section('content')

{{-- ALERT AKTIF --}}
@if(isset($alertAktif) && $alertAktif->count())
    <div class="alert-banner danger" style="margin-bottom:20px;">
        <i class="fas fa-exclamation-triangle" style="margin-top:2px;"></i>
        <div>
            <strong>{{ $alertAktif->count() }} Alert Stok Aktif!</strong><br>
            <span style="font-size:12.5px;">
                Stok menipis: 
                @foreach($alertAktif->take(3) as $a)
                    <strong>{{ $a->komoditas }}</strong> ({{ number_format($a->stok_saat_ini) }} kg)@if(!$loop->last), @endif
                @endforeach
                @if($alertAktif->count() > 3) dan {{ $alertAktif->count() - 3 }} lainnya @endif
                — <a href="{{ route('admin.alert.index') }}" style="color:inherit;text-decoration:underline;">Lihat semua alert</a>
            </span>
        </div>
    </div>
@endif

{{-- STAT CARDS --}}
<div class="stat-grid">
    <div class="stat-card green animate-in">
        <div class="stat-icon"><i class="fas fa-warehouse"></i></div>
        <div class="stat-value">{{ number_format($stokBeras ?? 450) }} <small style="font-size:14px;font-weight:600;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Stok Beras</div>
        <div class="stat-change up">
            <i class="fas fa-arrow-up"></i>
            Kapasitas max 1.000 kg ({{ round((($stokBeras ?? 450)/1000)*100) }}%)
        </div>
        <div style="margin-top:10px;">
            <div class="progress-bar">
                <div class="progress-fill" style="width:{{ round((($stokBeras ?? 450)/1000)*100) }}%;background:var(--green-500);"></div>
            </div>
        </div>
    </div>

    <div class="stat-card amber animate-in">
        <div class="stat-icon"><i class="fas fa-seedling"></i></div>
        <div class="stat-value">{{ number_format($stokGabah ?? 800) }} <small style="font-size:14px;font-weight:600;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Stok Gabah</div>
        <div class="stat-change up">
            <i class="fas fa-arrow-up"></i>
            Kapasitas max 2.000 kg ({{ round((($stokGabah ?? 800)/2000)*100) }}%)
        </div>
        <div style="margin-top:10px;">
            <div class="progress-bar">
                <div class="progress-fill" style="width:{{ round((($stokGabah ?? 800)/2000)*100) }}%;background:var(--amber-500);"></div>
            </div>
        </div>
    </div>

    <div class="stat-card blue animate-in">
        <div class="stat-icon"><i class="fas fa-chart-line"></i></div>
        <div class="stat-value">{{ number_format($targetBulan ?? 9000) }} <small style="font-size:14px;font-weight:600;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Target Pasar / Bulan</div>
        <div class="stat-change" style="color:var(--blue-500);">
            <i class="fas fa-info-circle"></i>
            Distribusi MBG 465 kg/hari
        </div>
    </div>

    <div class="stat-card {{ ($alertAktif ?? collect())->count() > 0 ? 'red' : 'green' }} animate-in">
        <div class="stat-icon"><i class="fas fa-bell"></i></div>
        <div class="stat-value">{{ ($alertAktif ?? collect())->count() }}</div>
        <div class="stat-label">Alert Aktif</div>
        <div class="stat-change {{ ($alertAktif ?? collect())->count() > 0 ? 'down' : 'up' }}">
            <i class="fas fa-{{ ($alertAktif ?? collect())->count() > 0 ? 'exclamation-triangle' : 'check-circle' }}"></i>
            {{ ($alertAktif ?? collect())->count() > 0 ? 'Perlu penanganan segera' : 'Semua stok aman' }}
        </div>
    </div>
</div>

{{-- CHARTS ROW --}}
<div class="grid-2" style="margin-bottom:24px;">
    {{-- Grafik Stok vs Target --}}
    <div class="card animate-in">
        <div class="card-header">
            <div>
                <div class="card-title">Stok vs Target Pasar</div>
                <div class="card-subtitle">Perbandingan stok tersedia vs target 9.000 kg/bulan (6 bulan terakhir)</div>
            </div>
        </div>
        <div class="card-body">
            <div class="chart-wrap" style="height:240px;">
                <canvas id="chartStokTarget"></canvas>
            </div>
        </div>
    </div>

    {{-- Tren Panen --}}
    <div class="card animate-in">
        <div class="card-header">
            <div>
                <div class="card-title">Tren Hasil Panen</div>
                <div class="card-subtitle">Gabah masuk per bulan (ton)</div>
            </div>
        </div>
        <div class="card-body">
            <div class="chart-wrap" style="height:240px;">
                <canvas id="chartTrenPanen"></canvas>
            </div>
        </div>
    </div>
</div>

{{-- BOTTOM ROW --}}
<div class="grid-2">
    {{-- Distribusi Terkini --}}
    <div class="card">
        <div class="card-header">
            <div>
                <div class="card-title">Distribusi Terkini</div>
                <div class="card-subtitle">Transaksi stok keluar terbaru</div>
            </div>
            <a href="{{ route('admin.stok.index') }}" class="btn btn-secondary btn-sm">Lihat Semua</a>
        </div>
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Tujuan</th>
                        <th>Komoditas</th>
                        <th>Jumlah</th>
                        <th>Tanggal</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($distribusiTerkini ?? [] as $dist)
                        <tr>
                            <td>
                                <div style="font-weight:600;">{{ $dist->tujuan }}</div>
                                <div style="font-size:11.5px;color:var(--text-muted);">{{ $dist->jenis_tujuan }}</div>
                            </td>
                            <td><span class="badge badge-green">{{ $dist->komoditas }}</span></td>
                            <td><strong>{{ number_format($dist->jumlah) }} kg</strong></td>
                            <td style="color:var(--text-muted);font-size:12.5px;">{{ $dist->tanggal }}</td>
                        </tr>
                    @empty
                        {{-- DUMMY DATA untuk preview --}}
                        <tr>
                            <td><div style="font-weight:600;">Dapur MBG 1</div><div style="font-size:11.5px;color:var(--text-muted);">MBG</div></td>
                            <td><span class="badge badge-green">Beras</span></td>
                            <td><strong>155 kg</strong></td>
                            <td style="color:var(--text-muted);font-size:12.5px;">Hari ini</td>
                        </tr>
                        <tr>
                            <td><div style="font-weight:600;">Dapur MBG 2</div><div style="font-size:11.5px;color:var(--text-muted);">MBG</div></td>
                            <td><span class="badge badge-green">Beras</span></td>
                            <td><strong>155 kg</strong></td>
                            <td style="color:var(--text-muted);font-size:12.5px;">Hari ini</td>
                        </tr>
                        <tr>
                            <td><div style="font-weight:600;">Toko Rudi</div><div style="font-size:11.5px;color:var(--text-muted);">Toko Mitra</div></td>
                            <td><span class="badge badge-green">Beras</span></td>
                            <td><strong>100 kg</strong></td>
                            <td style="color:var(--text-muted);font-size:12.5px;">Kemarin</td>
                        </tr>
                        <tr>
                            <td><div style="font-weight:600;">Toko Barokah</div><div style="font-size:11.5px;color:var(--text-muted);">Toko Mitra</div></td>
                            <td><span class="badge badge-green">Beras</span></td>
                            <td><strong>80 kg</strong></td>
                            <td style="color:var(--text-muted);font-size:12.5px;">Kemarin</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    {{-- Ringkasan Margin & HPP --}}
    <div class="card">
        <div class="card-header">
            <div>
                <div class="card-title">Kalkulasi Margin & HPP</div>
                <div class="card-subtitle">Berdasarkan harga konfigurasi aktif</div>
            </div>
            <a href="{{ route('admin.harga.index') }}" class="btn btn-secondary btn-sm">Ubah Harga</a>
        </div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:16px;">

                <div style="background:var(--surface-2);border-radius:10px;padding:16px;">
                    <div style="font-size:12px;color:var(--text-muted);margin-bottom:8px;font-weight:600;text-transform:uppercase;letter-spacing:.7px;">Harga Beli Gabah</div>
                    <div style="font-size:22px;font-weight:800;">Rp 760.000 <small style="font-size:13px;font-weight:500;color:var(--text-muted);">/ 100 kg</small></div>
                </div>

                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                    <div style="background:var(--surface-2);border-radius:10px;padding:14px;">
                        <div style="font-size:11.5px;color:var(--text-muted);margin-bottom:6px;">Ongkos Giling</div>
                        <div style="font-size:17px;font-weight:700;">Rp 700 / kg</div>
                    </div>
                    <div style="background:var(--surface-2);border-radius:10px;padding:14px;">
                        <div style="font-size:11.5px;color:var(--text-muted);margin-bottom:6px;">Harga Jual Beras</div>
                        <div style="font-size:17px;font-weight:700;">Rp 13.500 / kg</div>
                    </div>
                </div>

                <div style="background:var(--green-50);border:1.5px solid var(--green-300);border-radius:10px;padding:16px;">
                    <div style="font-size:12px;color:var(--green-700);margin-bottom:6px;font-weight:700;">💰 Estimasi Margin Bersih</div>
                    <div style="font-size:24px;font-weight:800;color:var(--green-700);">≈ Rp 3.900 / kg</div>
                    <div style="font-size:12px;color:var(--green-600);margin-top:4px;">HPP ≈ Rp 9.600/kg &nbsp;|&nbsp; Margin ≈ 40,6%</div>
                </div>

                <div style="background:var(--blue-100);border-radius:10px;padding:14px;display:flex;align-items:center;gap:12px;">
                    <i class="fas fa-chart-bar" style="font-size:22px;color:var(--blue-500);"></i>
                    <div>
                        <div style="font-weight:700;font-size:14px;color:#1e40af;">Estimasi Pendapatan Bulan Ini</div>
                        <div style="font-size:13px;color:#1e40af;">{{ number_format(($stokBeras ?? 450) * 13500, 0, ',', '.') }} (stok saat ini × harga jual)</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<script>
// Chart: Stok vs Target
const ctx1 = document.getElementById('chartStokTarget').getContext('2d');
new Chart(ctx1, {
    type: 'bar',
    data: {
        labels: ['Nov', 'Des', 'Jan', 'Feb', 'Mar', 'Apr'],
        datasets: [
            {
                label: 'Stok Beras (kg)',
                data: [7200, 8100, 6800, 7500, 8900, 450],
                backgroundColor: 'rgba(56,161,105,.75)',
                borderRadius: 6,
                borderSkipped: false,
            },
            {
                label: 'Target (9.000 kg)',
                data: [9000, 9000, 9000, 9000, 9000, 9000],
                type: 'line',
                borderColor: '#f59e0b',
                borderDash: [5,4],
                borderWidth: 2,
                pointRadius: 0,
                tension: 0,
            }
        ]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { position: 'bottom', labels: { font: { family: 'Plus Jakarta Sans', size: 11 } } },
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: { color: 'rgba(0,0,0,.05)' },
                ticks: { font: { family: 'Plus Jakarta Sans', size: 11 } }
            },
            x: {
                grid: { display: false },
                ticks: { font: { family: 'Plus Jakarta Sans', size: 11 } }
            }
        }
    }
});

// Chart: Tren Panen
const ctx2 = document.getElementById('chartTrenPanen').getContext('2d');
new Chart(ctx2, {
    type: 'line',
    data: {
        labels: ['Nov', 'Des', 'Jan', 'Feb', 'Mar', 'Apr'],
        datasets: [{
            label: 'Gabah Masuk (kg)',
            data: [3200, 0, 2800, 4100, 3000, 800],
            borderColor: '#f59e0b',
            backgroundColor: 'rgba(245,158,11,.1)',
            borderWidth: 2.5,
            pointBackgroundColor: '#f59e0b',
            pointRadius: 5,
            fill: true,
            tension: .35,
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { position: 'bottom', labels: { font: { family: 'Plus Jakarta Sans', size: 11 } } },
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: { color: 'rgba(0,0,0,.05)' },
                ticks: { font: { family: 'Plus Jakarta Sans', size: 11 } }
            },
            x: {
                grid: { display: false },
                ticks: { font: { family: 'Plus Jakarta Sans', size: 11 } }
            }
        }
    }
});
</script>
@endpush
