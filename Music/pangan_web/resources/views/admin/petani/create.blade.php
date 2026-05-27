@extends('layout.admin')

@section('title', 'Tambah Petani')
@section('page-title', 'Tambah Petani Baru')

@section('content')

<div class="card">
    <div style="margin-bottom:20px;">
        <a href="{{ route('admin.petani.index') }}" style="color:#0066cc; text-decoration:none;">← Kembali ke Data Petani</a>
    </div>

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

    <form action="{{ route('admin.petani.store') }}" method="POST">
        @csrf

        <div style="margin-bottom:15px;">
            <label for="nama" style="display:block; margin-bottom:5px; font-weight:bold;">Nama Petani <span style="color:red;">*</span></label>
            <input type="text" name="nama" id="nama" value="{{ old('nama') }}" required style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
            @error('nama')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
        </div>

        <div style="margin-bottom:15px;">
            <label for="alamat" style="display:block; margin-bottom:5px; font-weight:bold;">Alamat <span style="color:red;">*</span></label>
            <textarea name="alamat" id="alamat" rows="3" required style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">{{ old('alamat') }}</textarea>
            @error('alamat')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px; margin-bottom:15px;">
            <div>
                <label for="nik" style="display:block; margin-bottom:5px; font-weight:bold;">NIK</label>
                <input type="text" name="nik" id="nik" value="{{ old('nik') }}" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                @error('nik')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>

            <div>
                <label for="telepon" style="display:block; margin-bottom:5px; font-weight:bold;">No. Telepon</label>
                <input type="text" name="telepon" id="telepon" value="{{ old('telepon') }}" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                @error('telepon')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px; margin-bottom:15px;">
            <div>
                <label for="luas_lahan" style="display:block; margin-bottom:5px; font-weight:bold;">Luas Lahan (m²)</label>
                <input type="number" name="luas_lahan" id="luas_lahan" value="{{ old('luas_lahan') }}" min="0" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                @error('luas_lahan')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>

            <div>
                <label for="komoditas" style="display:block; margin-bottom:5px; font-weight:bold;">Komoditas Utama</label>
                <select name="komoditas" id="komoditas" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                    <option value="">Pilih komoditas</option>
                    <option value="Padi" {{ old('komoditas') === 'Padi' ? 'selected' : '' }}>Padi</option>
                    <option value="Jagung" {{ old('komoditas') === 'Jagung' ? 'selected' : '' }}>Jagung</option>
                    <option value="Padi & Jagung" {{ old('komoditas') === 'Padi & Jagung' ? 'selected' : '' }}>Padi & Jagung</option>
                </select>
                @error('komoditas')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px; margin-bottom:15px;">
            <div>
                <label for="no_hp" style="display:block; margin-bottom:5px; font-weight:bold;">No HP</label>
                <input type="text" name="no_hp" id="no_hp" value="{{ old('no_hp') }}" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                @error('no_hp')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>

            <div>
                <label for="email" style="display:block; margin-bottom:5px; font-weight:bold;">Email</label>
                <input type="email" name="email" id="email" value="{{ old('email') }}" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                @error('email')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px; margin-bottom:15px;">
            <div>
                <label for="tanggal_lahir" style="display:block; margin-bottom:5px; font-weight:bold;">Tanggal Lahir</label>
                <input type="date" name="tanggal_lahir" id="tanggal_lahir" value="{{ old('tanggal_lahir') }}" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                @error('tanggal_lahir')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>

            <div>
                <label for="status" style="display:block; margin-bottom:5px; font-weight:bold;">Status</label>
                <select name="status" id="status" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
                    <option value="aktif" {{ old('status') === 'aktif' ? 'selected' : '' }}>Aktif</option>
                    <option value="nonaktif" {{ old('status') === 'nonaktif' ? 'selected' : '' }}>Non-aktif</option>
                </select>
                @error('status')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
            </div>
        </div>

        <div style="margin-bottom:15px;">
            <label for="catatan" style="display:block; margin-bottom:5px; font-weight:bold;">Catatan</label>
            <textarea name="catatan" id="catatan" rows="3" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">{{ old('catatan') }}</textarea>
            @error('catatan')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
        </div>

        <div style="display:flex; gap:10px; margin-top:20px;">
            <button type="submit" style="background-color:#28a745; color:white; padding:10px 20px; border:none; border-radius:4px; cursor:pointer; font-weight:bold;">
                💾 Simpan
            </button>
            <a href="{{ route('admin.petani.index') }}" style="background-color:#6c757d; color:white; padding:10px 20px; border-radius:4px; text-decoration:none; display:inline-block;">
                Batal
            </a>
        </div>
    </form>
</div>

@endsection
