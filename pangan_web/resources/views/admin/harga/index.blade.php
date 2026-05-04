{{-- ============================================================
     MANAJEMEN HARGA
     ============================================================ --}}
{{-- resources/views/admin/harga/index.blade.php --}}
@extends('layout.admin')

@section('title', 'Manajemen Harga')
@section('page-title', 'Manajemen Harga')
@section('page-subtitle', 'Konfigurasi harga beli gabah, ongkos giling, dan harga jual beras')

@section('content')

<div class="grid-2" style="margin-bottom:24px;">
    {{-- FORM HARGA --}}
    <div class="card">
        <div class="card-header">
            <div>
                <div class="card-title">Konfigurasi Harga Aktif</div>
                <div class="card-subtitle">Perubahan akan langsung mempengaruhi kalkulasi HPP & margin</div>
            </div>
        </div>
        <div class="card-body">
            <form method="POST" action="{{ route('admin.harga.update') }}">
                @csrf @method('PUT')

                <div class="form-group">
                    <label>Harga Beli Gabah (per 100 kg)</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;font-weight:600;">Rp</span>
                        <input type="number" name="harga_beli_gabah" value="{{ $harga->harga_beli_gabah ?? 760000 }}"
                            style="padding-left:36px;" placeholder="760000" required min="0">
                    </div>
                    <div class="form-hint">Default: Rp 760.000 per 100 kg</div>
                </div>

                <div class="form-group">
                    <label>Ongkos Giling (per kg beras)</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;font-weight:600;">Rp</span>
                        <input type="number" name="ongkos_giling" value="{{ $harga->ongkos_giling ?? 700 }}"
                            style="padding-left:36px;" placeholder="700" required min="0">
                    </div>
                    <div class="form-hint">Default: Rp 700 per kg beras</div>
                </div>

                <div class="form-group">
                    <label>Harga Jual Beras (per kg)</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;font-weight:600;">Rp</span>
                        <input type="number" name="harga_jual_beras" id="hargaJual" value="{{ $harga->harga_jual_beras ?? 13500 }}"
                            style="padding-left:36px;" placeholder="13500" required min="0" oninput="hitungMargin()">
                    </div>
                    <div class="form-hint" id="hintHarga">Minimum HPP + margin 10%</div>
                </div>

                <div class="form-group">
                    <label>Rasio Konversi Gabah → Beras (%)</label>
                    <input type="number" name="rasio_konversi" value="{{ $harga->rasio_konversi ?? 61.5 }}" step="0.1" min="50" max="70" required>
                    <div class="form-hint">Default: 61,5% (60–63 kg beras per 100 kg gabah)</div>
                </div>

                <div class="form-group">
                    <label>Berlaku Mulai Tanggal</label>
                    <input type="date" name="berlaku_mulai" value="{{ date('Y-m-d') }}" required>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center;">
                    <i class="fas fa-save"></i> Simpan Konfigurasi Harga
                </button>
            </form>
        </div>
    </div>

    {{-- KALKULASI HPP OTOMATIS --}}
    <div style="display:flex;flex-direction:column;gap:20px;">
        <div class="card">
            <div class="card-header">
                <div class="card-title">Kalkulasi HPP Otomatis</div>
            </div>
            <div class="card-body">
                <div style="background:var(--surface-2);border-radius:10px;padding:16px;margin-bottom:16px;">
                    <div style="font-size:12px;color:var(--text-muted);margin-bottom:12px;font-weight:600;">RUMUS HPP (per kg beras)</div>
                    <div style="font-size:13.5px;line-height:2;color:var(--text-secondary);">
                        HPP = (Harga Beli Gabah ÷ 100 × <em>konversi</em>) + Ongkos Giling<br>
                        <span style="font-size:12px;color:var(--text-muted);">= (Rp 760.000 ÷ 100 × 0.615) + Rp 700</span>
                    </div>
                </div>

                <div id="kalkulasiHPP" style="display:flex;flex-direction:column;gap:10px;">
                    <div style="display:flex;justify-content:space-between;padding:10px 14px;background:var(--surface-3);border-radius:8px;">
                        <span style="font-size:13px;color:var(--text-secondary);">HPP per kg beras</span>
                        <strong>≈ Rp 9.614</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:10px 14px;background:var(--surface-3);border-radius:8px;">
                        <span style="font-size:13px;color:var(--text-secondary);">Harga Jual</span>
                        <strong>Rp 13.500</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:12px 14px;background:var(--green-100);border-radius:8px;">
                        <span style="font-size:13px;font-weight:600;color:var(--green-700);">Margin Kotor</span>
                        <strong style="color:var(--green-700);">≈ Rp 3.886 / kg (40,4%)</strong>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <div class="card-title">Riwayat Perubahan Harga</div>
            </div>
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr><th>Tanggal</th><th>Harga Gabah</th><th>H. Jual Beras</th><th>Diubah Oleh</th></tr>
                    </thead>
                    <tbody>
                        @foreach($riwayatHarga ?? [
                            ['17 Apr 2025', 'Rp 760.000', 'Rp 13.500', 'Admin'],
                            ['01 Apr 2025', 'Rp 740.000', 'Rp 13.000', 'Admin'],
                        ] as $r)
                            <tr>
                                <td style="font-size:12.5px;">{{ is_array($r) ? $r[0] : $r->created_at }}</td>
                                <td>{{ is_array($r) ? $r[1] : 'Rp '.number_format($r->harga_beli_gabah) }}</td>
                                <td>{{ is_array($r) ? $r[2] : 'Rp '.number_format($r->harga_jual_beras) }}</td>
                                <td style="font-size:12px;color:var(--text-muted);">{{ is_array($r) ? $r[3] : ($r->user->name ?? '-') }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<script>
function hitungMargin() {
    const jual = parseFloat(document.getElementById('hargaJual').value) || 0;
    const hpp = 9614;
    const margin = jual - hpp;
    const pct = jual > 0 ? ((margin / jual) * 100).toFixed(1) : 0;
    const hint = document.getElementById('hintHarga');
    if (jual > 0 && jual < hpp * 1.10) {
        hint.style.color = 'var(--red-500)';
        hint.textContent = `⚠️ Harga jual terlalu rendah! HPP ≈ Rp ${hpp.toLocaleString('id')}, margin < 10%`;
    } else if (jual > 0) {
        hint.style.color = 'var(--green-600)';
        hint.textContent = `✅ Margin: Rp ${margin.toLocaleString('id')} (${pct}%)`;
    }
}
</script>
@endpush
