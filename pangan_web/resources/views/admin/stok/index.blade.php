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
        <div class="stat-value">{{ number_format($stokBeras ?? 450) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
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
        <div class="stat-value">{{ number_format($stokGabah ?? 800) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
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
        <div class="stat-icon"><i class="fas fa-outbox"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($keluarBerasBulanIni ?? 0) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Keluar Beras Bulan Ini</div>
    </div>

    <div class="stat-card red" style="border-top:3px solid var(--gray-700);">
        <div class="stat-icon"><i class="fas fa-outbox"></i></div>
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
                    <th>Dicatat Oleh</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($transaksis ?? [] as $i => $t)
                    <tr>
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
                        <td style="font-size:12px;color:var(--text-muted);">{{ optional($t->user)->name ?? '-' }}</td>
                        <td>
                            <a href="{{ route('admin.stok.show', $t->id) }}" class="btn btn-secondary btn-icon btn-sm" title="Lihat detail transaksi">
                                <i class="fas fa-eye"></i>
                            </a>
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
    </div>
</div>

{{-- MODAL CATAT TRANSAKSI --}}
<div class="modal-overlay" id="modalTransaksi">
    <div class="modal">
        <div class="modal-header">
            <div class="modal-title">Catat Transaksi Stok</div>
            <button class="modal-close" onclick="closeModal('modalTransaksi')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="{{ route('admin.stok.store') }}">
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
                    </div>
                    <div class="form-group">
                        <label>Komoditas <span style="color:var(--red-500)">*</span></label>
                        <select name="komoditas" required>
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
                    <input type="text" name="keterangan" placeholder="Contoh: Petani Budi, Hasil Giling, dll." required>
                </div>

                <div class="form-group">
                    <label>Catatan Tambahan</label>
                    <textarea name="catatan" rows="2" placeholder="Opsional"></textarea>
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

function toggleTujuan() {
    const jenis = document.getElementById('jenisTransaksi').value;
    const tujuan = document.getElementById('tujuanGroup');
    const warning = document.getElementById('stokWarning');
    tujuan.style.display = jenis === 'keluar' ? 'block' : 'none';
    warning.style.display = jenis === 'keluar' ? 'flex' : 'none';
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
});
</script>
@endpush
