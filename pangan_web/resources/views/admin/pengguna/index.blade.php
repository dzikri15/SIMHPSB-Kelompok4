@extends('layout.admin')

@section('title', 'Manajemen Pengguna')
@section('page-title', 'Manajemen Pengguna')
@section('page-subtitle', 'Kelola akun pengguna sistem')

@section('content')

@if(session('success'))
    <div class="alert-banner success" style="margin-bottom: 24px;">
        <i class="fas fa-check-circle"></i>
        <div>{{ session('success') }}</div>
    </div>
@endif

@if(session('error'))
    <div class="alert-banner danger" style="margin-bottom: 24px;">
        <i class="fas fa-exclamation-circle"></i>
        <div>{{ session('error') }}</div>
    </div>
@endif

<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Daftar Pengguna</div>
            <div class="card-subtitle">Semua pengguna terdaftar dalam sistem</div>
        </div>
        <a href="{{ route('admin.pengguna.create') }}" class="btn btn-primary btn-sm">
            <i class="fas fa-plus"></i> Tambah Pengguna
        </a>
    </div>

    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Nama</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Dibuat</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($users as $user)
                    <tr>
                        <td><strong>{{ $user->name }}</strong></td>
                        <td>{{ $user->email }}</td>
                        <td>
                            @if($user->role === 'admin')
                                <span class="badge badge-green">Admin</span>
                            @elseif($user->role === 'petugas')
                                <span class="badge badge-blue">Petugas</span>
                            @else
                                <span class="badge badge-gray">{{ ucfirst($user->role) }}</span>
                            @endif
                        </td>
                        <td>{{ $user->created_at->format('d M Y') }}</td>
                        <td style="display:flex; gap:8px; flex-wrap:wrap; align-items:center;">
                            <a href="{{ route('admin.pengguna.edit', $user->id) }}" class="btn btn-secondary btn-sm">
                                <i class="fas fa-edit"></i> Edit
                            </a>
                            <button type="button" class="btn btn-danger btn-sm" onclick="confirmDelete({{ $user->id }}, '{{ addslashes($user->name) }}')">
                                <i class="fas fa-trash"></i> Hapus
                            </button>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" class="text-center text-muted" style="padding: 24px;">Belum ada pengguna terdaftar.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<!-- Modal Konfirmasi Hapus -->
<div class="modal-overlay" id="modalHapus">
    <div class="modal" style="max-width: 400px; text-align: center;">
        <div style="font-size: 48px; color: var(--red-500); margin-bottom: 15px; margin-top: 15px;">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h3 style="margin-bottom: 10px;">Konfirmasi Hapus</h3>
        <p style="color: var(--text-muted); margin-bottom: 20px;">Apakah Anda yakin ingin menghapus akun pengguna <strong id="hapusNamaPengguna"></strong>? Tindakan ini tidak dapat dibatalkan.</p>
        
        <form method="POST" id="formHapusPengguna">
            @csrf @method('DELETE')
            <div style="display: flex; gap: 10px; justify-content: center; margin-bottom: 15px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalHapus')">Batal</button>
                <button type="submit" class="btn btn-danger">Ya, Hapus</button>
            </div>
        </form>
    </div>
</div>

@endsection

@push('scripts')
<script>
function confirmDelete(id, nama) {
    document.getElementById('hapusNamaPengguna').innerText = nama;
    const form = document.getElementById('formHapusPengguna');
    form.action = `{{ url('admin/pengguna') }}/${id}`;
    openModal('modalHapus');
}
</script>
@endpush
