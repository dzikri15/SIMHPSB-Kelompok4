@extends('layout.admin')

@section('title', 'Stok Gudang')
@section('page-title', 'Stok Gudang')
@section('page-subtitle', 'Transaksi masuk/keluar dan saldo stok real-time')

@section('content')

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
        <div class="stat-value" style="font-size:20px;">{{ number_format($masukBulanIni ?? 1200) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Masuk Bulan Ini</div>
        <div class="stat-change up"><i class="fas fa-arrow-up"></i> Gabah + Beras</div>
    </div>

    <div class="stat-card red">
        <div class="stat-icon"><i class="fas fa-arrow-circle-up"></i></div>
        <div class="stat-value" style="font-size:20px;">{{ number_format($keluarBulanIni ?? 965) }} <small style="font-size:13px;color:var(--text-muted);">kg</small></div>
        <div class="stat-label">Keluar Bulan Ini</div>
        <div class="stat-change down"><i class="fas fa-arrow-down"></i> Distribusi aktif</div>
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
                    <th>Saldo Setelah</th>
                    <th>Dicatat Oleh</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($transaksis ?? [] as $i => $t)
                    <tr>
                        <td style="color:var(--text-muted);font-size:12px;">{{ $i+1 }}</td>
                        <td>{{ $t->tanggal }}</td>
                        <td>
                            <span class="badge badge-{{ $t->jenis == 'masuk' ? 'green' : 'red' }}">
                                <i class="fas fa-{{ $t->jenis == 'masuk' ? 'arrow-down' : 'arrow-up' }}"></i>
                                {{ ucfirst($t->jenis) }}
                            </span>
                        </td>
                        <td><span class="badge badge-{{ $t->komoditas == 'Beras' ? 'blue' : 'amber' }}">{{ $t->komoditas }}</span></td>
                        <td><strong>{{ number_format($t->jumlah) }}</strong></td>
                        <td>{{ $t->keterangan }}</td>
                        <td>{{ number_format($t->saldo_setelah) }} kg</td>
                        <td style="font-size:12px;color:var(--text-muted);">{{ $t->user->name ?? '-' }}</td>
                        <td>
                            <button class="btn btn-secondary btn-icon btn-sm"><i class="fas fa-eye"></i></button>
                        </td>
                    </tr>
                @empty
                    @php
                        $rows = [
                            ['Hari ini 08:00', 'masuk',  'Gabah', 500, 'Petani: Silvy H.', 800,   'Admin'],
                            ['Hari ini 07:30', 'keluar', 'Beras', 155, 'MBG Dapur 1',      450,   'Petugas A'],
                            ['Hari ini 07:30', 'keluar', 'Beras', 155, 'MBG Dapur 2',      605,   'Petugas A'],
                            ['Kemarin 14:00',  'keluar', 'Beras', 100, 'Toko Rudi',         760,   'Petugas B'],
                            ['Kemarin 10:00',  'masuk',  'Beras', 300, 'Hasil Giling',      860,   'Admin'],
                            ['Kemarin 09:00',  'keluar', 'Gabah', 490, 'Proses Giling',    1800,   'Admin'],
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
                            <td><strong>{{ number_format($r[5]) }}</strong> kg</td>
                            <td style="font-size:12px;color:var(--text-muted);">{{ $r[6] }}</td>
                            <td><button class="btn btn-secondary btn-icon btn-sm"><i class="fas fa-eye"></i></button></td>
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
                        <label>Tanggal <span style="color:var(--red-500)">*</span></label>
                        <input type="date" name="tanggal" required value="{{ date('Y-m-d') }}">
                    </div>
                </div>

                <div class="form-group" id="tujuanGroup" style="display:none;">
                    <label>Tujuan Distribusi <span style="color:var(--red-500)">*</span></label>
                    <select name="tujuan_distribusi">
                        <option value="">Pilih tujuan</option>
                        <option value="MBG Dapur 1">MBG Dapur 1</option>
                        <option value="MBG Dapur 2">MBG Dapur 2</option>
                        <option value="MBG Dapur 3">MBG Dapur 3</option>
                        <option value="Toko Rudi">Toko Rudi</option>
                        <option value="Toko Barokah">Toko Barokah</option>
                        <option value="Lainnya">Lainnya</option>
                    </select>
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
</script>
@endpush
