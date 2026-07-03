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
                <div class="progress-fill" style="width:{{ min(100, round((($stokBeras ?? 450)/1000)*100)) }}%;background:var(--green-500);"></div>
            </div>
            <div style="font-size:11px;color:var(--text-muted);margin-top:4px;">{{ round((($stokBeras ?? 450)/1000)*100) }}% kapasitas (max 1.000 kg)</div>
        </div>
    </div>

    <div class="stat-card amber">
        <div class="stat-icon"><i class="fas fa-seedling"></i></div>
        <div id="statStokGabahPage" class="stat-value">{{ number_format($stokGabah ?? 800) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Saldo Gabah</div>
        <div style="margin-top:10px;">
            <div class="progress-bar">
                <div class="progress-fill" style="width:{{ min(100, round((($stokGabah ?? 800)/2000)*100)) }}%;background:var(--amber-500);"></div>
            </div>
            <div style="font-size:11px;color:var(--text-muted);margin-top:4px;">{{ round((($stokGabah ?? 800)/2000)*100) }}% kapasitas (max 2.000 kg)</div>
        </div>
    </div>

    <div class="stat-card blue">
        <div class="stat-icon"><i class="fas fa-arrow-circle-down"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format(($masukBerasBulanIni ?? 0) + ($masukGabahBulanIni ?? 0)) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Masuk Bulan Ini</div>
        <div class="stat-change up"><i class="fas fa-arrow-up"></i> Gabah + Beras</div>
    </div>

    <div class="stat-card red">
        <div class="stat-icon"><i class="fas fa-arrow-circle-up"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format(($keluarBerasBulanIni ?? 0) + ($keluarGabahBulanIni ?? 0)) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Keluar Bulan Ini</div>
        <div class="stat-change down"><i class="fas fa-arrow-down"></i> Distribusi aktif</div>
    </div>

    <div class="stat-card blue" style="border-top:3px solid var(--blue-500);">
        <div class="stat-icon"><i class="fas fa-inbox"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($masukBerasBulanIni ?? 0) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Masuk Beras Bulan Ini</div>
    </div>

    <div class="stat-card amber" style="border-top:3px solid var(--amber-500);">
        <div class="stat-icon"><i class="fas fa-inbox"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($masukGabahBulanIni ?? 0) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Masuk Gabah Bulan Ini</div>
    </div>

    <div class="stat-card red" style="border-top:3px solid var(--red-500);">
        <div class="stat-icon"><i class="fas fa-arrow-circle-up"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($keluarBerasBulanIni ?? 0) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Keluar Beras Bulan Ini</div>
    </div>

    <div class="stat-card red" style="border-top:3px solid var(--red-500);">
        <div class="stat-icon"><i class="fas fa-arrow-circle-up"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($keluarGabahBulanIni ?? 0) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Keluar Gabah Bulan Ini</div>
    </div>
</div>

<div class="card">
    {{-- TOOLBAR --}}
    <div class="toolbar">
        <div class="search-input-wrap">
            <i class="fas fa-search"></i>
            <input type="text" id="searchStok" placeholder="Cari tujuan, komoditas..." oninput="filterStok()">
        </div>

        <select id="filterJenis" onchange="filterStok()" style="width:auto;min-width:130px;">
            <option value="">Semua Jenis</option>
            <option value="masuk">Masuk</option>
            <option value="keluar">Keluar</option>
        </select>

        <select id="filterKomoditas" onchange="filterStok()" style="width:auto;min-width:130px;">
            <option value="">Semua Komoditas</option>
            <option value="beras">Beras</option>
            <option value="gabah">Gabah</option>
        </select>

        <input type="date" id="filterTanggal" onchange="filterStok()" title="Filter tanggal" style="width:auto;">

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
                                <button class="btn btn-danger btn-icon btn-sm" onclick="event.stopPropagation(); performToggle({{ $t->id }})" title="Batalkan transaksi"><i class="fas fa-times"></i></button>
                            @else
                                <button class="btn btn-primary btn-icon btn-sm" onclick="event.stopPropagation(); performToggle({{ $t->id }})" title="Aktifkan kembali"><i class="fas fa-redo"></i></button>
                            @endif
                        </td>
                    </tr>
                @empty
                    @php
                        $rows = [
                            ['Hari ini 08:00', 'masuk',  'Gabah', 500, 'Petani: Silvy H.', 'Penerimaan panen', 800,   'Admin'],
                            ['Hari ini 07:30', 'keluar', 'Beras', 155, 'MBG Dapur 1',      'Distribusi dapur', 450,   'Petugas A'],
                            ['Hari ini 07:30', 'keluar', 'Beras', 155, 'MBG Dapur 2',      'Stok permintaan', 605,   'Petugas A'],
                            ['Kemarin 14:00',  'keluar', 'Beras', 100, 'Toko Rudi',         'Pengiriman lokal', 760,   'Petugas B'],
                            ['Kemarin 10:00',  'masuk',  'Beras', 300, 'Hasil Giling',      'Gabah hasil kering', 860,   'Admin'],
                            ['Kemarin 09:00',  'keluar', 'Gabah', 490, 'Proses Giling',    'Bahan giling', 1800,   'Admin'],
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
        @if($transaksis->hasPages())
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
                    <div style="display:flex;gap:8px;align-items:center;">
                        <select name="tujuan_distribusi" id="tujuanSelect" style="flex:1;">
                            <option value="">Pilih tujuan</option>
                            @foreach(($tujuans ?? []) as $t)
                                <option value="{{ $t->nama }}">{{ $t->nama }}</option>
                            @endforeach
                            <option value="__add_new">+ Tambah tujuan baru</option>
                        </select>
                        <input type="text" id="quickAddTujuanInput" placeholder="Tambah tujuan..." style="display:none;min-width:160px;" />
                    </div>
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
            const actionCell = row.querySelector('td:nth-child(11)');
            if (statusCell) {
                statusCell.innerHTML = data.status === 'aktif'
                    ? '<span class="badge badge-green">Aktif</span>'
                    : '<span class="badge badge-gray">Dibatalkan</span>';
            }
            if (actionCell) {
                if (data.status === 'aktif') {
                    actionCell.querySelectorAll('button').forEach(b => b.remove());
                    const btn = document.createElement('button');
                    btn.className = 'btn btn-danger btn-icon btn-sm';
                    btn.title = 'Batalkan transaksi';
                    btn.onclick = () => performToggle(id);
                    btn.innerHTML = '<i class="fas fa-times"></i>';
                    actionCell.appendChild(btn);
                } else {
                    actionCell.querySelectorAll('button').forEach(b => b.remove());
                    const btn = document.createElement('button');
                    btn.className = 'btn btn-primary btn-icon btn-sm';
                    btn.title = 'Aktifkan kembali';
                    btn.onclick = () => performToggle(id);
                    btn.innerHTML = '<i class="fas fa-redo"></i>';
                    actionCell.appendChild(btn);
                }
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

function filterStok() {
    const q = document.getElementById('searchStok').value.toLowerCase();
    const j = document.getElementById('filterJenis').value.toLowerCase();
    const k = document.getElementById('filterKomoditas').value.toLowerCase();
    document.querySelectorAll('#tableStok tbody tr').forEach(row => {
        const text = row.textContent.toLowerCase();
        const matchQ = text.includes(q);
        const matchJ = j === '' || text.includes(j);
        const matchK = k === '' || text.includes(k);
        row.style.display = (matchQ && matchJ && matchK) ? '' : 'none';
    });
}

function onKomoditasChange() {
    const komoditas = document.getElementById('komoditasTransaksi').value;
    const jenis = document.getElementById('jenisTransaksi');
    const note = document.getElementById('gabahMasukNote');
    
    // Sembunyikan opsi "Masuk" jika komoditas "Gabah"
    for (let i = 0; i < jenis.options.length; i++) {
        if (jenis.options[i].value === 'masuk') {
            jenis.options[i].style.display = (komoditas === 'Gabah') ? 'none' : 'block';
        }
    }
    
    // Jika jenis saat ini "Masuk" dan berubah ke "Gabah", ganti jadi "Keluar" otomatis
    if (komoditas === 'Gabah' && jenis.value === 'masuk') {
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
    const tujuanSelect = document.getElementById('tujuanSelect');

    if (jenis === 'keluar' && komoditas === 'Beras') {
        tujuan.style.display = 'block';
        if (tujuanSelect) tujuanSelect.setAttribute('required', 'required');
    } else {
        tujuan.style.display = 'none';
        if (tujuanSelect) tujuanSelect.removeAttribute('required');
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
    const tujuanSelect = document.getElementById('tujuanSelect');
    const quickInput = document.getElementById('quickAddTujuanInput');
    if (tujuanSelect) {
        tujuanSelect.addEventListener('change', function() {
            if (this.value === '__add_new') {
                quickInput.style.display = 'block';
                quickInput.focus();
            } else {
                quickInput.style.display = 'none';
            }
        });
    }

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
</script>
@endpush