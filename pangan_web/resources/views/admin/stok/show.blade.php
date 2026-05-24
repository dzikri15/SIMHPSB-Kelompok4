@extends('layout.admin')

@section('title', 'Detail Transaksi Stok')
@section('page-title', 'Detail Transaksi Stok')
@section('page-subtitle', 'Informasi lengkap transaksi stok gudang')

@section('content')

<div class="card">
    <div style="margin-bottom:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
        <a href="{{ route('admin.stok.index') }}" class="btn btn-secondary btn-sm">
            ← Kembali ke Stok Gudang
        </a>
    </div>

    <div style="display:grid; grid-template-columns:220px 1fr; gap:18px;">
        <div style="font-weight:700; color:var(--text-muted);">Tanggal Transaksi</div>
        <div>{{ $stok->tanggal ? \Carbon\Carbon::parse($stok->tanggal)->format('d M Y H:i') : ($stok->created_at?->format('d M Y H:i') ?? '-') }}</div>

        <div style="font-weight:700; color:var(--text-muted);">Jenis Transaksi</div>
        <div>
            <span class="badge badge-{{ $stok->jenis_transaksi === 'masuk' ? 'green' : 'red' }}">
                <i class="fas fa-{{ $stok->jenis_transaksi === 'masuk' ? 'arrow-down' : 'arrow-up' }}"></i>
                {{ ucfirst($stok->jenis_transaksi) }}
            </span>
        </div>

        <div style="font-weight:700; color:var(--text-muted);">Komoditas</div>
        <div><span class="badge badge-{{ $stok->komoditas === 'Beras' ? 'blue' : 'amber' }}">{{ $stok->komoditas }}</span></div>

        <div style="font-weight:700; color:var(--text-muted);">Jumlah</div>
        <div><strong>{{ number_format($stok->jumlah) }} kg</strong></div>

        <div style="font-weight:700; color:var(--text-muted);">Saldo Setelah</div>
        <div><strong>{{ number_format($stok->jumlah_stok) }} kg</strong></div>

        <div style="font-weight:700; color:var(--text-muted);">Tujuan / Sumber</div>
        <div>{{ $stok->keterangan ?? '-' }}</div>

        <div style="font-weight:700; color:var(--text-muted);">Catatan</div>
        <div>{{ $stok->catatan ?? '-' }}</div>

        <div style="font-weight:700; color:var(--text-muted);">Dicatat Oleh</div>
        <div>{{ $stok->user?->name ?? '-' }}</div>

        <div style="font-weight:700; color:var(--text-muted);">ID Transaksi</div>
        <div>{{ $stok->id }}</div>

        <div style="font-weight:700; color:var(--text-muted);">Dibuat</div>
        <div>{{ $stok->created_at ? $stok->created_at->format('d M Y H:i') : '-' }}</div>

        <div style="font-weight:700; color:var(--text-muted);">Terakhir Diperbarui</div>
        <div>{{ $stok->updated_at ? $stok->updated_at->format('d M Y H:i') : '-' }}</div>
    </div>
</div>

@endsection
