@extends('layout.admin')

@section('title', 'Detail Catatan Panen')
@section('page-title', 'Detail Catatan Panen')
@section('page-subtitle', 'Informasi lengkap hasil panen petani')

@section('content')

@php
    $penghasilan = ($panen->harga_gabah_per_kg > 0)
        ? $panen->jumlah_gabah * $panen->harga_gabah_per_kg
        : null;
@endphp

<div class="card">
    <div style="margin-bottom:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
        <a href="{{ route('admin.panen.index') }}" class="btn btn-secondary btn-sm">
            ← Kembali ke Pencatatan Panen
        </a>
        <a href="{{ route('admin.panen.edit', $panen->id) }}" class="btn btn-primary btn-sm">
            <i class="fas fa-edit"></i> Edit
        </a>
    </div>

    <div style="display:grid; grid-template-columns:220px 1fr; gap:18px; align-items:start;">

        <div style="font-weight:700; color:var(--text-muted);">Petani</div>
        <div><strong>{{ $panen->lahan->petani->nama ?? '-' }}</strong></div>

        <div style="font-weight:700; color:var(--text-muted);">Musim Tanam</div>
        <div><span class="badge badge-green">{{ $panen->musim ?? '-' }}</span></div>

        <div style="font-weight:700; color:var(--text-muted);">Tanggal Panen</div>
        <div>{{ optional($panen->tanggal_panen)->format('d M Y') ?? '-' }}</div>

        <div style="font-weight:700; color:var(--text-muted);">Hasil Gabah</div>
        <div><strong>{{ number_format($panen->jumlah_gabah) }} kg</strong></div>

        <div style="font-weight:700; color:var(--text-muted);">Harga Beli Gabah (saat itu)</div>
        <div>
            @if($panen->harga_gabah_per_kg > 0)
                Rp {{ number_format($panen->harga_gabah_per_kg, 0, ',', '.') }} / kg
            @else
                <span style="color:var(--text-muted);">-</span>
            @endif
        </div>

        <div style="font-weight:700; color:var(--text-muted);">Penghasilan</div>
        <div>
            @if($penghasilan !== null)
                <strong style="color:var(--green-700);font-size:17px;">
                    Rp {{ number_format($penghasilan, 0, ',', '.') }}
                </strong>
                <div style="font-size:12px;color:var(--text-muted);margin-top:2px;">
                    {{ number_format($panen->jumlah_gabah) }} kg × Rp {{ number_format($panen->harga_gabah_per_kg, 0, ',', '.') }}
                </div>
            @else
                <span style="color:var(--text-muted);">-</span>
            @endif
        </div>

        <div style="font-weight:700; color:var(--text-muted);">Catatan</div>
        <div>{{ $panen->catatan ?: '-' }}</div>

        <div style="font-weight:700; color:var(--text-muted);">Foto Bukti Transaksi</div>
        <div>
            @if(!empty($panen->foto_bukti))
                <button type="button" onclick="openDetailImageModal('{{ asset('storage/' . $panen->foto_bukti) }}')"
                    style="border:none;background:transparent;padding:0;cursor:pointer;display:inline-block;">
                    <img src="{{ asset('storage/' . $panen->foto_bukti) }}" alt="Foto Bukti"
                        style="max-width:220px;max-height:220px;object-fit:cover;border-radius:10px;border:1px solid #d1d5db;transition:transform .2s;"
                        onmouseover="this.style.transform='scale(1.03)'"
                        onmouseout="this.style.transform='scale(1)'">
                </button>
                <div style="margin-top:8px;font-size:13px;color:var(--text-muted);">Klik gambar untuk melihat ukuran penuh.</div>
            @else
                <span style="color:var(--text-muted);">Tidak ada foto</span>
            @endif
        </div>

        <div style="font-weight:700; color:var(--text-muted);">ID Panen</div>
        <div>{{ $panen->id }}</div>

        <div style="font-weight:700; color:var(--text-muted);">Dicatat Pada</div>
        <div>{{ $panen->created_at ? $panen->created_at->format('d M Y H:i') : '-' }}</div>

        <div style="font-weight:700; color:var(--text-muted);">Terakhir Diperbarui</div>
        <div>{{ $panen->updated_at ? $panen->updated_at->format('d M Y H:i') : '-' }}</div>

    </div>
</div>

{{-- LIGHTBOX --}}
<div id="detailImageLightbox" onclick="closeDetailImageModal()"
    style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(15,23,42,0.85);backdrop-filter:blur(4px);align-items:center;justify-content:center;padding:16px;">
    <div onclick="event.stopPropagation()"
        style="position:relative;max-width:calc(90vw - 32px);max-height:calc(90vh - 32px);display:flex;align-items:center;justify-content:center;">
        <img id="detailImageFull" src="" alt="Foto Bukti Panen"
            style="display:block;max-width:90vw;max-height:90vh;width:auto;height:auto;object-fit:contain;border-radius:12px;box-shadow:0 24px 60px rgba(0,0,0,0.5);">
        <button type="button" onclick="closeDetailImageModal()"
            style="position:absolute;top:-14px;right:-14px;border:none;background:rgba(255,255,255,0.92);border-radius:999px;width:36px;height:36px;cursor:pointer;display:flex;align-items:center;justify-content:center;box-shadow:0 2px 8px rgba(0,0,0,0.2);">
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
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeDetailImageModal();
});
</script>

@endsection
