@extends('layout.admin')

@section('title', 'Data Petani')
@section('page-title', 'Data Petani')
@section('page-subtitle', 'Manajemen data petani dan lahan mitra')

@section('content')

@if(session('success'))
<div class="alert alert-success alert-dismissible fade show" role="alert" style="margin-bottom:16px;">
    <i class="fas fa-check-circle"></i> {{ session('success') }}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
@endif

@if(session('error'))
<div class="alert alert-danger alert-dismissible fade show" role="alert" style="margin-bottom:16px;">
    <i class="fas fa-exclamation-circle"></i> {{ session('error') }}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
@endif

<div class="card">
    <div class="toolbar" style="display:flex;flex-wrap:wrap;align-items:center;gap:12px;margin-bottom:18px;">
        <div style="display:flex;gap:8px;flex-wrap:wrap;align-items:center;">
            <input type="text" id="searchInput" placeholder="Cari petani, NIK, telepon..." style="padding:10px 12px;border:1px solid var(--border);border-radius:8px;min-width:220px;">
            <select id="filterKomoditas" onchange="filterTable()" style="padding:10px 12px;border:1px solid var(--border);border-radius:8px;min-width:180px;">
                <option value="">Semua Komoditas</option>
                <option value="Padi">Padi</option>
                <option value="Jagung">Jagung</option>
                <option value="Padi & Jagung">Padi & Jagung</option>
            </select>
        </div>

        <div style="margin-left:auto;display:flex;gap:10px;flex-wrap:wrap;">
            <button class="btn btn-primary" onclick="openModal('modalTambah')">
                <i class="fas fa-plus"></i> Tambah Petani
            </button>
            <a href="{{ route('admin.petani.export', ['format' => 'pdf']) }}" class="btn btn-secondary">
                <i class="fas fa-file-pdf"></i> PDF
            </a>
            <a href="{{ route('admin.petani.export', ['format' => 'excel']) }}" class="btn btn-secondary">
                <i class="fas fa-file-excel"></i> Excel
            </a>
            <a href="{{ route('admin.petani.export', ['format' => 'csv']) }}" class="btn btn-secondary">
                <i class="fas fa-file-csv"></i> CSV
            </a>
        </div>
    </div>

    <div class="table-container">
        <table class="data-table" id="tablePetani">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Nama Petani</th>
                    <th>NIK / Kontak</th>
                    <th>Luas Lahan</th>
                    <th>Komoditas</th>
                    <th>Alamat</th>
                    <th>Status</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($petani as $i => $item)
                    <tr>
                        <td style="color:var(--text-muted);font-size:12px;">{{ $i + 1 }}</td>
                        <td>
                            <div style="display:flex;align-items:center;gap:10px;">
                                <div style="width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,var(--green-400),var(--green-600));display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;color:#fff;flex-shrink:0;">
                                    {{ strtoupper(substr($item->nama, 0, 1)) }}
                                </div>
                                <div>
                                    <div style="font-weight:600;">{{ $item->nama }}</div>
                                    <div style="font-size:11.5px;color:var(--text-muted);">ID: #{{ str_pad($item->id, 4, '0', STR_PAD_LEFT) }}</div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div>{{ $item->nik ?? '-' }}</div>
                            <div style="font-size:12px;color:var(--text-muted);">{{ $item->telepon ?? '-' }}</div>
                        </td>
                        <td><strong>{{ number_format($item->luas_lahan ?? 0) }}</strong> m²</td>
                        <td>
                            <span class="badge badge-{{ $item->komoditas == 'Padi' ? 'green' : ($item->komoditas == 'Jagung' ? 'amber' : 'blue') }}">
                                {{ $item->komoditas }}
                            </span>
                        </td>
                        <td style="font-size:12.5px;color:var(--text-secondary);">{{ Str::limit($item->alamat ?? '-', 35) }}</td>
                        <td>
                            <span class="badge badge-{{ $item->status == 'aktif' ? 'green' : 'gray' }}">
                                {{ $item->status === 'nonaktif' ? 'Non-aktif' : ucfirst($item->status ?? 'aktif') }}
                            </span>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px;flex-wrap:wrap;">
                                <a href="{{ route('admin.petani.edit', $item->id) }}" class="btn btn-secondary btn-icon btn-sm" title="Edit">
                                    <i class="fas fa-pen"></i>
                                </a>
                                <a href="{{ route('admin.petani.show', $item->id) }}" class="btn btn-secondary btn-icon btn-sm" title="Detail">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <form method="POST" action="{{ route('admin.petani.destroy', $item->id) }}"
                                    style="display:inline;"
                                    onsubmit="return confirm('Hapus data petani {{ $item->nama }}?')">
                                    @csrf @method('DELETE')
                                    <button type="submit" class="btn btn-danger btn-icon btn-sm" title="Hapus">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    {{-- DUMMY --}}
                    @php
                        $dummies = [
                            ['Silvy Halimatusyadiah', '3210xxxxxxxxx', '9200', 'Padi & Jagung', 'Blok Gunung Sari RT 01/02, Gunung Manik', 'aktif'],
                            ['Budi Santoso', '3211xxxxxxxxx', '5000', 'Padi', 'Desa Talaga, Majalengka', 'aktif'],
                            ['Ahmad Fauzi', '3212xxxxxxxxx', '7800', 'Padi', 'Desa Cikijing, Majalengka', 'aktif'],
                            ['Dewi Rahayu', '3213xxxxxxxxx', '3200', 'Jagung', 'Desa Sindang, Majalengka', 'non-aktif'],
                        ];
                    @endphp
                    @foreach($dummies as $i => $d)
                        <tr>
                            <td style="color:var(--text-muted);font-size:12px;">{{ $i+1 }}</td>
                            <td>
                                <div style="display:flex;align-items:center;gap:10px;">
                                    <div style="width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,var(--green-400),var(--green-600));display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;color:#fff;">
                                        {{ strtoupper(substr($d[0], 0, 1)) }}
                                    </div>
                                    <div>
                                        <div style="font-weight:600;">{{ $d[0] }}</div>
                                        <div style="font-size:11.5px;color:var(--text-muted);">ID: #{{ str_pad($i+1, 4, '0', STR_PAD_LEFT) }}</div>
                                    </div>
                                </div>
                            </td>
                            <td><div>{{ $d[1] }}</div><div style="font-size:12px;color:var(--text-muted);">+62 8xx xxxx xxxx</div></td>
                            <td><strong>{{ number_format($d[2]) }}</strong> m²</td>
                            <td><span class="badge badge-{{ $d[3]=='Padi'?'green':($d[3]=='Jagung'?'amber':'blue') }}">{{ $d[3] }}</span></td>
                            <td style="font-size:12.5px;color:var(--text-secondary);">{{ substr($d[4],0,40) }}</td>
                            <td><span class="badge badge-{{ $d[5]=='aktif'?'green':'gray' }}">{{ ucfirst($d[5]) }}</span></td>
                            <td>
                                <div style="display:flex;gap:6px;">
                                    <button class="btn btn-secondary btn-icon btn-sm" onclick="openModal('modalTambah')"><i class="fas fa-pen"></i></button>
                                    <button class="btn btn-danger btn-icon btn-sm"><i class="fas fa-trash"></i></button>
                                </div>
                            </td>
                        </tr>
                    @endforeach
                @endforelse
            </tbody>
        </table>
    </div>

    {{-- PAGINATION --}}
    @if(isset($petani) && $petani->hasPages())
        <div style="padding:16px 24px;border-top:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
            <span style="font-size:13px;color:var(--text-muted);">
                Menampilkan {{ $petani->firstItem() }}–{{ $petani->lastItem() }} dari {{ $petani->total() }} petani
            </span>
            {{ $petani->links() }}
        </div>
    @endif
</div>

{{-- MODAL TAMBAH PETANI --}}
<div class="modal-overlay" id="modalTambah">
    <div class="modal">
        <div class="modal-header">
            <div class="modal-title">Tambah Data Petani</div>
            <button class="modal-close" onclick="closeModal('modalTambah')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="{{ route('admin.petani.store') }}" id="formTambahPetani">
            @csrf
            <div class="modal-body">
                <div class="grid-2">
                    <div class="form-group">
                        <label>Nama Lengkap <span style="color:var(--red-500)">*</span></label>
                        <input type="text" name="nama" placeholder="Nama petani" required>
                    </div>
                    <div class="form-group">
                        <label>NIK</label>
                        <input type="text" name="nik" placeholder="16 digit NIK" maxlength="16">
                    </div>
                </div>
                <div class="grid-2">
                    <div class="form-group">
                        <label>No. Telepon</label>
                        <input type="text" name="telepon" placeholder="+62 8xx xxxx xxxx">
                    </div>
                    <div class="form-group">
                        <label>Luas Lahan (m²) <span style="color:var(--red-500)">*</span></label>
                        <input type="number" name="luas_lahan" placeholder="contoh: 9200" required min="0">
                    </div>
                </div>
                <div class="grid-2">
                    <div class="form-group">
                        <label>Komoditas Utama <span style="color:var(--red-500)">*</span></label>
                        <select name="komoditas" required>
                            <option value="">Pilih komoditas</option>
                            <option value="Padi">Padi</option>
                            <option value="Jagung">Jagung</option>
                            <option value="Padi & Jagung">Padi & Jagung</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <select name="status">
                            <option value="aktif">Aktif</option>
                            <option value="non-aktif">Non-Aktif</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Alamat <span style="color:var(--red-500)">*</span></label>
                    <textarea name="alamat" rows="2" placeholder="Alamat lengkap petani" required></textarea>
                </div>
                <div class="form-group">
                    <label>Catatan</label>
                    <textarea name="catatan" rows="2" placeholder="Catatan tambahan (opsional)"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalTambah')">Batal</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Simpan</button>
            </div>
        </form>
    </div>
</div>

@endsection

@push('scripts')
<script>
function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    const k = document.getElementById('filterKomoditas').value.toLowerCase();
    document.querySelectorAll('#tablePetani tbody tr').forEach(row => {
        const text = row.textContent.toLowerCase();
        const matchQ = text.includes(q);
        const matchK = k === '' || text.includes(k);
        row.style.display = (matchQ && matchK) ? '' : 'none';
    });
}

document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('formTambahPetani');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalText = submitBtn.textContent;
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Menyimpan...';
            
            fetch(form.action, {
                method: 'POST',
                body: new FormData(form),
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
            .then(response => {
                if (response.ok) {
                    closeModal('modalTambah');
                    form.reset();
                    // Reload page setelah 500ms untuk memastikan data tersimpan
                    setTimeout(() => location.reload(), 500);
                } else {
                    alert('Gagal menyimpan data. Silakan coba lagi.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Terjadi kesalahan. Silakan coba lagi.');
            })
            .finally(() => {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
            });
        });
    }
});
</script>
@endpush
        