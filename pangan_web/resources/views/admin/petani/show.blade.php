@extends('layout.admin')

@section('title', 'Detail Petani')
@section('page-title', 'Detail Data Petani')

@section('content')

@php
    $lahans = $petani->lahan;
    $jumlahLahan = $lahans->count();
    $totalLuasLahan = $lahans->sum('luas');
@endphp

<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Detail Petani</div>
            <div class="card-subtitle">Informasi lengkap petani dan ringkasan lahan terkait</div>
        </div>
        <div style="display:flex; gap:12px; flex-wrap:wrap; align-items:center;">
            <a href="{{ route('admin.petani.edit', $petani) }}" class="btn btn-primary btn-sm" style="background:#fd7e14; border:none; color:#fff;">
                <span>✏️</span>
                <span>Edit</span>
            </a>
            <form action="{{ route('admin.petani.destroy', $petani) }}" method="POST" style="display:inline;">
                @csrf
                @method('DELETE')
                <button type="submit" class="btn btn-danger btn-sm" style="min-width:120px;">
                    <span>🗑️</span>
                    <span>Hapus</span>
                </button>
            </form>
            <a href="{{ route('admin.petani.index') }}" class="btn btn-secondary btn-sm" style="min-width:120px;">
                <span>↩️</span>
                <span>Kembali</span>
            </a>
        </div>
    </div>

    <div class="card-body">
        <div class="stat-grid">
            <div class="stat-card green">
                <div class="stat-icon">👤</div>
                <div class="stat-value">{{ $petani->nama }}</div>
                <div class="stat-label">Nama Petani</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-icon">🌾</div>
                <div class="stat-value">{{ $jumlahLahan }}</div>
                <div class="stat-label">Jumlah Lahan</div>
            </div>
            <div class="stat-card amber">
                <div class="stat-icon">📏</div>
                <div class="stat-value">{{ $totalLuasLahan ?: '-' }}</div>
                <div class="stat-label">Total Luas (ha)</div>
            </div>
            <div class="stat-card {{ $petani->status === 'aktif' ? 'green' : 'red' }}">
                <div class="stat-icon">⚡</div>
                <div class="stat-value">{{ ucfirst($petani->status) }}</div>
                <div class="stat-label">Status Aktif</div>
            </div>
        </div>

        <div class="grid-2" style="gap:24px; margin-bottom:24px;">
            <div class="card" style="padding:20px;">
                <div class="card-title" style="margin-bottom:16px;">Informasi Utama</div>
                <div style="display:grid; grid-template-columns:140px 1fr; gap:12px; row-gap:14px;">
                    <div style="font-weight:600; color:var(--text-muted);">Nama</div>
                    <div>{{ $petani->nama }}</div>

                    <div style="font-weight:600; color:var(--text-muted);">NIK</div>
                    <div>{{ $petani->nik ?? '-' }}</div>

                    <div style="font-weight:600; color:var(--text-muted);">Komoditas</div>
                    <div>{{ $petani->komoditas ?? '-' }}</div>

                    <div style="font-weight:600; color:var(--text-muted);">Luas Lahan</div>
                    <div>{{ $petani->luas_lahan ? $petani->luas_lahan . ' ha' : '-' }}</div>

                    <div style="font-weight:600; color:var(--text-muted);">Tanggal Lahir</div>
                    <div>{{ $petani->tanggal_lahir ? \Carbon\Carbon::parse($petani->tanggal_lahir)->format('d M Y') : '-' }}</div>
                </div>
            </div>

            <div class="card" style="padding:20px;">
                <div class="card-title" style="margin-bottom:16px;">Kontak & Lainnya</div>
                <div style="display:grid; grid-template-columns:140px 1fr; gap:12px; row-gap:14px;">
                    <div style="font-weight:600; color:var(--text-muted);">No. Telepon/HP</div>
                    <div>{{ $petani->telepon ?? $petani->no_hp ?? '-' }}</div>

                    <div style="font-weight:600; color:var(--text-muted);">Email</div>
                    <div>{{ $petani->email ?? '-' }}</div>

                    <div style="font-weight:600; color:var(--text-muted);">Alamat</div>
                    <div>{{ $petani->alamat }}</div>

                    <div style="font-weight:600; color:var(--text-muted);">Terdaftar</div>
                    <div>{{ $petani->created_at->format('d M Y H:i') }}</div>
                </div>
            </div>
        </div>

        <div class="card" style="padding:20px;">
            <div class="card-title" style="margin-bottom:16px;">Catatan Petani</div>
            <div style="color:var(--text-secondary); font-size:14px; min-height:80px;">
                {{ $petani->catatan ?: 'Tidak ada catatan tambahan untuk petani ini.' }}
            </div>
        </div>

        <div class="card" style="padding:20px; margin-top:24px;">
            <div class="card-title" style="margin-bottom:16px;">Data Lahan</div>

            @if ($jumlahLahan > 0)
                <table class="table table-striped" style="width:100%; border-collapse:collapse;">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>Nama Lahan</th>
                            <th>Luas (ha)</th>
                            <th>Lokasi</th>
                            <th>Jenis Tanah</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($lahans as $lahan)
                            <tr>
                                <td>{{ $loop->iteration }}</td>
                                <td>{{ $lahan->nama_lahan }}</td>
                                <td>{{ $lahan->luas }}</td>
                                <td style="font-size:13px; color:var(--text-muted);">{{ $lahan->lokasi }}</td>
                                <td>{{ ucfirst($lahan->jenis_tanah) }}</td>
                                <td>
                                    <span style="padding:4px 8px; border-radius:4px; color:white; font-size:12px; background-color:{{ $lahan->status === 'aktif' ? '#28a745' : '#dc3545' }};">
                                        {{ ucfirst($lahan->status) }}
                                    </span>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @else
                <p style="color:#6b7280; font-style:italic; margin:0;">Belum ada data lahan untuk petani ini.</p>
            @endif
        </div>
    </div>
</div>

@endsection
