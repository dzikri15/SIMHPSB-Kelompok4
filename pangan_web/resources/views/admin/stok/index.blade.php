@extends('layout.admin')

@section('title', 'Stok Gudang')
@section('page-title', 'Stok Gudang')
@section('page-subtitle', 'Transaksi masuk/keluar dan saldo stok real-time')

@section('content')

@if ($errors->any())
    <div class="alert-banner danger" style="margin-bottom:24px;">
        <i class="fas fa-exclamation-circle"></i>
        <div>
            <strong>Perbaiki kesalahan input stok:</strong>
            <ul style="margin:8px 0 0 16px;">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    </div>
@endif

{{-- RINGKASAN STOK --}}
<div class="stat-grid" style="margin-bottom:24px;">
    <div class="stat-card green">
        <div class="stat-icon"><i class="fas fa-box-open"></i></div>
        <div id="statStokBerasPage" class="stat-value">{{ number_format($stokBeras ?? 450) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Saldo Beras</div>
        <div style="margin-top:10px;">
            <div class="progress-bar">
                <div class="progress-fill" style="width:{{ min(100, round((($stokBeras ?? 450)/($kapasitasBeras ?? 1000))*100)) }}%;background:var(--green-500);"></div>
            </div>
            <div style="font-size:11px;color:var(--text-muted);margin-top:4px;">{{ round((($stokBeras ?? 450)/($kapasitasBeras ?? 1000))*100) }}% kapasitas (max {{ number_format($kapasitasBeras ?? 1000) }} kg)</div>
        </div>
    </div>

    <div class="stat-card amber">
        <div class="stat-icon"><i class="fas fa-seedling"></i></div>
        <div id="statStokGabahPage" class="stat-value">{{ number_format($stokGabah ?? 800) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Saldo Gabah</div>
        <div style="margin-top:10px;">
            <div class="progress-bar">
                <div class="progress-fill" style="width:{{ min(100, round((($stokGabah ?? 800)/($kapasitasGabah ?? 2000))*100)) }}%;background:var(--amber-500);"></div>
            </div>
            <div style="font-size:11px;color:var(--text-muted);margin-top:4px;">{{ round((($stokGabah ?? 800)/($kapasitasGabah ?? 2000))*100) }}% kapasitas (max {{ number_format($kapasitasGabah ?? 2000) }} kg)</div>
        </div>
    </div>

    @php $monthLabel = \Carbon\Carbon::create($currentYear, $currentMonth, 1)->translatedFormat('F Y'); @endphp
    <div class="stat-card blue">
        <div class="stat-icon"><i class="fas fa-arrow-circle-down"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format(($masukBerasBulanIni ?? 0) + ($masukGabahBulanIni ?? 0)) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Masuk {{ $monthLabel }}</div>
        <div class="stat-change up"><i class="fas fa-arrow-up"></i> Gabah + Beras</div>
    </div>

    <div class="stat-card red">
        <div class="stat-icon"><i class="fas fa-arrow-circle-up"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format(($keluarBerasBulanIni ?? 0) + ($keluarGabahBulanIni ?? 0)) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Keluar {{ $monthLabel }}</div>
        <div class="stat-change down"><i class="fas fa-arrow-down"></i> Distribusi aktif</div>
    </div>

    <div class="stat-card blue" style="border-top:3px solid var(--blue-500);">
        <div class="stat-icon"><i class="fas fa-inbox"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($masukBerasBulanIni ?? 0) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Masuk Beras {{ $monthLabel }}</div>
    </div>

    <div class="stat-card amber" style="border-top:3px solid var(--amber-500);">
        <div class="stat-icon"><i class="fas fa-inbox"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($masukGabahBulanIni ?? 0) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Masuk Gabah {{ $monthLabel }}</div>
    </div>

    <div class="stat-card red" style="border-top:3px solid var(--red-500);">
        <div class="stat-icon"><i class="fas fa-arrow-circle-up"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($keluarBerasBulanIni ?? 0) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Keluar Beras {{ $monthLabel }}</div>
    </div>

    <div class="stat-card red" style="border-top:3px solid var(--red-500);">
        <div class="stat-icon"><i class="fas fa-arrow-circle-up"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($keluarGabahBulanIni ?? 0) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Keluar Gabah {{ $monthLabel }}</div>
    </div>
</div>

<div class="card">
    {{-- TOOLBAR --}}
    <div class="toolbar">
        <div class="search-input-wrap">
            <i class="fas fa-search"></i>
            <input type="text" id="searchStok" placeholder="Cari tujuan, komoditas..." oninput="filterStok()" value="{{ request('q') }}">
        </div>

        <select id="filterJenis" onchange="filterStok()" style="width:auto;min-width:130px;">
            <option value="">Semua Jenis</option>
            <option value="masuk" {{ request('jenis') == 'masuk' ? 'selected' : '' }}>Masuk</option>
            <option value="keluar" {{ request('jenis') == 'keluar' ? 'selected' : '' }}>Keluar</option>
        </select>

        <select id="filterKomoditas" onchange="filterStok()" style="width:auto;min-width:130px;">
            <option value="">Semua Komoditas</option>
            <option value="Beras" {{ request('komoditas') == 'Beras' ? 'selected' : '' }}>Beras</option>
            <option value="Gabah" {{ request('komoditas') == 'Gabah' ? 'selected' : '' }}>Gabah</option>
        </select>

        <input type="month" id="filterTanggal" oninput="filterStok()" title="Filter bulan" style="width:auto;" value="{{ request('tanggal') }}">

        <button class="btn btn-primary" onclick="openModal('modalTransaksi')">
            <i class="fas fa-plus"></i> Catat Transaksi
        </button>
    </div>

    <div class="table-container">
        <table class="data-table" id="tableStok">
            <thead>
                <tr>
                    <th>No</th>
                    <th>Tanggal</th>
                    <th>Jenis</th>
                    <th>Komoditas</th>
                    <th>Jumlah (kg)</th>
                    <th>Tujuan / Sumber</th>
                    <th>Catatan</th>
                    <th>Saldo Setelah</th>
                    <th>Status</th>
                    <th>Bukti</th>
                    <th>Dicatat Oleh</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($transaksis ?? [] as $i => $t)
                    <tr id="stokRow-{{ $t->id }}" class="{{ $t->status !== 'aktif' ? 'muted-row' : '' }} clickable-row" onclick="if(!event.target.closest('.row-action, .bukti-cell, .bukti-link')) window.location.href='{{ route('admin.stok.show', $t->id) }}';" style="cursor:pointer;">
                        <td style="color:var(--text-muted);font-size:12px;">{{ $i+1 }}</td>
                        <td>{{ ($t->tanggal ?? $t->tanggal_update) ? \Carbon\Carbon::parse($t->tanggal ?? $t->tanggal_update)->format('Y-m-d H:i') : '-' }}</td>
                        <td>
                            <span class="badge badge-{{ $t->jenis_transaksi == 'masuk' ? 'green' : 'red' }}">
                                <i class="fas fa-{{ $t->jenis_transaksi == 'masuk' ? 'arrow-down' : 'arrow-up' }}"></i>
                                {{ ucfirst($t->jenis_transaksi) }}
                            </span>
                        </td>
                        <td><span class="badge badge-{{ $t->komoditas == 'Beras' ? 'blue' : 'amber' }}">{{ $t->komoditas }}</span></td>
                        <td><strong>{{ number_format($t->jumlah) }}</strong></td>
                        <td>{{ $t->keterangan }}</td>
                        <td>{{ $t->catatan ?? '-' }}</td>
                        <td>{{ number_format($t->saldo_setelah ?? $t->jumlah) }} kg</td>
                        <td>
                            @if($t->status === 'aktif')
                                <span class="badge badge-green">Aktif</span>
                            @else
                                <span class="badge badge-gray">Dibatalkan</span>
                            @endif
                        </td>
                        <td class="bukti-cell" data-src="{{ !empty($t->foto_bukti) ? asset('storage/' . $t->foto_bukti) : '' }}" onclick="if(this.dataset.src) openImageModal(this.dataset.src)" style="text-align:center;cursor:pointer;">
                            @if(!empty($t->foto_bukti))
                                <a href="javascript:void(0)" class="bukti-link" data-src="{{ asset('storage/' . $t->foto_bukti) }}" title="Lihat bukti" onclick="event.preventDefault(); openImageModal(this.dataset.src);">
                                    <img src="{{ asset('storage/' . $t->foto_bukti) }}" style="width:36px;height:36px;object-fit:cover;border-radius:6px;border:1px solid #e5e7eb;cursor:pointer;" alt="Bukti">
                                </a>
                            @else
                                -
                            @endif
                        </td>
                        <td style="font-size:12px;color:var(--text-muted);">{{ optional($t->user)->name ?? '-' }}</td>
                        <td class="row-action" style="display:flex;gap:8px;justify-content:flex-end;">
                            <a href="{{ route('admin.stok.show', $t->id) }}" class="btn btn-secondary btn-icon btn-sm" title="Lihat detail transaksi">
                                <i class="fas fa-eye"></i>
                            </a>
                            <a href="{{ route('admin.stok.edit', $t->id) }}" class="btn btn-primary btn-icon btn-sm" title="Edit transaksi" onclick="event.stopPropagation()">
                                <i class="fas fa-edit"></i>
                            </a>
                            @if($t->status === 'aktif')
                                <button class="btn btn-warning btn-icon btn-sm" onclick="event.stopPropagation(); performToggle({{ $t->id }})" title="Batalkan transaksi"><i class="fas fa-times"></i></button>
                            @else
                                <button class="btn btn-success btn-icon btn-sm" onclick="event.stopPropagation(); performToggle({{ $t->id }})" title="Aktifkan kembali"><i class="fas fa-redo"></i></button>
                            @endif
                            <button class="btn btn-danger btn-icon btn-sm" onclick="event.stopPropagation(); performDelete({{ $t->id }})" title="Hapus permanen"><i class="fas fa-trash"></i></button>
                        </td>
                    </tr>
                @empty
                    @php
                        $rows = [
                            
                        ];
                    @endphp
                    @foreach($rows as $i => $r)
                        <tr>
                            <td style="color:var(--text-muted);font-size:12px;">{{ $i+1 }}</td>
                            <td style="font-size:12.5px;">{{ $r[0] }}</td>
                            <td>
                                <span class="badge badge-{{ $r[1]=='masuk'?'green':'red' }}">
                                    <i class="fas fa-arrow-{{ $r[1]=='masuk'?'down':'up' }}"></i>
                                    {{ ucfirst($r[1]) }}
                                </span>
                            </td>
                            <td><span class="badge badge-{{ $r[2]=='Beras'?'blue':'amber' }}">{{ $r[2] }}</span></td>
                            <td><strong>{{ number_format($r[3]) }}</strong></td>
                            <td style="font-size:13px;">{{ $r[4] }}</td>
                            <td style="font-size:13px;">{{ $r[5] }}</td>
                            <td><strong>{{ number_format($r[6]) }}</strong> kg</td>
                            <td style="font-size:12px;color:var(--text-muted);">{{ $r[7] }}</td>
                            <td><button class="btn btn-secondary btn-icon btn-sm" disabled><i class="fas fa-eye"></i></button></td>
                        </tr>
                    @endforeach
                @endforelse
            </tbody>
        </table>
        {{-- Paginasi --}}
        @if($transaksis->total() > 0)
            <div style="padding:16px;display:flex;flex-wrap:wrap;justify-content:center;align-items:center;gap:10px;border-top:1px solid var(--border,#e2e8f0);">
                <div style="width:100%;text-align:center;font-size:12px;color:var(--text-muted);">
                    Menampilkan {{ $transaksis->firstItem() }}–{{ $transaksis->lastItem() }} dari {{ $transaksis->total() }} data
                </div>
                <div style="display:flex;flex-wrap:wrap;justify-content:center;gap:4px;">
                    @if($transaksis->onFirstPage())
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;">First</span>
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;"><i class="fas fa-chevron-left"></i></span>
                    @else
                        <a href="{{ $transaksis->url(1) }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;">First</a>
                        <a href="{{ $transaksis->previousPageUrl() }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;"><i class="fas fa-chevron-left"></i></a>
                    @endif
                    @foreach($transaksis->getUrlRange(max(1,$transaksis->currentPage()-2), min($transaksis->lastPage(),$transaksis->currentPage()+2)) as $page => $url)
                        <a href="{{ $url }}" style="padding:6px 10px;border-radius:6px;font-size:12px;text-decoration:none;background:{{ $page == $transaksis->currentPage() ? 'var(--green-600)' : 'var(--surface-3)' }};color:{{ $page == $transaksis->currentPage() ? 'white' : 'var(--text-primary)' }};">{{ $page }}</a>
                    @endforeach
                    @if($transaksis->hasMorePages())
                        <a href="{{ $transaksis->nextPageUrl() }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;"><i class="fas fa-chevron-right"></i></a>
                        <a href="{{ $transaksis->url($transaksis->lastPage()) }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;">Last</a>
                    @else
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;"><i class="fas fa-chevron-right"></i></span>
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;">Last</span>
                    @endif
                </div>
            </div>
        @endif
    </div>
</div>

{{-- MODAL CATAT TRANSAKSI --}}
<div class="modal-overlay" id="modalTransaksi">
    <div class="modal">
        <div class="modal-header">
            <div class="modal-title">Catat Transaksi Stok</div>
            <button class="modal-close" onclick="closeModal('modalTransaksi')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="{{ route('admin.stok.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="modal-body">
                <div class="grid-2">
                    <div class="form-group">
                        <label>Jenis Transaksi <span style="color:var(--red-500)">*</span></label>
                        <select name="jenis" id="jenisTransaksi" required onchange="toggleTujuan()">
                            <option value="">Pilih jenis</option>
                            <option value="masuk">Masuk</option>
                            <option value="keluar">Keluar</option>
                        </select>
                        <div class="form-hint" id="gabahMasukNote" style="display:none;color:var(--text-muted);">
                            <i class="fas fa-info-circle"></i> Gabah Masuk otomatis tercatat dari menu <strong>Pencatatan Panen</strong>.
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Komoditas <span style="color:var(--red-500)">*</span></label>
                        <select name="komoditas" id="komoditasTransaksi" required onchange="onKomoditasChange()">
                            <option value="">Pilih komoditas</option>
                            <option value="Gabah">Gabah</option>
                            <option value="Beras">Beras</option>
                        </select>
                    </div>
                </div>
                <div class="grid-2">
                    <div class="form-group">
                        <label>Jumlah (kg) <span style="color:var(--red-500)">*</span></label>
                        <input type="number" name="jumlah" placeholder="0" required min="1">
                    </div>
                    <div class="form-group">
                        <label>Tanggal</label>
                        <input id="tanggalTransaksi" type="datetime-local" name="tanggal" value="{{ date('Y-m-d\TH:i') }}">
                        <div class="form-hint">Waktu akan terisi otomatis saat menyimpan jika Anda tidak mengubahnya.</div>
                    </div>
                </div>

                <div class="form-group" id="tujuanGroup" style="display:none;">
                    <label>Tujuan Distribusi <span style="color:var(--red-500)">*</span></label>
                    {{-- Hidden input for form submission --}}
                    <input type="hidden" name="tujuan_distribusi" id="tujuanSelectHidden">
                    {{-- Custom searchable dropdown --}}
                    <div id="tujuanDropdown" style="position:relative;">
                        <div id="tujuanTrigger" onclick="toggleTujuanDropdown()" style="display:flex;align-items:center;justify-content:space-between;padding:10px 14px;border:1px solid var(--border);border-radius:8px;cursor:pointer;background:var(--surface);user-select:none;">
                            <span id="tujuanLabel" style="color:var(--text-muted);">Pilih tujuan</span>
                            <i class="fas fa-chevron-down" style="font-size:12px;color:var(--text-muted);transition:.2s;"></i>
                        </div>
                        <div id="tujuanPanel" style="display:none;position:absolute;z-index:1000;width:100%;top:calc(100% + 4px);background:var(--surface);border:1px solid var(--border);border-radius:8px;box-shadow:var(--shadow-md);overflow:hidden;">
                            <div style="padding:8px;">
                                <input type="text" id="tujuanSearch" placeholder="🔍 Cari tujuan..." oninput="filterTujuanList()" style="width:100%;padding:7px 10px;border-radius:6px;border:1px solid var(--border);font-size:13px;background:var(--surface-2);">
                            </div>
                            <ul id="tujuanList" style="list-style:none;margin:0;padding:0 0 6px;max-height:200px;overflow-y:auto;">
                                @foreach(($tujuans ?? []) as $t)
                                    <li onclick="selectTujuan('{{ $t->nama }}')" style="padding:9px 14px;cursor:pointer;font-size:13px;" class="tujuan-opt" onmouseover="this.style.background='var(--surface-2)'" onmouseout="this.style.background=''">{{ $t->nama }}</li>
                                @endforeach
                                <li onclick="showQuickAddTujuan()" style="padding:9px 14px;cursor:pointer;font-size:13px;color:var(--green-600);font-weight:600;border-top:1px solid var(--border);margin-top:4px;" onmouseover="this.style.background='var(--surface-2)'" onmouseout="this.style.background=''">+ Tambah tujuan baru</li>
                            </ul>
                        </div>
                    </div>
                    <input type="text" id="quickAddTujuanInput" placeholder="Ketik nama tujuan baru lalu tekan Enter..." style="display:none;margin-top:8px;width:100%;" />
                </div>

                <div class="form-group" id="sumberGroup">
                    <label>Sumber / Keterangan <span style="color:var(--red-500)">*</span></label>
                    <input type="text" name="keterangan" id="keteranganText" placeholder="Contoh: Petani Budi, Hasil Giling, dll." required>
                    <select name="keterangan" id="keteranganPetani" style="display:none;" disabled>
                        <option value="">Pilih Petani</option>
                        @foreach(($petanis ?? []) as $p)
                            <option value="Petani: {{ $p->nama }}">{{ $p->nama }}</option>
                        @endforeach
                    </select>
                </div>

                <div class="form-group">
                    <label>Catatan Tambahan</label>
                    <textarea name="catatan" rows="2" placeholder="Opsional"></textarea>
                </div>

                <div class="form-group" id="fotoBuktiGroup" style="display:none;">
                    <label>Foto Bukti Pengiriman <small style="color:var(--text-muted);font-size:12px;">(jpg, png, webp — max 2MB)</small></label>
                    <input type="file" name="foto_bukti" id="fotoBuktiInput" accept="image/*">
                    <div id="fotoPreview" style="margin-top:8px;display:none;">
                        <img id="fotoPreviewImg" src="" alt="Preview" style="width:120px;height:80px;object-fit:cover;border-radius:6px;border:2px solid #e8f5e9;">
                    </div>
                </div>

                {{-- VALIDASI STOK REAL-TIME --}}
                <div id="stokWarning" class="alert-banner warning" style="display:none;margin-top:0;">
                    <i class="fas fa-exclamation-triangle"></i>
                    <div>Perhatikan saldo stok saat ini sebelum mencatat transaksi keluar.</div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalTransaksi')">Batal</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Simpan</button>
            </div>
        </form>
    </div>
</div>

@endsection


@push('scripts')
<script>
// Load SlimSelect CSS dynamically
(function(){
    var link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'https://unpkg.com/slim-select@latest/dist/slimselect.css';
    document.head.appendChild(link);
})();
</script>
<script src="https://unpkg.com/slim-select@latest/dist/slimselect.min.js"></script>
<script>
// Styles for muted row
const style = document.createElement('style');
style.innerHTML = `
    .muted-row { opacity: 0.6; text-decoration: line-through; }
    .badge-gray { background:#9CA3AF; color:#fff; padding:4px 8px; border-radius:6px; font-size:12px; }
`;
document.head.appendChild(style);

// Toggle status aksi
function performToggle(id) {
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    fetch(`{{ url('admin/stok') }}/${id}/toggle-status`, {
        method: 'PATCH',
        headers: {
            'X-CSRF-TOKEN': token,
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }
    })
    .then(r => r.json())
    .then(data => {
        if (!data || !data.success) {
            alert(data?.message || 'Gagal memperbarui status');
            return;
        }

        // update row inline
        const row = document.getElementById(`stokRow-${id}`);
        if (row) {
            const statusCell = row.querySelector('td:nth-child(9)');
            const actionCell = row.querySelector('.row-action');
            if (statusCell) {
                statusCell.innerHTML = data.status === 'aktif'
                    ? '<span class="badge badge-green">Aktif</span>'
                    : '<span class="badge badge-gray">Dibatalkan</span>';
            }
            if (actionCell) {
                actionCell.innerHTML = `
                    <a href="/admin/stok/${id}" class="btn btn-secondary btn-icon btn-sm" title="Lihat detail transaksi">
                        <i class="fas fa-eye"></i>
                    </a>
                    <a href="/admin/stok/${id}/edit" class="btn btn-primary btn-icon btn-sm" title="Edit transaksi" onclick="event.stopPropagation()">
                        <i class="fas fa-edit"></i>
                    </a>
                    ${data.status === 'aktif' 
                        ? '<button class="btn btn-warning btn-icon btn-sm" onclick="event.stopPropagation(); performToggle(' + id + ')" title="Batalkan transaksi"><i class="fas fa-times"></i></button>' 
                        : '<button class="btn btn-success btn-icon btn-sm" onclick="event.stopPropagation(); performToggle(' + id + ')" title="Aktifkan kembali"><i class="fas fa-redo"></i></button>'
                    }
                    <button class="btn btn-danger btn-icon btn-sm" onclick="event.stopPropagation(); performDelete(${id})" title="Hapus permanen"><i class="fas fa-trash"></i></button>
                `;
            }
            row.classList.toggle('muted-row', data.status !== 'aktif');
        }

        // notify other tabs (dashboard) to refresh summary
        // update page-level stat cards if server returned a summary
        try {
            if (data.summary) {
                if (data.summary.stokBeras !== undefined) {
                    const elb = document.getElementById('statStokBerasPage');
                    if (elb) elb.innerHTML = Number(data.summary.stokBeras).toLocaleString() + ' <small style="font-size:13px;color:var(--text-muted);">kg</small>';
                }
                if (data.summary.stokGabah !== undefined) {
                    const elg = document.getElementById('statStokGabahPage');
                    if (elg) elg.innerHTML = Number(data.summary.stokGabah).toLocaleString() + ' <small style="font-size:13px;color:var(--text-muted);">kg</small>';
                }
            }
        } catch (e) { console.error('Failed to update local stat cards', e); }

        try { localStorage.setItem('stok:updated', Date.now()); console.log('stok:updated set in localStorage', Date.now()); } catch(e) {}
        try {
            const bc = new BroadcastChannel('stok_channel');
            bc.postMessage({ updated: Date.now() });
            console.log('BroadcastChannel posted stok_channel', Date.now());
            bc.close();
        } catch (e) {
            // BroadcastChannel not supported
            console.log('BroadcastChannel not supported', e);
        }
    })
    .catch(err => { alert('Gagal menghubungi server'); console.error(err); });
}

function performDelete(id) {
    if (!confirm('Apakah Anda yakin ingin menghapus permanen transaksi ini?')) return;
    
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/admin/stok/' + id;
    
    const csrfInput = document.createElement('input');
    csrfInput.type = 'hidden';
    csrfInput.name = '_token';
    csrfInput.value = '{{ csrf_token() }}';
    
    const methodInput = document.createElement('input');
    methodInput.type = 'hidden';
    methodInput.name = '_method';
    methodInput.value = 'DELETE';
    
    form.appendChild(csrfInput);
    form.appendChild(methodInput);
    document.body.appendChild(form);
    form.submit();
}

let filterTimeout;
function filterStok() {
    clearTimeout(filterTimeout);
    filterTimeout = setTimeout(() => {
        const q = document.getElementById('searchStok').value;
        const j = document.getElementById('filterJenis').value;
        const k = document.getElementById('filterKomoditas').value;
        const t = document.getElementById('filterTanggal').value;
        
        const url = new URL(window.location.href);
        if (q) url.searchParams.set('q', q); else url.searchParams.delete('q');
        if (j) url.searchParams.set('jenis', j); else url.searchParams.delete('jenis');
        if (k) url.searchParams.set('komoditas', k); else url.searchParams.delete('komoditas');
        if (t) url.searchParams.set('tanggal', t); else url.searchParams.delete('tanggal');
        
        url.searchParams.delete('page');
        window.location.href = url.toString();
    }, 400);
}

function onKomoditasChange() {
    const komoditas = document.getElementById('komoditasTransaksi').value;
    const jenis = document.getElementById('jenisTransaksi');
    const note = document.getElementById('gabahMasukNote');
    
    for (let i = 0; i < jenis.options.length; i++) {
        if (komoditas === 'Gabah') {
            jenis.options[i].style.display = (jenis.options[i].value === 'keluar') ? 'block' : 'none';
        } else {
            jenis.options[i].style.display = 'block';
        }
    }
    
    if (komoditas === 'Gabah') {
        jenis.value = 'keluar';
    }
    
    // Tampilkan pesan
    if (note) {
        note.style.display = (komoditas === 'Gabah') ? 'block' : 'none';
    }
    
    toggleTujuan();
}

function toggleTujuan() {
    const jenis = document.getElementById('jenisTransaksi').value;
    const komoditas = document.getElementById('komoditasTransaksi') ? document.getElementById('komoditasTransaksi').value : '';
    const tujuan = document.getElementById('tujuanGroup');
    const warning = document.getElementById('stokWarning');
    if (jenis === 'keluar' && komoditas === 'Beras') {
        tujuan.style.display = 'block';
        document.getElementById('tujuanSelectHidden').setAttribute('required', 'required');
    } else {
        tujuan.style.display = 'none';
        document.getElementById('tujuanSelectHidden').removeAttribute('required');
    }

    warning.style.display = jenis === 'keluar' ? 'flex' : 'none';

    // foto bukti wajib untuk masuk dan keluar
    const fotoGroup = document.getElementById('fotoBuktiGroup');
    const fotoInput = document.getElementById('fotoBuktiInput');
    if (fotoGroup) {
        if (jenis === 'keluar' || jenis === 'masuk') {
            fotoGroup.style.display = 'block';
            if (fotoInput) {
                fotoInput.setAttribute('required', 'required');
            }
        } else {
            fotoGroup.style.display = 'none';
            if (fotoInput) {
                fotoInput.removeAttribute('required');
            }
        }
    }

    // Gabah masuk -> Sumber = Dropdown Petani
    const ketText = document.getElementById('keteranganText');
    const ketPetani = document.getElementById('keteranganPetani');
    if (jenis === 'masuk' && komoditas === 'Gabah') {
        if (ketText) { ketText.style.display = 'none'; ketText.removeAttribute('required'); ketText.disabled = true; }
        if (ketPetani) { ketPetani.style.display = 'block'; ketPetani.setAttribute('required', 'required'); ketPetani.disabled = false; }
    } else {
        if (ketText) { ketText.style.display = 'block'; ketText.setAttribute('required', 'required'); ketText.disabled = false; }
        if (ketPetani) { ketPetani.style.display = 'none'; ketPetani.removeAttribute('required'); ketPetani.disabled = true; }
    }
}

// preview foto bukti
function setupFotoPreview() {
    const input = document.getElementById('fotoBuktiInput');
    const preview = document.getElementById('fotoPreview');
    const img = document.getElementById('fotoPreviewImg');
    if (!input) return;
    input.addEventListener('change', function(e) {
        const file = this.files && this.files[0];
        if (!file) { preview.style.display = 'none'; img.src = ''; return; }
        const allowed = ['image/jpeg','image/png','image/webp'];
        if (!allowed.includes(file.type)) {
            alert('Format file tidak didukung. Gunakan jpg/png/webp.');
            this.value = '';
            preview.style.display = 'none';
            return;
        }
        if (file.size > 2 * 1024 * 1024) {
            alert('Ukuran file terlalu besar. Maks 2MB.');
            this.value = '';
            preview.style.display = 'none';
            return;
        }
        const reader = new FileReader();
        reader.onload = function(ev) {
            img.src = ev.target.result;
            preview.style.display = 'block';
        };
        reader.readAsDataURL(file);
    });
}

function getCurrentLocalDatetime() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${day}T${hours}:${minutes}`;
}

function ensureTanggalIsSet() {
    const tanggalInput = document.getElementById('tanggalTransaksi');
    if (!tanggalInput) {
        return;
    }
    if (!tanggalInput.value) {
        tanggalInput.value = getCurrentLocalDatetime();
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('form[action="{{ route('admin.stok.store') }}"]');
    ensureTanggalIsSet();
    if (form) {
        form.addEventListener('submit', function() {
            ensureTanggalIsSet();
        });
    }

    // Quick-add tujuan distribusi from transaksi modal
    const quickInput = document.getElementById('quickAddTujuanInput');

    // Close custom dropdown when clicking outside
    document.addEventListener('click', function(e) {
        const dropdown = document.getElementById('tujuanDropdown');
        const panel = document.getElementById('tujuanPanel');
        if (dropdown && panel && !dropdown.contains(e.target)) {
            panel.style.display = 'none';
        }
    });

    if (quickInput) {
        quickInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                const name = this.value.trim();
                if (!name) return;
                const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
                fetch('{{ route('admin.tujuan-distribusi.store') }}', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': token,
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({ nama: name })
                })
                .then(r => r.json())
                .then(data => {
                    if (data.success && data.data) {
                        const opt = document.createElement('option');
                        opt.value = data.data.nama;
                        opt.textContent = data.data.nama;
                        const addOpt = Array.from(tujuanSelect.options).find(o => o.value === '__add_new');
                        tujuanSelect.insertBefore(opt, addOpt);
                        tujuanSelect.value = data.data.nama;
                        quickInput.value = '';
                        quickInput.style.display = 'none';
                    } else {
                        alert('Gagal menambahkan tujuan');
                        console.error(data);
                    }
                })
                .catch(err => { alert('Gagal menghubungi server'); console.error(err); });
            }
        });

        quickInput.addEventListener('blur', function() { setTimeout(() => { quickInput.style.display = 'none'; tujuanSelect.value = ''; }, 200); });
    }

    // setup foto preview handler
    setupFotoPreview();
});
</script>
<div class="modal-overlay" id="modalImageLightbox" style="display:none;">
    <div class="modal" style="max-width:900px;max-height:90vh;background:transparent;box-shadow:none;">
        <div style="position:relative;background:linear-gradient(180deg, rgba(46,125,50,0.95), rgba(16,64,20,0.95));padding:16px;border-radius:8px;display:flex;justify-content:flex-end;">
            <button class="modal-close" onclick="closeImageModal()" style="position:absolute;right:12px;top:12px;color:#fff;background:transparent;border:none;font-size:20px;"><i class="fas fa-times"></i></button>
            <div style="width:100%;display:flex;align-items:center;justify-content:center;padding:24px;">
                <img id="modalImageFull" src="" alt="Bukti" style="max-width:100%;max-height:80vh;border-radius:8px;box-shadow:0 8px 24px rgba(0,0,0,0.4);transform:scale(0.98);opacity:0;transition:all .25s ease-in-out;" />
            </div>
        </div>
    </div>
</div>

<script>
function openImageModal(src) {
    const overlay = document.getElementById('modalImageLightbox');
    const img = document.getElementById('modalImageFull');
    if (!overlay || !img) return;
    img.style.opacity = 0; img.style.transform = 'scale(0.98)';
    img.src = src;
    overlay.style.display = 'flex';
    setTimeout(() => { img.style.opacity = 1; img.style.transform = 'scale(1)'; }, 40);
}
function closeImageModal() {
    const overlay = document.getElementById('modalImageLightbox');
    const img = document.getElementById('modalImageFull');
    if (!overlay || !img) return;
    img.style.opacity = 0; img.style.transform = 'scale(0.98)';
    setTimeout(() => { overlay.style.display = 'none'; img.src = ''; }, 220);
}

document.addEventListener('click', function(e) {
    const anchor = e.target.closest && e.target.closest('.bukti-link');
    if (anchor) {
        e.preventDefault();
        const src = anchor.dataset.src;
        if (src) {
            openImageModal(src);
        }
        return;
    }

    const cell = e.target.closest && e.target.closest('.bukti-cell');
    if (cell && cell.dataset.src) {
        e.preventDefault();
        openImageModal(cell.dataset.src);
    }

});

// Custom dropdown functions
function toggleTujuanDropdown() {
    const panel = document.getElementById('tujuanPanel');
    const search = document.getElementById('tujuanSearch');
    if (panel.style.display === 'none') {
        panel.style.display = 'block';
        search.focus();
    } else {
        panel.style.display = 'none';
    }
}

function filterTujuanList() {
    const q = document.getElementById('tujuanSearch').value.toLowerCase();
    const items = document.querySelectorAll('#tujuanList li.tujuan-opt');
    items.forEach(item => {
        const text = item.textContent.toLowerCase();
        item.style.display = text.includes(q) ? 'block' : 'none';
    });
}

function selectTujuan(name) {
    document.getElementById('tujuanSelectHidden').value = name;
    document.getElementById('tujuanLabel').textContent = name;
    document.getElementById('tujuanLabel').style.color = 'var(--text-primary)';
    document.getElementById('tujuanPanel').style.display = 'none';
    document.getElementById('quickAddTujuanInput').style.display = 'none';
    document.getElementById('quickAddTujuanInput').removeAttribute('required');
}

function showQuickAddTujuan() {
    document.getElementById('tujuanSelectHidden').value = '__add_new';
    document.getElementById('tujuanLabel').textContent = '+ Tambah tujuan baru';
    document.getElementById('tujuanLabel').style.color = 'var(--green-600)';
    document.getElementById('tujuanPanel').style.display = 'none';
    
    const quickInput = document.getElementById('quickAddTujuanInput');
    quickInput.style.display = 'block';
    quickInput.setAttribute('required', 'required');
    quickInput.focus();
}

</script>
@endpush