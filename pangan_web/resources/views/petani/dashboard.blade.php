@extends('layout.admin')

@section('title', 'Dashboard Petani')
@section('page-title', 'Dashboard Petani')
@section('page-subtitle', 'Ringkasan data petani dan aktivitas panen Anda')

@section('content')
<style>
    .petani-dashboard {
        display: grid;
        gap: 20px;
        width: min(100%, 1040px);
        margin: 0 auto;
        padding: 0 16px;
    }

    .petani-hero,
    .petani-card,
    .petani-panel {
        border: 1px solid var(--border);
        border-radius: 22px;
        background: var(--surface);
        padding: 20px;
        box-shadow: 0 14px 36px rgba(10, 27, 52, .05);
    }

    .petani-hero {
        display: grid;
        gap: 18px;
    }

    .petani-hero-top {
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
        gap: 16px;
        align-items: center;
    }

    .petani-hero-text {
        min-width: 220px;
    }

    .petani-hero-status {
        min-width: 170px;
        padding: 16px;
        border-radius: 18px;
        background: var(--blue-50);
        text-align: center;
    }

    .petani-summary {
        display: grid;
        gap: 16px;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    }

    .petani-panels {
        display: grid;
        gap: 20px;
    }

    .petani-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 14px;
    }

    .petani-table th,
    .petani-table td {
        padding: 12px 10px;
        border-bottom: 1px solid var(--border);
    }

    .petani-table thead tr {
        background: var(--surface-2);
        color: var(--text-muted);
        text-transform: uppercase;
        font-size: 12px;
        letter-spacing: .05em;
    }

    .petani-panel-header {
        display: flex;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 12px;
        align-items: center;
        margin-bottom: 16px;
    }

    @media (min-width: 860px) {
        .petani-panels {
            grid-template-columns: 1fr 340px;
        }
    }
</style>

<div class="petani-dashboard">
    <div class="petani-hero">
        <div class="petani-hero-top">
            <div class="petani-hero-text">
                <div style="font-size:13px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.12em;margin-bottom:10px;">Selamat datang</div>
                <h2 style="margin:0 0 10px;">Halo, {{ auth()->user()->name }}</h2>
                <p style="margin:0;color:var(--text-muted);max-width:820px;">Anda login sebagai <strong>Petani</strong>. Di sini Anda dapat melihat riwayat panen sendiri dan informasi harga aktif terbaru.</p>
            </div>
            <div class="petani-hero-status">
                <div style="font-size:12px;color:var(--blue-700);text-transform:uppercase;letter-spacing:.08em;margin-bottom:8px;">Status Akun</div>
                <div style="font-size:26px;font-weight:800;color:var(--blue-900);">{{ ucfirst($petani->status ?? 'Aktif') }}</div>
            </div>
        </div>

        <div class="petani-summary">
            <div class="summary-card">
                <div class="summary-card-title">Total Lahan</div>
                <div class="summary-card-value">{{ number_format($totalLahan) }}</div>
            </div>
            <div class="summary-card">
                <div class="summary-card-title">Total Panen</div>
                <div class="summary-card-value">{{ number_format($totalPanen) }}</div>
            </div>
            <div class="summary-card">
                <div class="summary-card-title">Komoditas</div>
                <div class="summary-card-value">{{ $petani->komoditas ?? '-' }}</div>
            </div>
            <div class="summary-card">
                <div class="summary-card-title">Harga Jual Beras</div>
                <div class="summary-card-value">@if($activePrice) Rp {{ number_format($activePrice->harga_jual_beras, 0, ',', '.') }} @else - @endif</div>
            </div>
        </div>
    </div>

    <div class="petani-panels">
        <div class="petani-card">
            <div class="petani-panel-header">
                <div>
                    <div style="font-size:13px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.08em;">Riwayat Panen Terbaru</div>
                    <h3 style="margin:8px 0 0;">{{ $panens->count() }} entri</h3>
                </div>
                <span style="padding:10px 16px;border-radius:999px;background:var(--green-100);color:var(--green-800);font-weight:700;">Akun Petani</span>
            </div>

            @if($panens->count())
                <div style="overflow-x:auto;">
                    <table class="petani-table">
                        <thead>
                            <tr>
                                <th style="text-align:left;">Tanggal</th>
                                <th style="text-align:right;">Gabah</th>
                                <th style="text-align:right;">Harga/kg</th>
                                <th style="text-align:right;">Estimasi Beras</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($panens->take(8) as $panen)
                                <tr>
                                    <td>{{ optional($panen->tanggal_panen)->format('d M Y') }}</td>
                                    <td style="text-align:right;">{{ number_format($panen->jumlah_gabah, 0, ',', '.') }} kg</td>
                                    <td style="text-align:right;">Rp {{ number_format($panen->harga_gabah_per_kg, 0, ',', '.') }}</td>
                                    <td style="text-align:right;">{{ number_format($panen->beras_dihasilkan, 2, ',', '.') }} kg</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @else
                <p style="margin:0;color:var(--text-muted);">Belum ada catatan panen. Silakan tambahkan data panen melalui menu yang tersedia.</p>
            @endif
        </div>

        <div class="petani-card">
            <div class="petani-panel-header">
                <div>
                    <div style="font-size:13px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.08em;">Informasi Harga Aktif</div>
                    <h3 style="margin:8px 0 0;">{{ $activePrice ? 'Tersedia' : 'Belum aktif' }}</h3>
                </div>
                <i class="fas fa-dollar-sign" style="font-size:22px;color:var(--green-700);"></i>
            </div>

            @if($activePrice)
                <div style="display:grid;gap:10px;">
                    <div style="display:flex;justify-content:space-between;">
                        <span>Harga Beli Gabah</span>
                        <strong>Rp {{ number_format($activePrice->harga_beli_gabah, 0, ',', '.') }}</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;">
                        <span>Ongkos Giling</span>
                        <strong>Rp {{ number_format($activePrice->ongkos_giling, 0, ',', '.') }}</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;">
                        <span>Harga Jual Beras</span>
                        <strong>Rp {{ number_format($activePrice->harga_jual_beras, 0, ',', '.') }}</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;">
                        <span>Rasio</span>
                        <strong>{{ number_format($activePrice->rasio_konversi, 2, ',', '.') }}</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;color:var(--text-muted);font-size:13px;">
                        <span>Mulai berlaku</span>
                        <span>{{ optional($activePrice->berlaku_mulai)->format('d M Y') ?? '-' }}</span>
                    </div>
                </div>
            @else
                <p style="margin:0;color:var(--text-muted);">Saat ini belum ada harga aktif. Silakan hubungi Petugas atau Admin untuk update harga.</p>
            @endif
        </div>
    </div>
</div>
@endsection
