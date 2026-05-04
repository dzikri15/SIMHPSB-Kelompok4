@extends('layout.admin')

@section('title', 'Pengaturan Sistem')
@section('page-title', 'Pengaturan Sistem')
@section('page-subtitle', 'Konfigurasi aplikasi dan preferensi sistem')

@section('content')

<div class="grid-2">
    <div class="card">
        <div class="card-header">
            <div class="card-title">Informasi Sistem</div>
        </div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:14px;">
                <div>
                    <label style="display:block;margin-bottom:6px;font-weight:600;font-size:12.5px;color:var(--text-muted);">Nama Sistem</label>
                    <input type="text" value="SIMHPSB" disabled>
                </div>
                <div>
                    <label style="display:block;margin-bottom:6px;font-weight:600;font-size:12.5px;color:var(--text-muted);">Versi</label>
                    <input type="text" value="v1.2" disabled>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div class="card-title">Pengaturan Umum</div>
        </div>
        <div class="card-body">
            <form method="POST" action="{{ route('admin.pengaturan.update') }}">
                @csrf @method('PUT')
                <div class="form-group">
                    <label>Nama Organisasi</label>
                    <input type="text" name="org_name" value="Kelompok Tani Makmur" required>
                </div>
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Simpan Pengaturan</button>
            </form>
        </div>
    </div>
</div>

@endsection
