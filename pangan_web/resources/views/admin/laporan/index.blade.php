{{-- ============================================================
     LAPORAN
     ============================================================ --}}
@extends('layout.admin')

@section('title', 'Laporan')
@section('page-title', 'Laporan')
@section('page-subtitle', 'Rekapitulasi panen, stok, dan margin per periode')

@section('content')

{{-- FILTER --}}
<div class="card" style="margin-bottom:24px;">
    <div class="card-body" style="padding:20px 24px;">
        <form method="GET" action="{{ route('admin.laporan.index') }}">
            <div style="display:flex;align-items:flex-end;gap:16px;flex-wrap:wrap;">
                <div class="form-group" style="margin:0;flex:1;min-width:140px;">
                    <label>Jenis Laporan</label>
                    <select name="jenis">
                        <option value="panen" {{ request('jenis')=='panen'?'selected':'' }}>Laporan Panen</option>
                        <option value="stok" {{ request('jenis')=='stok'?'selected':'' }}>Laporan Stok</option>
                        <option value="margin" {{ request('jenis','margin')=='margin'?'selected':'' }}>Laporan Margin</option>
                    </select>
                </div>
                <div class="form-group" style="margin:0;flex:1;min-width:130px;">
                    <label>Dari Tanggal</label>
                    <input type="date" name="dari" value="{{ request('dari', date('Y-m-01')) }}">
                </div>
                <div class="form-group" style="margin:0;flex:1;min-width:130px;">
                    <label>Sampai Tanggal</label>
                    <input type="date" name="sampai" value="{{ request('sampai', date('Y-m-d')) }}">
                </div>
                <div class="form-group" style="margin:0;flex:1;min-width:130px;">
                    <label>Petani</label>
                    <select name="petani_id">
                        <option value="">Semua Petani</option>
                        @foreach($petanis ?? [] as $p)
                            <option value="{{ $p->id }}" {{ request('petani_id')==$p->id?'selected':'' }}>{{ $p->nama }}</option>
                        @endforeach
                    </select>
                </div>
                <button type="submit" class="btn btn-primary" style="flex-shrink:0;">
                    <i class="fas fa-filter"></i> Tampilkan
                </button>
                <div style="display:flex;gap:8px;flex-shrink:0;">
                    <a href="{{ route('admin.laporan.export', array_merge(request()->all(), ['format'=>'pdf'])) }}" class="btn btn-secondary">
                        <i class="fas fa-file-pdf"></i> PDF
                    </a>
                    <a href="{{ route('admin.laporan.export', array_merge(request()->all(), ['format'=>'excel'])) }}" class="btn btn-secondary">
                        <i class="fas fa-file-excel"></i> Excel
                    </a>
                </div>
            </div>
        </form>
    </div>
</div>

{{-- RINGKASAN --}}
<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:24px;">
    <div class="card" style="border-top:3px solid var(--green-500);">
        <div class="card-body" style="text-align:center;">
            <div style="font-size:12px;color:var(--text-muted);margin-bottom:8px;text-transform:uppercase;letter-spacing:.7px;font-weight:600;">Total Panen</div>
            <div style="font-size:28px;font-weight:800;">{{ number_format($totalPanen ?? 3000) }} kg</div>
            <div style="font-size:12px;color:var(--text-muted);">gabah periode ini</div>
        </div>
    </div>
    <div class="card" style="border-top:3px solid var(--blue-500);">
        <div class="card-body" style="text-align:center;">
            <div style="font-size:12px;color:var(--text-muted);margin-bottom:8px;text-transform:uppercase;letter-spacing:.7px;font-weight:600;">Total Distribusi</div>
            <div style="font-size:28px;font-weight:800;">{{ number_format($totalDistribusi ?? 1845) }} kg</div>
            <div style="font-size:12px;color:var(--text-muted);">beras periode ini</div>
        </div>
    </div>
    <div class="card" style="border-top:3px solid var(--amber-500);">
        <div class="card-body" style="text-align:center;">
            <div style="font-size:12px;color:var(--text-muted);margin-bottom:8px;text-transform:uppercase;letter-spacing:.7px;font-weight:600;">Estimasi Margin</div>
            <div style="font-size:28px;font-weight:800;">Rp {{ number_format(($totalDistribusi ?? 1845) * 3886, 0, ',', '.') }}</div>
            <div style="font-size:12px;color:var(--text-muted);">≈ Rp 3.886/kg × distribusi</div>
        </div>
    </div>
</div>

{{-- GRAFIK --}}
<div class="card" style="margin-bottom:24px;">
    <div class="card-header">
        <div class="card-title">Grafik Panen vs Distribusi</div>
    </div>
    <div class="card-body">
        <div class="chart-wrap" style="height:280px;">
            <canvas id="chartLaporan"></canvas>
        </div>
    </div>
</div>

{{-- TABEL DETAIL --}}
<div class="card">
    <div class="card-header">
        <div class="card-title">Detail Laporan Panen per Petani</div>
    </div>
    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Petani</th>
                    <th>Lahan (m²)</th>
                    <th>Tonase Gabah</th>
                    <th>Beras Dihasilkan</th>
                    <th>Musim</th>
                    <th>Tanggal Panen</th>
                    <th>HPP (est.)</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @forelse($laporanData ?? [] as $row)
                    <tr>
                        <td><strong>{{ $row->petani->nama }}</strong></td>
                        <td>{{ number_format($row->petani->luas_lahan) }}</td>
                        <td><strong>{{ number_format($row->tonase_gabah) }} kg</strong></td>
                        <td>{{ number_format($row->beras_dihasilkan) }} kg</td>
                        <td><span class="badge badge-green">{{ $row->musim }}</span></td>
                        <td style="font-size:12.5px;">{{ $row->tanggal_panen }}</td>
                        <td>Rp {{ number_format($row->hpp_estimasi) }}</td>
                        <td><span class="badge badge-{{ $row->status=='selesai'?'green':'amber' }}">{{ $row->status }}</span></td>
                    </tr>
                @empty
                    @foreach([
                        ['Silvy Halimatusyadiah', '9.200', '3.000', '1.845', 'Okt-Mar 2025', 'Maret 2025', '17.710.200', 'selesai'],
                        ['Budi Santoso', '5.000', '1.800', '1.107', 'Okt-Mar 2025', 'Feb 2025',  '10.643.598', 'selesai'],
                    ] as $r)
                        <tr>
                            <td><strong>{{ $r[0] }}</strong></td>
                            <td>{{ $r[1] }}</td>
                            <td><strong>{{ $r[2] }} kg</strong></td>
                            <td>{{ $r[3] }} kg</td>
                            <td><span class="badge badge-green">{{ $r[4] }}</span></td>
                            <td style="font-size:12.5px;">{{ $r[5] }}</td>
                            <td>Rp {{ $r[6] }}</td>
                            <td><span class="badge badge-{{ $r[7]=='selesai'?'green':'amber' }}">{{ $r[7] }}</span></td>
                        </tr>
                    @endforeach
                @endforelse
            </tbody>
        </table>
    </div>
</div>

@endsection

@push('scripts')
<script>
new Chart(document.getElementById('chartLaporan').getContext('2d'), {
    type: 'bar',
    data: {
        labels: ['Oktober', 'November', 'Desember', 'Januari', 'Februari', 'Maret'],
        datasets: [
            {
                label: 'Gabah Masuk (kg)',
                data: [0, 3200, 0, 2800, 4100, 3000],
                backgroundColor: 'rgba(245,158,11,.75)',
                borderRadius: 6,
            },
            {
                label: 'Beras Distribusi (kg)',
                data: [800, 1200, 900, 1500, 1800, 1845],
                backgroundColor: 'rgba(56,161,105,.75)',
                borderRadius: 6,
            }
        ]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { position: 'bottom', labels: { font: { family: 'Plus Jakarta Sans', size: 12 } } }
        },
        scales: {
            y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,.05)' }, ticks: { font: { family: 'Plus Jakarta Sans', size: 11 } } },
            x: { grid: { display: false }, ticks: { font: { family: 'Plus Jakarta Sans', size: 11 } } }
        }
    }
});
</script>
@endpush
