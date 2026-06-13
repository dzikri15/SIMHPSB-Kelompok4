{{-- ALERT PAGE --}}
@extends('layout.admin')

@section('title', 'Alert Stok')
@section('page-title', 'Alert Stok')
@section('page-subtitle', 'Notifikasi otomatis saat stok mendekati batas minimum')

@section('content')

@if(session('warning'))
<div id="warningModal" class="modal-overlay active" onclick="if(event.target === this) this.classList.remove('active')">
    <div class="modal-box">
        <div class="modal-icon">⚠️</div>
        <h3 class="modal-title" style="color:#d97706;">Tidak Bisa Diselesaikan</h3>
        <p class="modal-message">{{ session('warning') }}</p>
        <div class="modal-actions">
            <button class="btn-confirm" style="background:#d97706;" onclick="closeWarningModal()">Mengerti</button>
        </div>
    </div>
</div>
<script>
function closeWarningModal() {
    document.getElementById('warningModal').classList.remove('active');
}
</script>
@endif

@if(session('success'))
<div id="successModal" class="modal-overlay active">
    <div class="modal-box">
        <div class="modal-icon">✅</div>
        <h3 class="modal-title">Berhasil</h3>
        <p class="modal-message">{{ session('success') }}</p>
        <div class="modal-actions">
            <button class="btn-confirm" onclick="document.getElementById('successModal').classList.remove('active')">OK</button>
        </div>
    </div>
</div>
@endif

@if ($errors->any())
    <div class="alert-banner danger" style="margin-bottom:20px;">
        <i class="fas fa-exclamation-circle"></i>
        <div>{{ $errors->first() }}</div>
    </div>
@endif

@if (session('success'))
    <div class="alert-banner success" style="margin-bottom:20px;">
        <i class="fas fa-check-circle"></i>
        <div>{{ session('success') }}</div>
    </div>
@endif

{{-- BATAS MINIMUM KONFIGURASI --}}
<div class="grid-2" style="margin-bottom:24px;">
    <div class="card">
        <div class="card-header">
            <div>
                <div class="card-title">Konfigurasi Batas Minimum</div>
                <div class="card-subtitle">Sistem akan memicu alert jika stok berada di bawah batas minimum</div>
            </div>
            <button class="btn btn-primary btn-sm" onclick="openModal('modalKonfigAlert')">
                <i class="fas fa-cog"></i> Ubah
            </button>
        </div>
        <div class="card-body">
            <style>
            .modal-overlay {
    position: fixed; inset: 0; background: rgba(0,0,0,0.5);
    display: flex; align-items: center; justify-content: center;
    opacity: 0; visibility: hidden; transition: opacity 0.3s ease;
    z-index: 99999;
    pointer-events: none;
}
.modal-overlay.active { 
    opacity: 1; 
    visibility: visible; 
    pointer-events: auto;
}

.modal-box {
    background: #fff; border-radius: 16px; padding: 28px; width: 360px;
    text-align: center; transform: scale(0.9) translateY(20px); opacity: 0;
    transition: all 0.3s ease;
    box-shadow: 0 20px 40px rgba(0,0,0,0.2);
}
.modal-overlay.active .modal-box { transform: scale(1) translateY(0); opacity: 1; }
.modal-icon { font-size: 40px; margin-bottom: 8px; }
.modal-title { font-size: 18px; font-weight: 700; color: #2E7D32; margin-bottom: 8px; }
.modal-message { font-size: 14px; color: #555; margin-bottom: 20px; }
.modal-actions { display: flex; gap: 10px; justify-content: center; }
.btn-confirm {
    padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer;
    font-size: 14px; font-weight: 600; transition: 0.2s;
    background: #2E7D32; color: #fff;
}
.btn-confirm:hover { background: #256428; }
                .alert-stock-card { background: var(--surface-2); border-radius: 16px; padding: 18px; }
                .stock-status-pill { display:inline-flex;align-items:center;gap:8px;padding:6px 12px;border-radius:999px;font-size:12px;font-weight:700;}
                .stock-status-pill.red { background: var(--red-100); color: #991b1b; }
                .stock-status-pill.amber { background: var(--amber-100); color: #92400e; }
                .stock-status-pill.green { background: var(--green-100); color: var(--green-700); }
                .progress-bar { background: var(--surface); border: 1px solid var(--border); border-radius: 999px; overflow: hidden; height: 10px; }
                .progress-fill { height: 100%; transition: width .3s ease; }
            </style>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                @foreach($stokCards as $card)
                    @php
                        $status = 'Aman';
                        $statusClass = 'green';
                        if ($card['stok'] < $card['batas']) {
                            $status = 'Kritis';
                            $statusClass = 'red';
                        } elseif ($card['stok'] < $card['batas'] * 1.5) {
                            $status = 'Peringatan';
                            $statusClass = 'amber';
                        }
                        $progress = $card['kapasitas'] > 0 ? min(100, round(($card['stok'] / $card['kapasitas']) * 100)) : 0;
                    @endphp
                    <div class="alert-stock-card">
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">
                            <div>
                                <div style="font-size:13px;color:var(--text-muted);margin-bottom:8px;"><img src="https://raw.githubusercontent.com/NoahMikhailovna/foto/c45c72f9adca95001eefebd49d7581e89d0de508/padi_logo_fitted.svg" alt="Padi" style="width:16px;height:16px;vertical-align:middle;margin-right:6px;display:inline-block;"> {{ $card['komoditas'] }}</div>
                                <div style="font-size:28px;font-weight:800;color:var(--text-primary);">{{ number_format($card['stok']) }} kg</div>
                            </div>
                            <span class="stock-status-pill {{ $statusClass }}">{{ $status }}</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;gap:16px;margin-bottom:12px;">
                            <div>
                                <div style="font-size:11.5px;color:var(--text-muted);">Batas minimum</div>
                                <div style="font-size:16px;font-weight:700;">{{ number_format($card['batas']) }} kg</div>
                            </div>
                            <div style="text-align:right;">
                                <div style="font-size:11.5px;color:var(--text-muted);">Kapasitas</div>
                                <div style="font-size:16px;font-weight:700;">{{ number_format($card['kapasitas']) }} kg</div>
                            </div>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width:{{ $progress }}%;background:var(--{{ $statusClass }}-500);"></div>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:12px;color:var(--text-muted);margin-top:8px;">
                            <span>{{ $progress }}% dari kapasitas</span>
                            <span>{{ number_format(max(0, $card['kapasitas'] - $card['stok'])) }} kg tersisa</span>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div class="card-title">Ringkasan Status Alert</div>
        </div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:14px;">
                <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px;background:var(--red-100);border-radius:10px;">
                    <div style="display:flex;align-items:center;gap:10px;">
                        <i class="fas fa-circle-exclamation" style="color:var(--red-500);font-size:18px;"></i>
                        <span style="font-weight:600;color:#991b1b;">Alert Aktif</span>
                    </div>
                    <span id="count-aktif" style="font-size:22px;font-weight:800;color:var(--red-500);">{{ $alertAktif ?? 0 }}</span>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px;background:var(--amber-100);border-radius:10px;">
                    <div style="display:flex;align-items:center;gap:10px;">
                        <i class="fas fa-clock" style="color:var(--amber-500);font-size:18px;"></i>
                        <span style="font-weight:600;color:#92400e;">Dalam Penanganan</span>
                    </div>
                    <span id="count-proses" style="font-size:22px;font-weight:800;color:var(--amber-500);">{{ $alertProses ?? 1 }}</span>
                </div>
                <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px;background:var(--green-100);border-radius:10px;">
                    <div style="display:flex;align-items:center;gap:10px;">
                        <i class="fas fa-check-circle" style="color:var(--green-600);font-size:18px;"></i>
                        <span style="font-weight:600;color:var(--green-700);">Sudah Ditangani</span>
                    </div>
                    <span id="count-selesai" style="font-size:22px;font-weight:800;color:var(--green-600);">{{ $alertSelesai ?? 5 }}</span>
                </div>
            </div>
        </div>
    </div>
</div>

{{-- DAFTAR ALERT --}}
<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Riwayat Alert</div>
            <div class="card-subtitle">Semua notifikasi sistem, terbaru di atas</div>
        </div>
        <div style="display:flex;gap:8px;">
            <select id="filterStatus" onchange="filterAlert()" style="width:auto;min-width:160px;padding:8px 12px;border-radius:8px;border:1.5px solid var(--border);font-size:13px;font-family:inherit;">
                <option value="" {{ $selectedStatus === '' ? 'selected' : '' }}>Semua Status</option>
                <option value="aktif" {{ $selectedStatus === 'aktif' ? 'selected' : '' }}>Aktif</option>
                <option value="dalam_penanganan" {{ $selectedStatus === 'dalam_penanganan' ? 'selected' : '' }}>Dalam Penanganan</option>
                <option value="selesai" {{ $selectedStatus === 'selesai' ? 'selected' : '' }}>Sudah Ditangani</option>
            </select>
        </div>
    </div>

    <div class="table-container">
        <table class="data-table" id="tableAlert">
            <thead>
                <tr>
                    <th>Waktu</th>
                    <th>Komoditas</th>
                    <th>Stok Saat Alert</th>
                    <th>Batas Minimum</th>
                    <th>Status</th>
                    <th>Ditangani Oleh</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse(($alertList ?? []) as $a)
                    @php
                        $normalizedStatus = in_array($a->status, ['proses', 'dalam_penanganan']) ? 'dalam_penanganan' : $a->status;
                        $statusLabel = $normalizedStatus === 'aktif' ? 'Aktif' : ($normalizedStatus === 'dalam_penanganan' ? 'Dalam Penanganan' : 'Sudah Ditangani');
                        $statusClass = $normalizedStatus === 'aktif' ? 'red' : ($normalizedStatus === 'dalam_penanganan' ? 'amber' : 'green');
                        $statusIcon = $normalizedStatus === 'aktif' ? 'circle-exclamation' : ($normalizedStatus === 'dalam_penanganan' ? 'clock' : 'check');
                    @endphp
                    <tr class="alert-row" data-status="{{ $normalizedStatus }}" data-id="{{ $a->id }}">
                        <td style="font-size:12.5px;">
                            {{ $a->created_at ? $a->created_at->format('d M Y H:i') : '-' }}
                        </td>
                        <td>
                            <span class="badge badge-{{ $a->komoditas == 'Beras' ? 'blue' : 'amber' }}">
                                {{ $a->komoditas }}
                            </span>
                        </td>
                        <td>
                            <strong style="color:var(--red-500);">{{ number_format($a->stok_saat_ini) }} kg</strong>
                        </td>
                        <td><strong>{{ number_format($a->batas_minimum) }} kg</strong></td>
                        <td>
                            <span class="badge badge-{{ $statusClass }}" id="status-{{ $a->id }}">
                                <i class="fas fa-{{ $statusIcon }}"></i>
                                {{ $statusLabel }}
                            </span>
                        </td>
                        <td style="font-size:12.5px;color:var(--text-secondary);">
                            {{ $a->handler->name ?? '-' }}
                        </td>
                        <td>
                            @if($normalizedStatus == 'aktif')
                                <button type="button" class="btn btn-primary btn-sm" onclick="tandaiDitangani({{ $a->id }})">
                                    <i class="fas fa-check"></i> Tandai Ditangani
                                </button>
                            @elseif($normalizedStatus == 'dalam_penanganan')
                                <button type="button" class="btn btn-success btn-sm" onclick="tandaiSelesai({{ $a->id }})">
                                    <i class="fas fa-flag-checkered"></i> Selesai
                                </button>
                            @else
                                <span style="font-size:12px;color:var(--text-muted);">✓ Selesai</span>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" style="text-align:center;padding:32px;color:var(--text-muted);">
                            <i class="fas fa-inbox" style="font-size:32px;margin-bottom:12px;display:block;"></i>
                            Tidak ada alert
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

{{-- MODAL KONFIGURASI ALERT --}}
<div class="modal-overlay" id="modalKonfigAlert">
    <div class="modal">
        <div class="modal-header">
            <div class="modal-title">Konfigurasi Batas Minimum Alert</div>
            <button class="modal-close" onclick="closeModal('modalKonfigAlert')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="{{ route('admin.alert.konfigurasi') }}">
            @csrf @method('PUT')
            <div class="modal-body">
                <div class="alert-banner warning" style="margin-bottom:20px;">
                    <i class="fas fa-info-circle"></i>
                    <div>Sistem menggunakan nilai default (400 kg beras, 1000 kg gabah) jika belum dikonfigurasi.</div>
                </div>
                <div class="grid-2">
                    <div class="form-group">
                        <label>Batas Minimum Beras (kg)</label>
                        <input type="number" name="batas_min_beras" value="{{ $stokCards[0]['batas'] ?? 400 }}" min="0" required>
                        <div class="form-hint">Default: 400 kg</div>
                    </div>
                    <div class="form-group">
                        <label>Batas Minimum Gabah (kg)</label>
                        <input type="number" name="batas_min_gabah" value="{{ $stokCards[1]['batas'] ?? 1000 }}" min="0" required>
                        <div class="form-hint">Default: 1000 kg</div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalKonfigAlert')">Batal</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Simpan Konfigurasi</button>
            </div>
        </form>
    </div>
</div>

@endsection

@push('scripts')
<script>
function filterAlert() {
    const selected = document.getElementById('filterStatus').value;
    const url = new URL(window.location.href);
    if (selected) {
        url.searchParams.set('status', selected);
    } else {
        url.searchParams.delete('status');
    }
    window.location.href = url.toString();
}

function updateSummaryCounters(oldStatus, newStatus) {
    const counters = {
        aktif: document.getElementById('count-aktif'),
        dalam_penanganan: document.getElementById('count-proses'),
        selesai: document.getElementById('count-selesai'),
    };

    if (oldStatus && oldStatus !== newStatus) {
        const oldCounter = counters[oldStatus];
        const newCounter = counters[newStatus];
        if (oldCounter) {
            oldCounter.textContent = Math.max(0, parseInt(oldCounter.textContent || '0') - 1);
        }
        if (newCounter) {
            newCounter.textContent = (parseInt(newCounter.textContent || '0') + 1).toString();
        }
    }
}

function renderStatusBadge(alertId, status) {
    const statusEl = document.getElementById(`status-${alertId}`);
    const badgeMap = {
        aktif: { class: 'red', icon: 'circle-exclamation', text: 'Aktif' },
        dalam_penanganan: { class: 'amber', icon: 'clock', text: 'Dalam Penanganan' },
        selesai: { class: 'green', icon: 'check', text: 'Sudah Ditangani' },
    };
    const badge = badgeMap[status] || badgeMap.aktif;

    if (statusEl) {
        statusEl.className = `badge badge-${badge.class}`;
        statusEl.innerHTML = `<i class="fas fa-${badge.icon}"></i> ${badge.text}`;
    }
}

function renderActionCell(alertId, status) {
    const row = document.querySelector(`tr.alert-row[data-id="${alertId}"]`);
    if (!row) return;
    const cell = row.querySelector('td:last-child');
    if (!cell) return;

    if (status === 'aktif') {
        cell.innerHTML = `<button type="button" class="btn btn-primary btn-sm" onclick="tandaiDitangani(${alertId})"><i class="fas fa-check"></i> Tandai Ditangani</button>`;
    } else if (status === 'dalam_penanganan') {
        cell.innerHTML = `<button type="button" class="btn btn-success btn-sm" onclick="tandaiSelesai(${alertId})"><i class="fas fa-flag-checkered"></i> Selesai</button>`;
    } else {
        cell.innerHTML = '<span style="font-size:12px;color:var(--text-muted);">✓ Selesai</span>';
    }
}

function postUpdateAlert(alertId, newStatus, message) {
    const row = document.querySelector(`tr.alert-row[data-id="${alertId}"]`);
    const oldStatus = row ? row.dataset.status : null;

    renderStatusBadge(alertId, newStatus);
    renderActionCell(alertId, newStatus);

    if (row) {
        row.dataset.status = newStatus;
    }

    updateSummaryCounters(oldStatus, newStatus);
    showSuccessMessage(message || 'Alert berhasil diperbarui');
}

function showWarningModal(message) {
    let modal = document.getElementById('warningModalJS');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'warningModalJS';
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal-box">
                <div class="modal-icon">⚠️</div>
                <h3 class="modal-title" style="color:#d97706;">Tidak Bisa Diselesaikan</h3>
                <p class="modal-message" id="warningModalMsg"></p>
                <div class="modal-actions">
                    <button class="btn-confirm" style="background:#d97706;" onclick="this.closest('.modal-overlay').classList.remove('active')">Mengerti</button>
                </div>
            </div>`;
        document.body.appendChild(modal);
    }
    modal.querySelector('#warningModalMsg').textContent = message;
    requestAnimationFrame(() => modal.classList.add('active'));
}

function tandaiDitangani(alertId) {
    if (!confirm('Tandai alert ini sebagai sedang ditangani?')) return;

    fetch(`{{ route('admin.alert.tangani', ':id') }}`.replace(':id', alertId), {
        method: 'PATCH',
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
        body: JSON.stringify({ status: 'dalam_penanganan' })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            postUpdateAlert(alertId, 'dalam_penanganan', data.message || 'Alert sedang ditangani');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Gagal memperbarui alert');
    });
}

function tandaiSelesai(alertId) {
    if (!confirm('Tandai alert ini sebagai sudah selesai?')) return;

    fetch(`{{ route('admin.alert.tangani', ':id') }}`.replace(':id', alertId), {
        method: 'PATCH',
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
        body: JSON.stringify({ status: 'selesai' })
    })
    .then(response => response.json())
    .then(data => {
    if (data.success) {
        postUpdateAlert(alertId, 'selesai', data.message || 'Alert berhasil diselesaikan');
    } else {
        showWarningModal(data.message);
    }
})
    .catch(error => {
        console.error('Error:', error);
        alert('Gagal memperbarui alert');
    });
}

function showSuccessMessage(message) {
    const alertBanner = document.createElement('div');
    alertBanner.className = 'alert-banner success';
    alertBanner.style.cssText = 'margin-bottom:20px;animation:slideDown 0.3s ease-out;';
    alertBanner.innerHTML = `<i class="fas fa-check-circle"></i><div>${message}</div>`;
    const mainContent = document.querySelector('main');
    if (mainContent) {
        mainContent.insertBefore(alertBanner, mainContent.firstChild);
        setTimeout(() => alertBanner.remove(), 3000);
    }
}
</script>
@endpush
