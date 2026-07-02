@extends('layout.admin')

@section('title', isset($harga) ? 'Edit Konfigurasi Harga' : 'Tambah Konfigurasi Harga')
@section('page-title', isset($harga) ? 'Edit Konfigurasi Harga' : 'Tambah Konfigurasi Harga')
@section('page-subtitle', 'Atur harga beli gabah dan harga jual beras')

@section('content')
<style>
    .calc-card-border {
        border: 1px solid rgba(148, 163, 184, 0.35);
        transition: border-color 0.25s ease, box-shadow 0.25s ease;
    }
    .fade-value {
        display: inline-block;
        opacity: 1;
        transition: opacity 0.18s ease;
    }
    .fade-out {
        opacity: 0;
    }
</style>

@php
    $hargaBeli = old('harga_beli_gabah', isset($harga) ? $harga->harga_beli_gabah : null);
    $hargaJual = old('harga_jual_beras', isset($harga) ? $harga->harga_jual_beras : null);
@endphp

<div class="grid-2" style="margin-bottom:24px;">
    {{-- FORM HARGA --}}
    <div class="card">
        <div class="card-header">
            <div>
                <div class="card-title">{{ isset($harga) ? 'Edit Form' : 'Tambah Baru' }}</div>
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
                    <label>Harga Beli Gabah (per kg)</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;font-weight:600;">Rp</span>
                        <input type="text" name="harga_beli_gabah" id="harga_beli_gabah" class="currency-input" value="{{ is_numeric($hargaBeli) ? number_format($hargaBeli, 0, ',', '.') : ($hargaBeli ?? '') }}"
                            style="padding-left:36px;" placeholder="7.600" inputmode="numeric" autocomplete="off" required>
                    </div>
                    @if(isset($activePrice) && !isset($harga))
                        <div class="form-hint" style="color:var(--amber-600);margin-top:5px;">
                            <i class="fas fa-info-circle"></i> Harga aktif saat ini: <strong>Rp {{ number_format($activePrice->harga_beli_gabah, 0, ',', '.') }} /kg</strong>
                        </div>
                    @endif
                </div>

                <div class="form-group">
                    <label>Harga Jual Beras (per kg)</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;font-weight:600;">Rp</span>
                        <input type="text" name="harga_jual_beras" id="harga_jual_beras" class="currency-input" value="{{ is_numeric($hargaJual) ? number_format($hargaJual, 0, ',', '.') : ($hargaJual ?? '') }}"
                            style="padding-left:36px;" placeholder="13.500" inputmode="numeric" autocomplete="off" required>
                    </div>
                    @if(isset($activePrice) && !isset($harga))
                        <div class="form-hint" style="color:var(--amber-600);margin-top:5px;">
                            <i class="fas fa-info-circle"></i> Harga aktif saat ini: <strong>Rp {{ number_format($activePrice->harga_jual_beras, 0, ',', '.') }} /kg</strong>
                        </div>
                    @endif
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

    {{-- KALKULATOR TOTAL NILAI --}}
    <div style="display:flex;flex-direction:column;gap:20px;">
        <div class="card calc-card-border" id="hasil_card">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;gap:12px;">
                <div>
                    <div class="card-title">Kalkulator Penghasilan</div>
                </div>
            </div>
            <div class="card-body">
                <div style="background:var(--surface-2);border-radius:10px;padding:16px;margin-bottom:16px;">
                    <div style="font-size:12px;color:var(--text-muted);margin-bottom:12px;font-weight:600;">RUMUS HASIL</div>
                    <div style="font-size:13.5px;line-height:2;color:var(--text-secondary);">
                        Total = Harga (per kg) &times;  Masuk (kg)
                    </div>
                </div>

                <div class="form-group">
                    <label>Berat (kg)</label>
                    <input type="number" id="simulasi_jumlah" value="100" min="1" placeholder="Masukkan jumlah kg...">
                </div>

                <div id="kalkulasiTotal" style="display:flex;flex-direction:column;gap:10px;">
                    <div style="display:flex;justify-content:space-between;padding:10px 14px;background:var(--surface-3);border-radius:8px;">
                        <span style="font-size:13px;color:var(--text-secondary);">Total Nilai Gabah</span>
                        <strong id="hasil_total_gabah" class="fade-value">Rp 0</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:10px 14px;background:var(--surface-3);border-radius:8px;">
                        <span style="font-size:13px;color:var(--text-secondary);">Total Nilai Beras</span>
                        <strong id="hasil_total_beras" class="fade-value">Rp 0</strong>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<script>
// Format number to Indonesian thousands: 13500 → "13.500"
function idFormat(num) {
    return String(Math.round(num)).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

function formatCurrency(input) {
    let raw = String(input.value).replace(/[^0-9]/g, '');
    if (raw === '') {
        input.value = '';
        return;
    }
    input.value = idFormat(Number(raw));
}

function normalizeCurrencyInputs(form) {
    form.querySelectorAll('.currency-input').forEach(el => {
        el.value = String(el.value).replace(/\D/g, '');
    });
}

function parseCurrency(value) {
    // Strip dots (thousands sep), keep digits only
    return parseFloat(String(value).replace(/\./g, '').replace(/[^0-9]/g, '')) || 0;
}

function formatRupiah(amount) {
    return idFormat(amount);
}

function animateText(element, text) {
    if (!element) return;
    element.classList.add('fade-out');
    window.setTimeout(() => {
        element.textContent = text;
        element.classList.remove('fade-out');
    }, 120);
}

function updateTotalPreview() {
    const hargaBeli = parseCurrency(document.getElementById('harga_beli_gabah').value);
    const hargaJual = parseCurrency(document.getElementById('harga_jual_beras').value);
    const jumlah = parseFloat(document.getElementById('simulasi_jumlah').value) || 0;

    const totalGabah = hargaBeli * jumlah;
    const totalBeras = hargaJual * jumlah;

    animateText(document.getElementById('hasil_total_gabah'), `Rp ${formatRupiah(totalGabah)}`);
    animateText(document.getElementById('hasil_total_beras'), `Rp ${formatRupiah(totalBeras)}`);
}

document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('form');
    if (!form) return;

    const inputIds = ['harga_beli_gabah', 'harga_jual_beras'];
    inputIds.forEach(id => {
        const input = document.getElementById(id);
        if (!input) return;
        input.addEventListener('input', function() {
            formatCurrency(input);
            updateTotalPreview();
        });
    });

    const simulasiInput = document.getElementById('simulasi_jumlah');
    if (simulasiInput) {
        simulasiInput.addEventListener('input', updateTotalPreview);
    }

    form.addEventListener('submit', function() {
        normalizeCurrencyInputs(form);
    });

    document.querySelectorAll('.currency-input').forEach(input => {
        let raw = String(input.value).replace(/[^0-9]/g, '');
        if (raw !== '') input.value = Number(raw).toLocaleString('id');
    });

    updateTotalPreview();
});
</script>
@endpush
