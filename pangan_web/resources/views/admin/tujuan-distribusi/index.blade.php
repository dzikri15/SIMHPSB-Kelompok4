@extends('layout.admin')

@section('title', 'Tujuan Distribusi')
@section('page-title', 'Manajemen Tujuan Distribusi')
@section('page-subtitle', 'Tambah/hapus tujuan distribusi yang digunakan pada pencatatan stok')

@section('content')

@if ($errors->any())
    <div class="alert-banner danger" style="margin-bottom:20px;">
        <i class="fas fa-exclamation-circle"></i>
        <div>{{ $errors->first() }}</div>
    </div>
@endif

@if(session('success'))
    <div class="alert-banner success" style="margin-bottom:20px;">
        <i class="fas fa-check-circle"></i>
        <div>{{ session('success') }}</div>
    </div>
@endif

<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Daftar Tujuan Distribusi</div>
            <div class="card-subtitle">Semua tujuan yang tersedia untuk transaksi keluar</div>
        </div>
        <button class="btn btn-primary" onclick="openModal('modalTambahTujuan')"><i class="fas fa-plus"></i> Tambah Tujuan</button>
    </div>
    <div class="card-body">
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Nama Tujuan</th>
                        <th>Dibuat</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse(($tujuans ?? []) as $i => $t)
                        <tr>
                            <td style="color:var(--text-muted);font-size:12px;">{{ $i+1 }}</td>
                            <td>{{ $t->nama }}</td>
                            <td style="font-size:12px;color:var(--text-muted);">{{ $t->created_at?->format('Y-m-d') ?? '-' }}</td>
                            <td>
                                <form method="POST" action="{{ route('tujuan-distribusi.destroy', $t->id) }}" onsubmit="return false;" class="inline-form">
                                    @csrf
                                    @method('DELETE')
                                    <button type="button" class="btn btn-danger btn-sm" onclick="confirmDelete({{ $t->id }}, '{{ addslashes($t->nama) }}')">
                                        <i class="fas fa-trash"></i> Hapus
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" style="text-align:center;padding:28px;color:var(--text-muted);">Belum ada tujuan distribusi</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>

{{-- MODAL TAMBAH --}}
<div class="modal-overlay" id="modalTambahTujuan">
    <div class="modal">
        <div class="modal-header">
            <div class="modal-title">Tambah Tujuan Distribusi</div>
            <button class="modal-close" onclick="closeModal('modalTambahTujuan')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="{{ route('tujuan-distribusi.store') }}">
        <form method="POST" action="{{ route('admin.tujuan-distribusi.store') }}">
            @csrf
            <div class="modal-body">
                <div class="form-group">
                    <label>Nama Tujuan</label>
                    <input type="text" name="nama" required placeholder="Contoh: Pasar Kota A">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalTambahTujuan')">Batal</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Simpan</button>
            </div>
                                <form method="POST" action="{{ route('admin.tujuan-distribusi.destroy', $t->id) }}" onsubmit="return false;" class="inline-form">
    </div>
</div>

{{-- MODAL KONFIRM HAPUS --}}
<div class="modal-overlay" id="modalHapusTujuan">
    <div class="modal">
        <div class="modal-header">
            <div class="modal-title">Hapus Tujuan</div>
            <button class="modal-close" onclick="closeModal('modalHapusTujuan')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" id="formHapusTujuan" action="">
            @csrf
            @method('DELETE')
            <div class="modal-body">
                <div class="alert-banner warning">
                    <i class="fas fa-exclamation-triangle"></i>
                    <div id="hapusMsg">Anda yakin ingin menghapus tujuan ini?</div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalHapusTujuan')">Batal</button>
                <button type="submit" class="btn btn-danger"><i class="fas fa-trash"></i> Hapus</button>
            </div>
        </form>
    </div>
</div>

@endsection

@push('scripts')
<script>
function confirmDelete(id, name) {
    const form = document.getElementById('formHapusTujuan');
    form.action = `{{ url('admin/tujuan-distribusi') }}/${id}`;
    document.getElementById('hapusMsg').textContent = `Hapus tujuan: "${name}" ? Jika tujuan ini sudah digunakan di transaksi, penghapusan akan diblokir.`;
    openModal('modalHapusTujuan');
}
</script>
@endpush
