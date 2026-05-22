@extends('layout.admin')

@section('title', isset($harga) ? 'Edit Konfigurasi Harga' : 'Tambah Konfigurasi Harga')
@section('page-title', isset($harga) ? 'Edit Konfigurasi Harga' : 'Tambah Konfigurasi Harga')
@section('page-subtitle', 'Atur harga beli gabah, ongkos giling, dan harga jual beras')

@section('content')
<style>
    .calc-card-border {
        border: 1px solid rgba(148, 163, 184, 0.35);
        transition: border-color 0.25s ease, box-shadow 0.25s ease;
    }
    .calc-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 0.35rem;
        padding: 0.45rem 0.9rem;
        border-radius: 999px;
        font-size: 0.82rem;
        font-weight: 700;
        color: #ffffff;
        white-space: nowrap;
    }
    .calc-badge.green { background: #16a34a; }
    .calc-badge.blue { background: #2563eb; }
    .calc-badge.yellow { background: #f59e0b; }
    .calc-badge.red { background: #dc2626; }
    .progress-track {
        position: relative;
        display: block;
        width: 100%;
        height: 18px;
        border-radius: 999px;
        background: rgba(148, 163, 184, 0.15);
        overflow: hidden;
    }
    .progress-fill {
        height: 100%;
        width: 0;
        border-radius: 999px;
        transition: width 0.32s ease, background-color 0.32s ease;
        background: #16a34a;
    }
    .progress-label {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-size: 0.78rem;
        font-weight: 600;
        color: var(--surface-900);
        pointer-events: none;
    }
    .fade-value {
        display: inline-block;
        opacity: 1;
        transition: opacity 0.18s ease;
    }
    .fade-out {
        opacity: 0;
    }
    .tooltip-inline {
        position: relative;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 22px;
        height: 22px;
        border-radius: 50%;
        background: var(--surface-2);
        color: var(--text-secondary);
        font-size: 0.8rem;
        cursor: help;
    }
    .tooltip-inline:hover .tooltip-text,
    .tooltip-inline:focus-within .tooltip-text {
        opacity: 1;
        visibility: visible;
    }
    .tooltip-text {
        position: absolute;
        bottom: calc(100% + 8px);
        left: 50%;
        transform: translateX(-50%);
        min-width: 220px;
        padding: 10px 12px;
        border-radius: 10px;
        background: rgba(15, 23, 42, 0.94);
        color: #f8fafc;
        font-size: 0.78rem;
        line-height: 1.4;
        text-align: left;
        opacity: 0;
        visibility: hidden;
        pointer-events: none;
        transition: opacity 0.18s ease, visibility 0.18s ease;
        z-index: 10;
        box-shadow: 0 12px 24px rgba(15, 23, 42, 0.18);
    }
</style>

@php
    $hargaBeli = old('harga_beli_gabah', $harga->harga_beli_gabah ?? 760000);
    $ongkosGiling = old('ongkos_giling', $harga->ongkos_giling ?? 700);
    $hargaJual = old('harga_jual_beras', $harga->harga_jual_beras ?? 13500);
    $rasioKonversi = old('rasio_konversi', $harga->rasio_konversi ?? 61.5);
    $hppDefault = round(($hargaBeli / 100) * $rasioKonversi + $ongkosGiling);
    $marginDefault = $hargaJual - $hppDefault;
    $marginPctDefault = $hargaJual > 0 ? number_format(($marginDefault / $hargaJual) * 100, 2, ',', '.') : '0,00';
@endphp

<div class="grid-2" style="margin-bottom:24px;">
    {{-- FORM HARGA --}}
    <div class="card">
        <div class="card-header">
            <div>
                <div class="card-title">{{ isset($harga) ? 'Edit Form' : 'Tambah Baru' }}</div>
                <div class="card-subtitle">Perubahan akan langsung mempengaruhi kalkulasi HPP & margin</div>
            </div>
            <a href="{{ route('admin.harga.index') }}" class="btn btn-secondary btn-sm"><i class="fas fa-arrow-left"></i> Kembali</a>
        </div>
        <div class="card-body">
            @if ($errors->any())
                <div style="background: var(--red-100); color: var(--red-700); padding: 12px; border-radius: 8px; margin-bottom: 16px;">
                    <ul style="margin: 0; padding-left: 20px;">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form method="POST" action="{{ isset($harga) ? route('admin.harga.update', $harga->id) : route('admin.harga.store') }}">
                @csrf
                @if(isset($harga))
                    @method('PUT')
                @endif

                <div class="form-group">
                    <label>Harga Beli Gabah (per 100 kg)</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;font-weight:600;">Rp</span>
                        <input type="text" name="harga_beli_gabah" id="harga_beli_gabah" class="currency-input" value="{{ number_format(intval(preg_replace('/\D/', '', $hargaBeli)), 0, ',', '.') }}"
                            style="padding-left:36px;" placeholder="760.000" inputmode="numeric" autocomplete="off" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Ongkos Giling (per kg beras)</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;font-weight:600;">Rp</span>
                        <input type="text" name="ongkos_giling" id="ongkos_giling" class="currency-input" value="{{ number_format(intval(preg_replace('/\D/', '', $ongkosGiling)), 0, ',', '.') }}"
                            style="padding-left:36px;" placeholder="700" inputmode="numeric" autocomplete="off" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Harga Jual Beras (per kg)</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;font-weight:600;">Rp</span>
                        <input type="text" name="harga_jual_beras" id="harga_jual_beras" class="currency-input" value="{{ number_format(intval(preg_replace('/\D/', '', $hargaJual)), 0, ',', '.') }}"
                            style="padding-left:36px;" placeholder="13.500" inputmode="numeric" autocomplete="off" required>
                    </div>
                    <div class="form-hint" id="hintHarga">Minimum HPP + margin 10%</div>
                </div>

                <div class="form-group">
                    <label>Rasio Konversi Gabah → Beras (%)</label>
                    <input type="number" name="rasio_konversi" id="rasio_konversi" value="{{ $rasioKonversi }}" step="0.1" min="50" max="70" required>
                    <div class="form-hint">Default: 61,5% (60–63 kg beras per 100 kg gabah)</div>
                </div>

                <div class="form-group">
                    <label>Berlaku Mulai Tanggal</label>
                    <input type="date" name="berlaku_mulai" value="{{ old('berlaku_mulai', isset($harga) ? $harga->berlaku_mulai->format('Y-m-d') : date('Y-m-d')) }}" required>
                </div>

                <div class="form-group" style="display:flex; align-items:center; gap:8px;">
                    <input type="checkbox" name="is_active" id="isActive" value="1" {{ old('is_active', $harga->is_active ?? true) ? 'checked' : '' }} style="width:auto; margin:0;">
                    <label for="isActive" style="margin:0; font-weight:normal; cursor:pointer;">Jadikan sebagai Konfigurasi Harga Aktif</label>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center;margin-top:16px;">
                    <i class="fas fa-save"></i> Simpan Konfigurasi
                </button>
            </form>
        </div>
    </div>

    {{-- KALKULASI HPP OTOMATIS --}}
    <div style="display:flex;flex-direction:column;gap:20px;">
        <div class="card calc-card-border" id="hasil_card">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;gap:12px;">
                <div>
                    <div class="card-title">Kalkulasi HPP Otomatis</div>
                </div>
                <span id="hasil_badge" class="calc-badge blue">Margin cukup</span>
            </div>
            <div class="card-body">
                <div style="background:var(--surface-2);border-radius:10px;padding:16px;margin-bottom:16px;">
                    <div style="font-size:12px;color:var(--text-muted);margin-bottom:12px;font-weight:600;">RUMUS HPP (per kg beras)</div>
                    <div style="font-size:13.5px;line-height:2;color:var(--text-secondary);">
                        HPP = (Harga Beli Gabah ÷ 100 × <em>konversi</em>) + Ongkos Giling<br>
                        <span id="formulaDisplay" style="font-size:12px;color:var(--text-muted);">= (Rp {{ number_format($hargaBeli, 0, ',', '.') }} &divide; 100 &times; {{ number_format($rasioKonversi, 1, ',', '.') }}) + Rp {{ number_format($ongkosGiling, 0, ',', '.') }}</span>
                    </div>
                </div>

                <div id="kalkulasiHPP" style="display:flex;flex-direction:column;gap:10px;">
                    <div style="display:flex;justify-content:space-between;padding:10px 14px;background:var(--surface-3);border-radius:8px;">
                        <span style="font-size:13px;color:var(--text-secondary);">HPP per kg beras</span>
                        <div style="display:flex;align-items:center;gap:8px;">
                            <strong id="hasil_hpp" class="fade-value">Rp {{ number_format($hppDefault, 0, ',', '.') }}</strong>
                            <span class="tooltip-inline" tabindex="0">?
                                <span class="tooltip-text" id="hasil_tooltip">HPP = (Rp {{ number_format($hargaBeli, 0, ',', '.') }} ÷ 100 × {{ number_format($rasioKonversi, 1, ',', '.') }}%) + Rp {{ number_format($ongkosGiling, 0, ',', '.') }} = Rp {{ number_format($hppDefault, 0, ',', '.') }}</span>
                            </span>
                        </div>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:10px 14px;background:var(--surface-3);border-radius:8px;">
                        <span style="font-size:13px;color:var(--text-secondary);">Harga Jual</span>
                        <strong id="hasil_harga_jual" class="fade-value">Rp {{ number_format($hargaJual, 0, ',', '.') }}</strong>
                    </div>
                    <div id="hasil_margin_row" style="display:flex;justify-content:space-between;padding:12px 14px;background:var(--green-100);border-radius:8px;">
                        <span style="font-size:13px;font-weight:600;color:var(--green-700);">Margin Kotor</span>
                        <strong id="hasil_margin" class="fade-value" style="color:var(--green-700);">Rp {{ number_format($marginDefault, 0, ',', '.') }} ({{ $marginPctDefault }}%)</strong>
                    </div>
                    <div class="progress-track">
                        <div class="progress-fill" id="hasil_progressbar"></div>
                        <span class="progress-label" id="hasil_progress_label">HPP menyerap {{ number_format(($hppDefault / max($hargaJual, 1)) * 100, 1, ',', '.') }}% dari harga jual</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<script>
function formatCurrency(input) {
    let raw = String(input.value).replace(/[^0-9]/g, '');
    if (raw === '') {
        input.value = '';
        return;
    }
    input.value = Number(raw).toLocaleString('id');
}

function normalizeCurrencyInputs(form) {
    form.querySelectorAll('.currency-input').forEach(el => {
        el.value = String(el.value).replace(/\D/g, '');
    });
}

function parseCurrency(value) {
    const cleaned = String(value)
        .replace(/\./g, '')
        .replace(/,/g, '.')
        .replace(/[^0-9.]/g, '');
    return parseFloat(cleaned) || 0;
}

function formatRupiah(amount) {
    return Number(amount).toLocaleString('id');
}

function animateText(element, text) {
    if (!element) return;
    element.classList.add('fade-out');
    window.setTimeout(() => {
        element.textContent = text;
        element.classList.remove('fade-out');
    }, 120);
}

function updateHPPPreview() {
    const hargaBeli = parseCurrency(document.getElementById('harga_beli_gabah').value);
    const ongkosGiling = parseCurrency(document.getElementById('ongkos_giling').value);
    const hargaJual = parseCurrency(document.getElementById('harga_jual_beras').value);
    const rasio = parseFloat(document.getElementById('rasio_konversi').value) || 0;

    const hpp = Math.round((hargaBeli / 100) * rasio + ongkosGiling);
    const margin = hargaJual - hpp;
    const pct = hargaJual > 0 ? ((margin / hargaJual) * 100).toFixed(2) : '0.00';

    animateText(document.getElementById('hasil_hpp'), `Rp ${formatRupiah(hpp)}`);
    animateText(document.getElementById('hasil_harga_jual'), `Rp ${formatRupiah(hargaJual)}`);
    animateText(document.getElementById('hasil_margin'), `Rp ${formatRupiah(margin)} (${pct}%)`);

    const formulaDisplay = document.getElementById('formulaDisplay');
    if (formulaDisplay) {
        formulaDisplay.textContent = `= (Rp ${formatRupiah(hargaBeli)} ÷ 100 × ${rasio}) + Rp ${formatRupiah(ongkosGiling)}`;
    }

    const tooltipText = document.getElementById('hasil_tooltip');
    if (tooltipText) {
        tooltipText.textContent = `HPP = (Rp ${formatRupiah(hargaBeli)} ÷ 100 × ${rasio}%) + Rp ${formatRupiah(ongkosGiling)} = Rp ${formatRupiah(hpp)}`;
    }

    const badge = document.getElementById('hasil_badge');
    const card = document.getElementById('hasil_card');
    const marginRow = document.getElementById('hasil_margin_row');
    const progressBar = document.getElementById('hasil_progressbar');
    const progressLabel = document.getElementById('hasil_progress_label');

    const status = hargaJual <= hpp
        ? { text: 'RUGI', badgeClass: 'red', rowBg: 'rgba(254, 205, 211, 0.95)', rowText: '#991b1b', border: '#dc2626', progress: '#dc2626' }
        : pct < 10
        ? { text: 'Margin terlalu kecil', badgeClass: 'yellow', rowBg: 'rgba(254, 243, 199, 0.95)', rowText: '#92400e', border: '#f59e0b', progress: '#f59e0b' }
        : pct < 30
        ? { text: 'Margin cukup', badgeClass: 'blue', rowBg: 'rgba(224, 231, 255, 0.95)', rowText: '#1d4ed8', border: '#2563eb', progress: '#2563eb' }
        : { text: 'Margin sehat', badgeClass: 'green', rowBg: 'rgba(220, 252, 231, 0.95)', rowText: '#166534', border: '#16a34a', progress: '#16a34a' };

    if (badge) {
        badge.className = `calc-badge ${status.badgeClass}`;
        badge.textContent = status.text;
    }
    if (card) {
        card.style.borderColor = status.border;
        card.style.boxShadow = `0 12px 24px rgba(15, 23, 42, 0.08)`;
    }
    if (marginRow) {
        marginRow.style.background = status.rowBg;
        const label = marginRow.querySelector('span');
        if (label) label.style.color = status.rowText;
    }

    const share = hargaJual > 0 ? Math.min(100, Math.max(0, (hpp / hargaJual) * 100)) : 0;
    if (progressBar) {
        progressBar.style.width = `${share}%`;
        progressBar.style.background = status.progress;
    }
    if (progressLabel) {
        progressLabel.textContent = hargaJual > 0
            ? `HPP menyerap ${share.toFixed(1)}% dari harga jual`
            : 'Isi harga jual untuk melihat progress';
    }

    const hint = document.getElementById('hintHarga');
    if (hint) {
        if (hargaJual > 0 && hargaJual < hpp * 1.10) {
            hint.style.color = 'var(--red-500)';
            hint.textContent = `⚠️ Harga jual terlalu rendah! HPP ≈ Rp ${formatRupiah(hpp)}, margin < 10%`;
        } else if (hargaJual > 0) {
            hint.style.color = 'var(--green-600)';
            hint.textContent = `✅ Margin: Rp ${formatRupiah(margin)} (${pct}%)`;
        } else {
            hint.style.color = 'var(--text-muted)';
            hint.textContent = 'Minimum HPP + margin 10%';
        }
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('form');
    if (!form) return;

    const inputIds = ['harga_beli_gabah', 'ongkos_giling', 'harga_jual_beras'];
    inputIds.forEach(id => {
        const input = document.getElementById(id);
        if (!input) return;
        input.addEventListener('input', function() {
            formatCurrency(input);
            updateHPPPreview();
        });
    });

    const rasioInput = document.getElementById('rasio_konversi');
    if (rasioInput) {
        rasioInput.addEventListener('input', updateHPPPreview);
    }

    form.addEventListener('submit', function() {
        normalizeCurrencyInputs(form);
    });

    document.querySelectorAll('.currency-input').forEach(input => {
        let raw = String(input.value).replace(/[^0-9]/g, '');
        if (raw !== '') input.value = Number(raw).toLocaleString('id');
    });

    updateHPPPreview();
});
</script>
@endpush
