@extends('layout.admin')

@section('title', 'Edit Petani')
@section('page-title', 'Edit Data Petani')

@section('content')

<div class="card">
    @php
        $totalLahan = $petani->lahan->count();
    @endphp

    <div class="card-header">
        <div>
            <div class="card-title">Edit Data Petani</div>
            <div class="card-subtitle">Perbarui informasi petani dengan cepat dan akurat</div>
        </div>
        <div style="display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
            <a href="{{ route('admin.petani.index') }}" class="btn btn-secondary btn-sm">
                ↩️ Kembali
            </a>
            <a href="{{ route('admin.petani.show', $petani) }}" class="btn btn-secondary btn-sm">
                👁️ Lihat Detail
            </a>
        </div>
    </div>

    <div class="card-body">
        @if ($errors->any())
            <div style="background-color:#f8d7da; border:1px solid #f5c6cb; color:#721c24; padding:12px; border-radius:4px; margin-bottom:15px;">
                <strong>Error Validasi:</strong>
                <ul style="margin:8px 0 0 20px;">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <div class="stat-grid" style="margin-bottom:24px;">
            <div class="stat-card green">
                <div class="stat-icon">📦</div>
                <div class="stat-value">{{ $totalLahan }}</div>
                <div class="stat-label">Jumlah Lahan</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-icon">🔖</div>
                <div class="stat-value">{{ ucfirst($petani->status) }}</div>
                <div class="stat-label">Status</div>
            </div>
            <div class="stat-card amber">
                <div class="stat-icon"><img src="https://raw.githubusercontent.com/NoahMikhailovna/foto/c45c72f9adca95001eefebd49d7581e89d0de508/padi_logo_fitted.svg" alt="Komoditas" style="width:100%;height:100%;object-fit:contain;"></div>
                <div class="stat-value">{{ $petani->komoditas ?? '-' }}</div>
                <div class="stat-label">Komoditas Utama</div>
            </div>
        </div>

        <form action="{{ route('admin.petani.update', $petani) }}" method="POST">
        @csrf
        @method('PUT')

        <div style="margin-bottom:15px;">
            <label for="nama" style="display:block; margin-bottom:5px; font-weight:bold;">Nama Petani <span style="color:red;">*</span></label>
            <input type="text" name="nama" id="nama" value="{{ old('nama', $petani->nama) }}" required style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
            @error('nama')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
        </div>

        <div style="margin-bottom:15px;">
            <label for="alamat" style="display:block; margin-bottom:5px; font-weight:bold;">Alamat <span style="color:red;">*</span></label>
            <textarea name="alamat" id="alamat" rows="3" required style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">{{ old('alamat', $petani->alamat) }}</textarea>
            @error('alamat')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px; margin-bottom:15px;">
            <div>
                <label for="telepon" style="display:block; margin-bottom:5px; font-weight:bold;">No. Telepon/HP</label>
                <input type="text" name="telepon" id="telepon" value="{{ old('telepon', $petani->telepon) }}" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                @error('telepon')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>

            <div>
                <label for="email" style="display:block; margin-bottom:5px; font-weight:bold;">Email</label>
                <input type="email" name="email" id="email" value="{{ old('email', $petani->email) }}" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                @error('email')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px; margin-bottom:15px;">
            <div>
                <label for="luas_lahan" style="display:block; margin-bottom:5px; font-weight:bold;">Luas Lahan (m²)</label>
                <input type="number" name="luas_lahan" id="luas_lahan" value="{{ old('luas_lahan', $petani->luas_lahan) }}" min="0" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                @error('luas_lahan')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>

            <div>
                <label for="komoditas" style="display:block; margin-bottom:5px; font-weight:bold;">Komoditas Utama</label>
                <input type="text" name="komoditas" id="komoditas" value="Padi" readonly style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px; background-color:#f3f4f6; cursor:not-allowed;">
                @error('komoditas')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>
        </div>

        <div style="margin-bottom:15px;">
            <label for="status" style="display:block; margin-bottom:5px; font-weight:bold;">Status</label>
            <select name="status" id="status" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                <option value="aktif" {{ old('status', $petani->status) === 'aktif' ? 'selected' : '' }}>Aktif</option>
                <option value="nonaktif" {{ old('status', $petani->status) === 'nonaktif' ? 'selected' : '' }}>Non-aktif</option>
            </select>
            @error('status')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
        </div>

        <div style="display:flex; gap:12px; flex-wrap:wrap; margin-top:20px;">
            <button type="submit" class="btn btn-primary btn-sm" style="min-width:140px;">
                <span>💾</span>
                <span>Update Petani</span>
            </button>
            <a href="{{ route('admin.petani.index') }}" class="btn btn-secondary btn-sm" style="min-width:120px;">
                <span>✖️</span>
                <span>Batal</span>
            </a>
        </div>
    </form>
    </div>
</div>

@endsection
