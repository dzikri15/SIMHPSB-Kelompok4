@extends('layout.admin')

@section('title', 'Tambah Pengguna')
@section('page-title', 'Tambah Pengguna Baru')
@section('page-subtitle', 'Buat akun pengguna baru di sistem')

@section('content')

{{-- PASSWORD VISIBILITY MODAL --}}
@if(session('user_created'))
<div class="modal-overlay" id="modalPasswordBaru" style="opacity: 1; pointer-events: auto;">
    <div class="modal" style="transform: scale(1) translateY(0);">
        <div class="modal-header">
            <div class="modal-title">Password Pengguna Baru</div>
            <a href="{{ route('admin.pengguna.index') }}" class="modal-close" title="Tutup">
                <i class="fas fa-times"></i>
            </a>
        </div>
        <div class="modal-body">
            <div class="alert-banner success" style="margin-bottom: 24px;">
                <i class="fas fa-check-circle"></i>
                <div><strong>Pengguna berhasil dibuat!</strong> Catat password di bawah ini sebelum menutup modal.</div>
            </div>

            <div style="background: var(--surface-3); padding: 16px; border-radius: 8px; margin-bottom: 16px;">
                <div style="margin-bottom: 12px;">
                    <strong>Nama Pengguna</strong><br>
                    {{ session('user_name') }}
                </div>
                <div style="margin-bottom: 12px;">
                    <strong>Email</strong><br>
                    {{ session('user_email') }}
                </div>
                <div style="background: white; padding: 12px; border-radius: 6px; border: 2px solid var(--amber-500);">
                    <strong style="color: var(--amber-500);">Password</strong><br>
                    <code id="passwordText" style="font-size: 16px; font-weight: 700; color: var(--green-600); word-break: break-all;">{{ session('user_password') }}</code>
                    <button type="button" class="btn btn-secondary btn-sm" style="margin-top: 8px;" onclick="copyPassword()">
                        <i class="fas fa-copy"></i> Salin
                    </button>
                </div>
            </div>

            <div class="alert-banner warning">
                <i class="fas fa-exclamation-triangle"></i>
                <div><strong>PENTING!</strong> Password ini hanya ditampilkan satu kali. Pastikan untuk menyalinnya sebelum menutup modal. Jangan bagikan password melalui chat atau email tidak aman.</div>
            </div>
        </div>
        <div class="modal-footer">
            <a href="{{ route('admin.pengguna.index') }}" class="btn btn-primary">
                <i class="fas fa-check"></i> Saya Sudah Menyalin Password
            </a>
        </div>
    </div>
</div>

<script>
    function copyPassword() {
        const passwordText = document.getElementById('passwordText').textContent;
        navigator.clipboard.writeText(passwordText).then(() => {
            alert('Password berhasil disalin ke clipboard');
        });
    }
</script>
@endif

<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Form Tambah Pengguna</div>
            <div class="card-subtitle">Isi formulir di bawah untuk membuat pengguna baru</div>
        </div>
        <a href="{{ route('admin.pengguna.index') }}" class="btn btn-secondary btn-sm" title="Kembali">
            <i class="fas fa-arrow-left"></i> Kembali
        </a>
    </div>

    <div class="card-body">
        <form method="POST" action="{{ route('admin.pengguna.store') }}">
            @csrf
            
            <div class="grid-2">
                <div class="form-group">
                    <label>Nama Lengkap <span style="color:var(--red-500)">*</span></label>
                    <input type="text" name="name" value="{{ old('name') }}" placeholder="Contoh: Budi Santoso" required>
                    @error('name')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>

                <div class="form-group">
                    <label>Email <span style="color:var(--red-500)">*</span></label>
                    <input type="email" name="email" value="{{ old('email') }}" placeholder="contoh@email.com" required>
                    @error('email')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label>Role <span style="color:var(--red-500)">*</span></label>
                    <select name="role" id="roleSelect" required onchange="togglePetaniField()">
                        <option value="">Pilih role</option>
                        <option value="admin" @selected(old('role') === 'admin')>Admin</option>
                        <option value="petugas" @selected(old('role') === 'petugas')>Petugas</option>
                        <option value="petani" @selected(old('role') === 'petani')>Petani</option>
                    </select>
                    @error('role')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>

                <div class="form-group" id="petaniField" style="display: {{ old('role') === 'petani' ? 'block' : 'none' }};">
                    <label>Pilih Petani Terhubung <span style="color:var(--red-500)">*</span></label>
                    <select name="petani_id" id="petaniSelect" {{ old('role') === 'petani' ? '' : 'disabled' }}>
                        <option value="">Pilih petani terhubung</option>
                        @foreach($petaniList as $petani)
                            <option value="{{ $petani->id }}" @selected(old('petani_id') == $petani->id)>{{ $petani->nama }} – {{ number_format($petani->luas_lahan ?: 0) }} m²</option>
                        @endforeach
                    </select>
                    @error('petani_id')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label>Password <span style="color:var(--red-500)">*</span></label>
                    <input type="password" name="password" placeholder="Minimal 8 karakter" required>
                    @error('password')
                        <small style="color: var(--red-500);">{{ $message }}</small>
                    @enderror
                </div>

                <div class="form-group">
                    <label>Konfirmasi Password <span style="color:var(--red-500)">*</span></label>
                    <input type="password" name="password_confirmation" placeholder="Ulangi password" required>
                </div>
            </div>

            <div class="alert-banner info">
                <i class="fas fa-info-circle"></i>
                <div>Password akan ditampilkan setelah pengguna berhasil dibuat. Pastikan untuk menyalinnya karena tidak akan ditampilkan lagi.</div>
            </div>

            <div style="display: flex; gap: 12px; margin-top: 24px;">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Simpan Pengguna
                </button>
                <a href="{{ route('admin.pengguna.index') }}" class="btn btn-secondary">
                    <i class="fas fa-times"></i> Batal
                </a>
            </div>
        </form>
    </div>
</div>

<script>
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
