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
                            <option value="Kemarau" {{ old('musim') == 'Kemarau' ? 'selected' : '' }}>Kemarau</option>
                            <option value="Hujan" {{ old('musim') == 'Hujan' ? 'selected' : '' }}>Hujan</option>
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
                <div class="card-subtitle">Scroll untuk melihat semua data</div>
            </div>
        </div>
        <div class="table-container" style="max-height:480px;overflow-y:auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Petani</th>
                        <th>Tonase Gabah</th>
                        <th>Beras Hasil</th>
                        <th>Musim</th>
                        <th>Tanggal</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($panenList ?? [] as $p)
                        <tr>
                            <td><strong>{{ $p->lahan->petani->nama ?? '-' }}</strong></td>
                            <td>{{ number_format($p->tonase_gabah) }} kg</td>
                            <td><strong style="color:var(--green-600);">{{ number_format($p->beras_dihasilkan) }} kg</strong></td>
                            <td><span class="badge badge-green" style="font-size:11px;">{{ $p->musim }}</span></td>
                            <td style="font-size:12px;color:var(--text-muted);">{{ optional($p->tanggal_panen)->format('Y-m-d') }}</td>
                            <td>
                                <div style="display:flex;gap:6px;align-items:center;">
                                    {{-- Edit --}}
                                    <a href="{{ route('admin.panen.edit', $p->id) }}"
                                       style="display:inline-flex;align-items:center;gap:4px;padding:5px 10px;background:var(--blue-500, #3b82f6);color:white;border-radius:6px;font-size:11px;font-weight:600;text-decoration:none;">
                                        <i class="fas fa-edit"></i> Edit
                                    </a>
                                    {{-- Hapus --}}
                                    <form method="POST" action="{{ route('admin.panen.destroy', $p->id) }}"
                                          onsubmit="return confirm('Yakin hapus data panen ini?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit"
                                                style="display:inline-flex;align-items:center;gap:4px;padding:5px 10px;background:var(--red-500, #ef4444);color:white;border:none;border-radius:6px;font-size:11px;font-weight:600;cursor:pointer;">
                                            <i class="fas fa-trash"></i> Hapus
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="text-center text-muted" style="padding: 24px;">Belum ada catatan panen.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        {{-- Paginasi --}}
        @if($panenList->hasPages())
            <div style="padding:16px;display:flex;justify-content:space-between;align-items:center;border-top:1px solid var(--border,#e2e8f0);">
                <div style="font-size:12px;color:var(--text-muted);">
                    Menampilkan {{ $panenList->firstItem() }}–{{ $panenList->lastItem() }} dari {{ $panenList->total() }} data
                </div>
                <div style="display:flex;gap:4px;">
                    @if($panenList->onFirstPage())
                        <span style="padding:6px 10px;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;"><i class="fas fa-chevron-left"></i></span>
                    @else
                        <a href="{{ $panenList->previousPageUrl() }}" style="padding:6px 10px;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;"><i class="fas fa-chevron-left"></i></a>
                    @endif
                    @foreach($panenList->getUrlRange(max(1,$panenList->currentPage()-2), min($panenList->lastPage(),$panenList->currentPage()+2)) as $page => $url)
                        <a href="{{ $url }}" style="padding:6px 10px;border-radius:6px;font-size:12px;text-decoration:none;background:{{ $page == $panenList->currentPage() ? 'var(--green-600)' : 'var(--surface-3)' }};color:{{ $page == $panenList->currentPage() ? 'white' : 'var(--text-primary)' }};">{{ $page }}</a>
                    @endforeach
                    @if($panenList->hasMorePages())
                        <a href="{{ $panenList->nextPageUrl() }}" style="padding:6px 10px;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;"><i class="fas fa-chevron-right"></i></a>
                    @else
                        <span style="padding:6px 10px;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;"><i class="fas fa-chevron-right"></i></span>
                    @endif
                </div>
            </div>
        @endif
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