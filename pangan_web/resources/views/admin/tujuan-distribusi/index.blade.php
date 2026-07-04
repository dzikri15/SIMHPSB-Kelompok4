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

@if(session('error'))
    <div class="alert-banner danger" style="margin-bottom:20px;">
        <i class="fas fa-times-circle"></i>
        <div>{{ session('error') }}</div>
    </div>
@endif

{{-- STAT CARDS --}}
<div class="stat-grid" style="margin-bottom:24px;">
    <div class="stat-card green animate-in">
        <div class="stat-icon"><i class="fas fa-location-dot"></i></div>
        <div class="stat-value">{{ $totalTujuan }}</div>
        <div class="stat-label">Total Tujuan</div>
        <div class="stat-change up"><i class="fas fa-map-marker-alt"></i> Lokasi terdaftar</div>
    </div>
    <div class="stat-card amber animate-in">
        <div class="stat-icon"><i class="fas fa-trophy"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ $tujuanTerbanyak }}</div>
        <div class="stat-label">Distribusi Terbanyak (Bulan Ini)</div>
        <div class="stat-change up"><i class="fas fa-arrow-up"></i> Berdasarkan kg terkirim</div>
    </div>
    <div class="stat-card blue animate-in">
        <div class="stat-icon"><i class="fas fa-truck"></i></div>
        <div class="stat-value">{{ number_format($totalDikirimBulanIni) }} <small style="font-size:14px;font-weight:600;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Total Dikirim (Bulan Ini)</div>
        <div class="stat-change" style="color:var(--blue-500);"><i class="fas fa-calendar"></i> Bulan {{ now()->translatedFormat('F Y') }}</div>
    </div>
</div>

{{-- TABLE CARD --}}
<div class="card">
    <div class="card-header" style="flex-wrap:wrap;gap:10px;">
        <div>
            <div class="card-title">Daftar Tujuan Distribusi</div>
            <div class="card-subtitle">{{ $total }} tujuan ditemukan @if($search) untuk "<strong>{{ $search }}</strong>" @endif</div>
        </div>
        <button class="btn btn-primary" onclick="openModal('modalTambahTujuan')"><i class="fas fa-plus"></i> Tambah Tujuan</button>
    </div>

    {{-- SEARCH BAR --}}
    <div style="padding:12px 20px 0;">
        <form method="GET" action="{{ route('admin.tujuan-distribusi.index') }}" id="searchForm">
            <div style="position:relative;max-width:400px;">
                <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;"></i>
                <input
                    type="text"
                    name="search"
                    value="{{ $search }}"
                    placeholder="Cari nama tujuan..."
                    oninput="debounceSearch()"
                    style="width:100%;padding:8px 36px 8px 34px;border-radius:8px;border:1.5px solid var(--border);font-size:13px;background:var(--surface-2);color:var(--text-primary);outline:none;box-sizing:border-box;transition:border-color .2s;"
                    onfocus="this.style.borderColor='var(--green-500)'"
                    onblur="this.style.borderColor='var(--border)'"
                >
                @if($search)
                <a href="{{ route('admin.tujuan-distribusi.index') }}" style="position:absolute;right:10px;top:50%;transform:translateY(-50%);color:var(--text-muted);text-decoration:none;font-size:13px;" title="Reset pencarian">
                    <i class="fas fa-times"></i>
                </a>
                @endif
            </div>
        </form>
    </div>

    <div class="card-body">
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width:50px;">#</th>
                        <th>Nama Tujuan</th>
                        <th>Total Terkirim</th>
                        <th>Dibuat</th>
                        <th style="width:100px;">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($tujuans as $t)
                        <tr>
                            <td style="color:var(--text-muted);font-size:12px;">{{ (($currentPage-1)*10) + $loop->iteration }}</td>
                            <td style="font-weight:600;">{{ $t->nama }}</td>
                            <td>
                                @if($t->total_terkirim > 0)
                                    <span style="font-weight:700;color:var(--green-600);">{{ number_format($t->total_terkirim) }} kg</span>
                                @else
                                    <span style="color:var(--text-muted);font-size:12px;">Belum ada</span>
                                @endif
                            </td>
                            <td style="font-size:12px;color:var(--text-muted);">{{ $t->created_at?->format('d M Y') ?? '-' }}</td>
                            <td>
                                <form method="POST" action="{{ route('admin.tujuan-distribusi.destroy', $t->id) }}" onsubmit="return false;" class="inline-form">
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
                            <td colspan="5" style="text-align:center;padding:36px;color:var(--text-muted);">
                                <i class="fas fa-inbox" style="font-size:32px;margin-bottom:10px;display:block;"></i>
                                @if($search)
                                    Tidak ada tujuan yang cocok dengan "<strong>{{ $search }}</strong>"
                                @else
                                    Belum ada tujuan distribusi
                                @endif
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        {{-- PAGINATION --}}
        @if($total > 0)
            <div style="padding:16px;display:flex;flex-wrap:wrap;justify-content:center;align-items:center;gap:10px;border-top:1px solid var(--border,#e2e8f0);">
                <div style="width:100%;text-align:center;font-size:12px;color:var(--text-muted);">
                    Menampilkan {{ ($currentPage - 1) * 10 + 1 }}–{{ min($currentPage * 10, $total) }} dari {{ $total }} data
                </div>
                <div style="display:flex;flex-wrap:wrap;justify-content:center;gap:4px;">
                    @if($currentPage <= 1)
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;">First</span>
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;"><i class="fas fa-chevron-left"></i></span>
                    @else
                        <a href="{{ route('admin.tujuan-distribusi.index', ['page' => 1, 'search' => $search]) }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;">First</a>
                        <a href="{{ route('admin.tujuan-distribusi.index', ['page' => $currentPage - 1, 'search' => $search]) }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;"><i class="fas fa-chevron-left"></i></a>
                    @endif
                    
                    @for($p = max(1, $currentPage-2); $p <= min(max(1, $lastPage), $currentPage+2); $p++)
                        <a href="{{ route('admin.tujuan-distribusi.index', ['page' => $p, 'search' => $search]) }}" style="padding:6px 10px;border-radius:6px;font-size:12px;text-decoration:none;background:{{ $p == $currentPage ? 'var(--green-600)' : 'var(--surface-3)' }};color:{{ $p == $currentPage ? 'white' : 'var(--text-primary)' }};">{{ $p }}</a>
                    @endfor
                    
                    @if($currentPage >= max(1, $lastPage))
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;"><i class="fas fa-chevron-right"></i></span>
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;">Last</span>
                    @else
                        <a href="{{ route('admin.tujuan-distribusi.index', ['page' => $currentPage + 1, 'search' => $search]) }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;"><i class="fas fa-chevron-right"></i></a>
                        <a href="{{ route('admin.tujuan-distribusi.index', ['page' => max(1, $lastPage), 'search' => $search]) }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;">Last</a>
                    @endif
                </div>
            </div>
        @endif
    </div>
</div>

{{-- MODAL TAMBAH --}}
<div class="modal-overlay" id="modalTambahTujuan">
    <div class="modal">
        <div class="modal-header">
            <div class="modal-title">Tambah Tujuan Distribusi</div>
            <button class="modal-close" onclick="closeModal('modalTambahTujuan')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="{{ route('admin.tujuan-distribusi.store') }}">
            @csrf
            <div class="modal-body">
                <div class="form-group">
                    <label>Nama Tujuan</label>
                    <input type="text" name="nama" required placeholder="Contoh: MBG 1">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalTambahTujuan')">Batal</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Simpan</button>
            </div>
        </form>
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

let searchTimer;
function debounceSearch() {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(() => {
        document.getElementById('searchForm').submit();
    }, 500);
}
</script>
@endpush
