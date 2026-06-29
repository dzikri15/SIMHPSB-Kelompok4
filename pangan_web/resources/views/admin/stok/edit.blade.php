@extends('layout.admin')

@section('title', 'Edit Transaksi Stok')
@section('page-title', 'Edit Transaksi Stok')
@section('page-subtitle', 'Perbarui data transaksi stok gudang')

@section('content')

@if ($errors->any())
    <div class="alert-banner danger" style="margin-bottom:24px;">
        <i class="fas fa-exclamation-circle"></i>
        <div>
            <strong>Perbaiki kesalahan berikut:</strong>
            <ul style="margin:8px 0 0 16px;">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    </div>
@endif

@if(session('success'))
    <div class="alert-banner success" style="margin-bottom:24px;">
        <i class="fas fa-check-circle"></i> {{ session('success') }}
    </div>
@endif

<div style="max-width:640px;margin:0 auto;">
    <div class="card">
        <div class="card-header">
            <div>
                <div class="card-title">Edit Transaksi #{{ $stok->id }}</div>
                <div class="card-subtitle">Perubahan jumlah akan otomatis recalculate saldo</div>
            </div>
        </div>
        <div class="card-body">
            <form method="POST" action="{{ route('admin.stok.update', $stok->id) }}" enctype="multipart/form-data">
                @csrf
                @method('PUT')

                {{-- Jenis Transaksi --}}
                <div class="form-group">
                    <label>Jenis Transaksi <span style="color:var(--red-500)">*</span></label>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                        <label style="display:flex;align-items:center;gap:10px;padding:12px;border:2px solid var(--border,#e2e8f0);border-radius:10px;cursor:pointer;background:var(--surface-2);"
                               id="labelMasuk">
                            <input type="radio" name="jenis_transaksi" value="masuk"
                                   {{ old('jenis_transaksi', $stok->jenis_transaksi) == 'masuk' ? 'checked' : '' }}
                                   onchange="updateJenisStyle()">
                            <span><i class="fas fa-arrow-down" style="color:var(--green-500);"></i> Masuk</span>
                        </label>
                        <label style="display:flex;align-items:center;gap:10px;padding:12px;border:2px solid var(--border,#e2e8f0);border-radius:10px;cursor:pointer;background:var(--surface-2);"
                               id="labelKeluar">
                            <input type="radio" name="jenis_transaksi" value="keluar"
                                   {{ old('jenis_transaksi', $stok->jenis_transaksi) == 'keluar' ? 'checked' : '' }}
                                   onchange="updateJenisStyle()">
                            <span><i class="fas fa-arrow-up" style="color:var(--red-500);"></i> Keluar</span>
                        </label>
                    </div>
                    @error('jenis_transaksi')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Komoditas --}}
                <div class="form-group">
                    <label>Komoditas <span style="color:var(--red-500)">*</span></label>
                    <select name="komoditas" required>
                        <option value="Beras" {{ old('komoditas', $stok->komoditas) == 'Beras' ? 'selected' : '' }}>Beras</option>
                        <option value="Gabah" {{ old('komoditas', $stok->komoditas) == 'Gabah' ? 'selected' : '' }}>Gabah</option>
                    </select>
                    @error('komoditas')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Jumlah --}}
                <div class="form-group">
                    <label>Jumlah (kg) <span style="color:var(--red-500)">*</span></label>
                    <input type="number" name="jumlah"
                           value="{{ old('jumlah', $stok->jumlah) }}"
                           step="0.01" min="0.01" required>
                    @error('jumlah')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Tanggal --}}
                <div class="form-group">
                    <label>Tanggal & Waktu <span style="color:var(--red-500)">*</span></label>
                    <input type="datetime-local" name="tanggal_update"
                           value="{{ old('tanggal_update', \Carbon\Carbon::parse($stok->tanggal_update ?? $stok->created_at)->format('Y-m-d\TH:i')) }}"
                           required>
                    @error('tanggal_update')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Keterangan --}}
                <div class="form-group">
                    <label>Tujuan / Sumber</label>
                    <input type="text" name="keterangan"
                           value="{{ old('keterangan', $stok->keterangan) }}"
                           placeholder="Contoh: Petani Budi, MBG Dapur 1...">
                    @error('keterangan')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Catatan --}}
                <div class="form-group">
                    <label>Catatan</label>
                    <textarea name="catatan" rows="2"
                              placeholder="Catatan tambahan (opsional)">{{ old('catatan', $stok->catatan) }}</textarea>
                    @error('catatan')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Foto Bukti --}}
                <div class="form-group">
                    <label>Foto Bukti</label>
                    @if(!empty($stok->foto_bukti))
                        <div style="margin-bottom:10px;">
                            <img src="{{ asset('storage/' . $stok->foto_bukti) }}"
                                 style="width:80px;height:80px;object-fit:cover;border-radius:8px;border:1px solid var(--border,#e2e8f0);"
                                 alt="Foto Bukti">
                            <div style="font-size:11px;color:var(--text-muted);margin-top:4px;">Foto saat ini (upload baru untuk mengganti)</div>
                        </div>
                    @endif
                    <input type="file" name="foto_bukti" accept="image/jpeg,image/jpg,image/png,image/webp">
                    @error('foto_bukti')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Info recalculate --}}
                <div style="background:var(--surface-3);border:1px solid var(--border,#e2e8f0);border-radius:10px;padding:14px;margin-bottom:20px;">
                    <div style="font-size:12px;color:var(--text-muted);display:flex;align-items:center;gap:8px;">
                        <i class="fas fa-info-circle" style="color:var(--green-500);"></i>
                        Setelah disimpan, saldo stok untuk komoditas ini akan dihitung ulang secara otomatis.
                    </div>
                </div>

                {{-- Actions --}}
                <div style="display:flex;gap:12px;">
                    <a href="{{ route('admin.stok.index') }}"
                       style="flex:1;display:inline-flex;align-items:center;justify-content:center;gap:8px;padding:12px;background:var(--surface-3);color:var(--text-primary);border:1px solid var(--border,#e2e8f0);border-radius:10px;text-decoration:none;font-weight:600;">
                        <i class="fas fa-arrow-left"></i> Batal
                    </a>
                    <button type="submit"
                            style="flex:2;display:inline-flex;align-items:center;justify-content:center;gap:8px;padding:12px;background:var(--green-600);color:white;border:none;border-radius:10px;font-weight:700;cursor:pointer;font-size:15px;">
                        <i class="fas fa-save"></i> Simpan Perubahan
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<script>
function updateJenisStyle() {
    const masuk  = document.querySelector('input[value="masuk"]');
    const keluar = document.querySelector('input[value="keluar"]');
    const lMasuk  = document.getElementById('labelMasuk');
    const lKeluar = document.getElementById('labelKeluar');
    if (masuk.checked) {
        lMasuk.style.borderColor  = 'var(--green-500)';
        lKeluar.style.borderColor = 'var(--border, #e2e8f0)';
    } else {
        lKeluar.style.borderColor = 'var(--red-500)';
        lMasuk.style.borderColor  = 'var(--border, #e2e8f0)';
    }
}
document.addEventListener('DOMContentLoaded', updateJenisStyle);
</script>
@endpush