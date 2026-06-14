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

        <div style="font-weight:700; color:var(--text-muted);">Foto Bukti</div>
        <div>
            @if(!empty($stok->foto_bukti))
                <button type="button" onclick="openDetailImageModal('{{ asset('storage/' . $stok->foto_bukti) }}')" style="border:none;background:transparent;padding:0;cursor:pointer;display:inline-block;">
                    <img src="{{ asset('storage/' . $stok->foto_bukti) }}" alt="Foto Bukti" style="max-width:220px;max-height:220px;object-fit:cover;border-radius:10px;border:1px solid #d1d5db;">
                </button>
                <div style="margin-top:8px;font-size:13px;color:var(--text-muted);">Klik gambar untuk melihat ukuran penuh tanpa meninggalkan halaman.</div>
            @else
                -
            @endif
        </div>

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

<div id="detailImageLightbox" onclick="closeDetailImageModal()" style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(15,23,42,0.8);backdrop-filter:blur(4px);align-items:center;justify-content:center;padding:16px;">
    <div onclick="event.stopPropagation()" style="position:relative;max-width:calc(90vw - 32px);max-height:calc(90vh - 32px);display:flex;align-items:center;justify-content:center;overflow:hidden;">
        <img id="detailImageFull" src="" alt="Foto Bukti" style="display:block;max-width:90vw!important;max-height:90vh!important;width:auto!important;height:auto!important;object-fit:contain;border-radius:12px;box-shadow:0 24px 60px rgba(0,0,0,0.5);position:relative;" />
        <button type="button" onclick="closeDetailImageModal()" style="position:absolute;top:16px;right:16px;border:none;background:rgba(255,255,255,0.92);border-radius:999px;width:36px;height:36px;cursor:pointer;display:flex;align-items:center;justify-content:center;">
            <span style="font-size:18px;font-weight:700;color:#111;">×</span>
        </button>
    </div>
</div>

<script>
function openDetailImageModal(src) {
    const overlay = document.getElementById('detailImageLightbox');
    const img = document.getElementById('detailImageFull');
    if (!overlay || !img) return;
    img.src = src;
    overlay.style.display = 'flex';
}
function closeDetailImageModal() {
    const overlay = document.getElementById('detailImageLightbox');
    const img = document.getElementById('detailImageFull');
    if (!overlay || !img) return;
    overlay.style.display = 'none';
    img.src = '';
}
</script>

@endsection
