@extends('layout.admin')

@section('title', 'Data Petani')
@section('page-title', 'Data Petani')
@section('page-subtitle', 'Manajemen data petani dan lahan mitra')

@section('content')

<div class="card">
    {{-- TOOLBAR --}}
    <div class="toolbar">
        <div class="search-input-wrap">
            <i class="fas fa-search"></i>
            <input type="text" id="searchInput" placeholder="Cari nama petani, NIK, atau komoditas..." oninput="filterTable()">
        </div>

        <select id="filterKomoditas" onchange="filterTable()" style="width:auto;min-width:150px;">
            <option value="">Semua Komoditas</option>
            <option value="Padi">Padi</option>
            <option value="Jagung">Jagung</option>
            <option value="Padi & Jagung">Padi & Jagung</option>
        </select>

        <button class="btn btn-primary" onclick="openModal('modalTambah')">
            <i class="fas fa-plus"></i> Tambah Petani
        </button>

        <a href="{{ route('admin.petani.export') }}" class="btn btn-secondary">
            <i class="fas fa-file-excel"></i> Export
        </a>
    </div>

    {{-- TABLE --}}
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
                @forelse($petanis ?? [] as $i => $petani)
                    <tr>
                        <td style="color:var(--text-muted);font-size:12px;">{{ $i + 1 }}</td>
                        <td>
                            <div style="display:flex;align-items:center;gap:10px;">
                                <div style="width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,var(--green-400),var(--green-600));display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;color:#fff;flex-shrink:0;">
                                    {{ strtoupper(substr($petani->nama, 0, 1)) }}
                                </div>
                                <div>
                                    <div style="font-weight:600;">{{ $petani->nama }}</div>
                                    <div style="font-size:11.5px;color:var(--text-muted);">ID: #{{ str_pad($petani->id, 4, '0', STR_PAD_LEFT) }}</div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div>{{ $petani->nik ?? '-' }}</div>
                            <div style="font-size:12px;color:var(--text-muted);">{{ $petani->telepon ?? '-' }}</div>
                        </td>
                        <td><strong>{{ number_format($petani->luas_lahan ?? 0) }}</strong> m²</td>
                        <td>
                            <span class="badge badge-{{ $petani->komoditas == 'Padi' ? 'green' : ($petani->komoditas == 'Jagung' ? 'amber' : 'blue') }}">
                                {{ $petani->komoditas }}
                            </span>
                        </td>
                        <td style="font-size:12.5px;color:var(--text-secondary);">{{ Str::limit($petani->alamat ?? '-', 35) }}</td>
                        <td>
                            <span class="badge badge-{{ $petani->status == 'aktif' ? 'green' : 'gray' }}">
                                {{ ucfirst($petani->status ?? 'aktif') }}
                            </span>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px;">
                                <button class="btn btn-secondary btn-icon btn-sm"
                                    onclick="openEditModal({{ $petani }})"
                                    title="Edit">
                                    <i class="fas fa-pen"></i>
                                </button>
                                <button class="btn btn-secondary btn-icon btn-sm"
                                    onclick="openDetailModal({{ $petani }})"
                                    title="Detail">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <form method="POST" action="{{ route('admin.petani.destroy', $petani->id) }}"
                                    onsubmit="return confirm('Hapus data petani {{ $petani->nama }}?')">
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
    @if(isset($petanis) && $petanis->hasPages())
        <div style="padding:16px 24px;border-top:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
            <span style="font-size:13px;color:var(--text-muted);">
                Menampilkan {{ $petanis->firstItem() }}–{{ $petanis->lastItem() }} dari {{ $petanis->total() }} petani
            </span>
            {{ $petanis->links() }}
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
        <form method="POST" action="{{ route('admin.petani.store') }}">
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
                    <label>Alamat</label>
                    <textarea name="alamat" rows="2" placeholder="Alamat lengkap petani"></textarea>
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
</script>
@endpush
