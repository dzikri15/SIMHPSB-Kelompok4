@extends('layout.admin')

@section('title', 'Edit Pengguna')
@section('page-title', 'Edit Pengguna')
@section('page-subtitle', 'Perbarui informasi pengguna')

@section('content')

<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Form Edit Pengguna</div>
            <div class="card-subtitle">Ubah data pengguna: {{ $user->name }}</div>
        </div>
        <a href="{{ route('admin.pengguna.index') }}" class="btn btn-secondary btn-sm" title="Kembali">
            <i class="fas fa-arrow-left"></i> Kembali
        </a>
    </div>

    <div class="card-body">
        <form method="POST" action="{{ route('admin.pengguna.update', $user->id) }}">
            @csrf
            @method('PUT')
            
            <div class="grid-2">
                <div class="form-group">
                    <label>Nama Lengkap <span style="color:var(--red-500)">*</span></label>
                    <input type="text" name="name" value="{{ old('name', $user->name) }}" placeholder="Contoh: Budi Santoso" required>
                    @error('name')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>

                <div class="form-group">
                    <label>Email <span style="color:var(--red-500)">*</span></label>
                    <input type="email" name="email" value="{{ old('email', $user->email) }}" placeholder="contoh@email.com" required>
                    @error('email')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label>Role <span style="color:var(--red-500)">*</span></label>
                    <select name="role" id="roleSelect" required onchange="togglePetaniField()">
                        <option value="admin" @selected(old('role', $user->role) === 'admin')>Admin</option>
                        <option value="petugas" @selected(old('role', $user->role) === 'petugas')>Petugas</option>
                        <option value="petani" @selected(old('role', $user->role) === 'petani')>Petani</option>
                    </select>
                    @error('role')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>

                <div class="form-group" id="petaniField" style="display: {{ old('role', $user->role) === 'petani' ? 'block' : 'none' }};">
                    <label>Pilih Petani Terhubung <span style="color:var(--red-500)">*</span></label>
                    <select name="petani_id" id="petaniSelect" {{ old('role', $user->role) === 'petani' ? '' : 'disabled' }}>
                        <option value="">Pilih petani terhubung</option>
                        @foreach($petaniList as $petani)
                            <option value="{{ $petani->id }}" @selected(old('petani_id', $user->petani_id) == $petani->id)>{{ $petani->nama }} – {{ number_format($petani->luas_lahan ?: 0) }} m²</option>
                        @endforeach
                    </select>
                    @error('petani_id')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>
            </div>

            <div class="alert-banner info" style="margin-top: 12px; margin-bottom: 20px;">
                <i class="fas fa-lock"></i>
                <div><strong>Ubah Password</strong> - Isi field password di bawah hanya jika ingin mengubah password pengguna</div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label>Password Baru (Opsional)</label>
                    <input type="password" id="passwordInput" name="password" placeholder="Biarkan kosong jika tidak ingin mengubah" onchange="togglePasswordConfirm()">
                    <div class="form-hint">Minimal 8 karakter</div>
                    @error('password')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>

                <div class="form-group" id="confirmGroup" style="display: none;">
                    <label>Konfirmasi Password Baru <span style="color:var(--red-500)">*</span></label>
                    <input type="password" name="password_confirmation" placeholder="Ulangi password baru">
                </div>
            </div>

            <div style="display: flex; gap: 12px; margin-top: 24px;">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Simpan Perubahan
                </button>
                <a href="{{ route('admin.pengguna.index') }}" class="btn btn-secondary">
                    <i class="fas fa-times"></i> Batal
                </a>
            </div>
        </form>
    </div>
</div>

<script>
    function togglePasswordConfirm() {
        const passwordInput = document.getElementById('passwordInput');
        const confirmGroup = document.getElementById('confirmGroup');
        if (passwordInput.value.length > 0) {
            confirmGroup.style.display = 'block';
        } else {
            confirmGroup.style.display = 'none';
        }
    }
    function togglePetaniField() {
        const roleSelect = document.getElementById('roleSelect');
        const petaniField = document.getElementById('petaniField');
        const petaniSelect = document.getElementById('petaniSelect');

        if (roleSelect.value === 'petani') {
            petaniField.style.display = 'block';
            petaniSelect.disabled = false;
        } else {
            petaniField.style.display = 'none';
            petaniSelect.disabled = true;
            petaniSelect.value = '';
        }
    }

    document.addEventListener('DOMContentLoaded', togglePetaniField);
</script>

@endsection
