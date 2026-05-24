@extends('layout.admin')

@section('title', 'Pencatatan Panen')
@section('page-title', 'Pencatatan Panen')
@section('page-subtitle', 'Input tonase panen dengan konversi gabah → beras otomatis')

@section('content')

@if ($errors->any())
    <div class="alert-banner danger" style="margin-bottom:24px;">
        <i class="fas fa-exclamation-circle"></i>
        <div>
            <strong>Perbaiki kesalahan berikut:</strong>
            <ul style="margin:8px 0 0 16px;">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    </div>
@endif

<div class="grid-2" style="margin-bottom:24px;align-items:start;">

    {{-- FORM CATAT PANEN --}}
    <div class="card">
        <div class="card-header">
            <div class="card-title">Catat Hasil Panen Baru</div>
        </div>
        <div class="card-body">
            <form method="POST" action="{{ route('admin.panen.store') }}">
                @csrf

                <div class="form-group">
                    <label>Petani <span style="color:var(--red-500)">*</span></label>
                    <select name="petani_id" required>
                        <option value="">Pilih petani...</option>
                        @forelse($petanis as $p)
                            <option value="{{ $p->id }}" {{ old('petani_id') == $p->id ? 'selected' : '' }}>
                                {{ $p->nama }} – {{ number_format($p->luas_lahan) }} m²
                            </option>
                        @empty
                            <option value="">Tidak ada data petani. Tambahkan petani terlebih dahulu.</option>
                        @endforelse
                    </select>
                    @error('petani_id')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                </div>

                <div class="grid-2">
                    <div class="form-group">
                        <label>Musim Tanam <span style="color:var(--red-500)">*</span></label>
                        <select name="musim" required>
                            <option value="">Pilih musim</option>
                            <option value="Okt-Mar 2024/2025" {{ old('musim') == 'Okt-Mar 2024/2025' ? 'selected' : '' }}>Okt–Mar 2024/2025</option>
                            <option value="Apr-Sep 2025" {{ old('musim') == 'Apr-Sep 2025' ? 'selected' : '' }}>Apr–Sep 2025</option>
                            <option value="Okt-Mar 2025/2026" {{ old('musim') == 'Okt-Mar 2025/2026' ? 'selected' : '' }}>Okt–Mar 2025/2026</option>
                        </select>
                        @error('musim')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                    </div>
                    <div class="form-group">
                        <label>Tanggal Panen <span style="color:var(--red-500)">*</span></label>
                        <input type="date" name="tanggal_panen" value="{{ old('tanggal_panen', date('Y-m-d')) }}" required>
                        @error('tanggal_panen')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                    </div>
                </div>

                <div class="form-group">
                    <label>Tonase Gabah (kg) <span style="color:var(--red-500)">*</span></label>
                    <input type="number" name="tonase_gabah" id="tonaseGabah" placeholder="Contoh: 3000"
                        required min="1" autocomplete="off" oninput="hitungKonversi()" value="{{ old('tonase_gabah') }}">
                    <div class="form-hint">Berat gabah basah setelah panen</div>
                    @error('tonase_gabah')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                </div>

                <div class="form-group">
                    <label>Rasio Konversi (%)</label>
                    <input type="number" name="rasio_konversi" id="rasioKonversi" value="{{ old('rasio_konversi', 61.5) }}"
                        step="0.1" min="50" max="70" oninput="hitungKonversi()">
                    <div class="form-hint">Default sistem: 61,5% (dapat disesuaikan per batch)</div>
                    @error('rasio_konversi')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- PREVIEW KONVERSI --}}
                <div id="previewKonversi" style="display:none;background:var(--green-50);border:1.5px solid var(--green-300);border-radius:10px;padding:16px;margin-bottom:18px;">
                    <div style="font-size:12px;font-weight:700;color:var(--green-700);margin-bottom:10px;">
                        <i class="fas fa-calculator"></i> Estimasi Hasil Konversi
                    </div>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                        <div>
                            <div style="font-size:11px;color:var(--text-muted);">Gabah Input</div>
                            <div style="font-size:18px;font-weight:800;" id="previewGabah">0 kg</div>
                        </div>
                        <div>
                            <div style="font-size:11px;color:var(--text-muted);">Est. Beras Dihasilkan</div>
                            <div style="font-size:18px;font-weight:800;color:var(--green-600);" id="previewBeras">0 kg</div>
                        </div>
                    </div>
                    <input type="hidden" name="beras_dihasilkan" id="berasDihasilkan" value="{{ old('beras_dihasilkan') }}">
                </div>

                <div class="form-group">
                    <label>Komoditas</label>
                    <select name="komoditas">
                        <option value="Padi" {{ old('komoditas') == 'Padi' ? 'selected' : '' }}>Padi</option>
                        <option value="Jagung" {{ old('komoditas') == 'Jagung' ? 'selected' : '' }}>Jagung</option>
                    </select>
                    @error('komoditas')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                </div>

                <div class="form-group">
                    <label>Catatan</label>
                    <textarea name="catatan" rows="2" placeholder="Kondisi panen, cuaca, dll. (opsional)">{{ old('catatan') }}</textarea>
                    @error('catatan')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center;">
                    <i class="fas fa-save"></i> Simpan Catatan Panen
                </button>
            </form>
        </div>
    </div>

    {{-- RIWAYAT PANEN TERBARU --}}
    <div class="card">
        <div class="card-header">
            <div>
                <div class="card-title">Riwayat Panen Terbaru</div>
                <div class="card-subtitle">10 entri terbaru</div>
            </div>
        </div>
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Petani</th>
                        <th>Tonase Gabah</th>
                        <th>Beras Hasil</th>
                        <th>Musim</th>
                        <th>Tanggal</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($panenList ?? [] as $p)
                        <tr>
                            <td><strong>{{ $p->petani->nama }}</strong></td>
                            <td>{{ number_format($p->tonase_gabah) }} kg</td>
                            <td><strong style="color:var(--green-600);">{{ number_format($p->beras_dihasilkan) }} kg</strong></td>
                            <td><span class="badge badge-green" style="font-size:11px;">{{ $p->musim }}</span></td>
                            <td style="font-size:12px;color:var(--text-muted);">{{ $p->tanggal_panen }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="text-center text-muted" style="padding: 24px;">Belum ada catatan panen.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<script>
function hitungKonversi() {
    const gabah = parseFloat(document.getElementById('tonaseGabah').value) || 0;
    const rasio = parseFloat(document.getElementById('rasioKonversi').value) || 61.5;
    const beras = Math.round(gabah * (rasio / 100));
    const preview = document.getElementById('previewKonversi');

    if (gabah > 0) {
        preview.style.display = 'block';
        document.getElementById('previewGabah').textContent = gabah.toLocaleString('id') + ' kg';
        document.getElementById('previewBeras').textContent = beras.toLocaleString('id') + ' kg';
        document.getElementById('berasDihasilkan').value = beras;
    } else {
        preview.style.display = 'none';
    }
}

document.addEventListener('DOMContentLoaded', function () {
    hitungKonversi();
});
</script>
@endpush
