@extends('layout.admin')

@section('title', 'Pencatatan Panen')
@section('page-title', 'Pencatatan Panen')
@section('page-subtitle', 'Input hasil panen dengan cepat')

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
            <form method="POST" action="{{ route('admin.panen.store') }}" enctype="multipart/form-data">
                @csrf

                <div class="form-group">
                    <label>Petani <span style="color:var(--red-500)">*</span></label>
                    {{-- Hidden input yang dikirim ke server --}}
                    <input type="hidden" name="petani_id" id="petaniIdInput" value="{{ old('petani_id') }}" required>

                    {{-- Custom searchable dropdown --}}
                    <div id="petaniDropdown" style="position:relative;">
                        <div id="petaniDisplay" onclick="togglePetaniDropdown()"
                            style="display:flex;align-items:center;justify-content:space-between;padding:10px 12px;border:1px solid var(--border);border-radius:8px;cursor:pointer;background:var(--surface-1,#fff);user-select:none;">
                            <span id="petaniDisplayText" style="color:var(--text-muted,#9ca3af);">Pilih petani...</span>
                            <i class="fas fa-chevron-down" id="petaniChevron" style="font-size:12px;color:var(--text-muted);transition:transform .2s;"></i>
                        </div>

                        <div id="petaniPanel" style="display:none;position:absolute;top:calc(100% + 4px);left:0;right:0;z-index:999;background:var(--surface-1,#fff);border:1px solid var(--border);border-radius:8px;box-shadow:0 8px 24px rgba(0,0,0,.12);overflow:hidden;">
                            {{-- Search box --}}
                            <div style="padding:8px;">
                                <div style="position:relative;">
                                    <i class="fas fa-search" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);font-size:12px;color:var(--text-muted);"></i>
                                    <input type="text" id="petaniSearch" placeholder="Cari nama petani..."
                                        oninput="filterPetaniList(this.value)"
                                        onclick="event.stopPropagation()"
                                        style="width:100%;box-sizing:border-box;padding:8px 10px 8px 30px;border:1px solid var(--border);border-radius:6px;font-size:13px;outline:none;background:var(--surface-2,#f9fafb);">
                                </div>
                            </div>
                            {{-- List dengan scroll --}}
                            <ul id="petaniList" style="list-style:none;margin:0;padding:4px 0;max-height:220px;overflow-y:auto;">
                                @forelse($petanis as $p)
                                <li class="petani-opt"
                                    data-id="{{ $p->id }}"
                                    data-label="{{ $p->nama }} – {{ number_format($p->luas_lahan) }} m²"
                                    data-search="{{ strtolower($p->nama) }}"
                                    onclick="selectPetani(this)"
                                    style="padding:9px 14px;cursor:pointer;font-size:13px;border-radius:6px;margin:0 4px;">
                                    {{ $p->nama }} – {{ number_format($p->luas_lahan) }} m²
                                </li>
                                @empty
                                <li style="padding:12px 14px;font-size:13px;color:var(--text-muted);">Tidak ada data petani.</li>
                                @endforelse
                            </ul>
                        </div>
                    </div>
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
                    <label>Hasil Gabah (kg) <span style="color:var(--red-500)">*</span></label>
                    <input type="number" name="jumlah_gabah" id="jumlahGabah" placeholder="Contoh: 3000"
                        required min="1" autocomplete="off" value="{{ old('jumlah_gabah') }}">
                    <div class="form-hint">Berat gabah basah setelah panen</div>
                    @error('jumlah_gabah')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                </div>


                <div class="form-group">
                    <label>Komoditas</label>
                    <select name="komoditas">
                        <option value="Padi" {{ old('komoditas') == 'Padi' ? 'selected' : '' }}>Padi</option>
                    </select>
                    @error('komoditas')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                </div>

                <div class="form-group">
                    <label>Catatan</label>
                    <textarea name="catatan" rows="2" placeholder="Kondisi panen, cuaca, dll. (opsional)">{{ old('catatan') }}</textarea>
                    @error('catatan')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- FOTO BUKTI --}}
                <div class="form-group">
                    <label>Foto Bukti Transaksi <span style="color:var(--red-500)">*</span></label>
                    <div id="foto-drop-zone" onclick="document.getElementById('foto_bukti_input').click()"
                        style="border:2px dashed var(--border);border-radius:10px;padding:24px;text-align:center;cursor:pointer;transition:border-color .2s,background .2s;">
                        <div id="foto-placeholder">
                            <i class="fas fa-camera" style="font-size:28px;color:var(--text-muted);margin-bottom:8px;"></i>
                            <div style="font-size:13px;color:var(--text-muted);">Klik untuk memilih foto</div>
                            <div style="font-size:11px;color:var(--text-muted);margin-top:4px;">JPG, JPEG, PNG &mdash; maks. 5 MB</div>
                        </div>
                        <img id="foto-preview" src="" alt="Preview" style="display:none;max-height:180px;border-radius:8px;object-fit:contain;">
                    </div>
                    <input type="file" id="foto_bukti_input" name="foto_bukti" accept="image/jpg,image/jpeg,image/png" required
                        style="display:none;" onchange="previewFoto(this)">
                    {{-- Tombol hapus foto (di luar area foto) --}}
                    <div id="foto-clear-wrap" style="display:none;margin-top:6px;text-align:right;">
                        <button type="button" onclick="clearFoto(event)"
                            style="background:none;border:none;cursor:pointer;font-size:12px;color:var(--red-500);font-weight:600;padding:0;">
                            <i class="fas fa-times"></i> Hapus foto
                        </button>
                    </div>
                    @error('foto_bukti')<span style="color:red; font-size:12px;">{{ $message }}</span>@enderror
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
                        <th>Hasil Gabah</th>
                        <th>Penghasilan</th>
                        <th>Foto</th>
                        <th>Musim</th>
                        <th>Tanggal</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($panenList ?? [] as $p)
                        <tr class="panen-row" data-href="{{ route('admin.panen.show', $p->id) }}" style="cursor:pointer;transition:background .15s;">
                            <td><strong>{{ $p->lahan->petani->nama ?? '-' }}</strong></td>
                            <td>{{ number_format($p->jumlah_gabah) }} kg</td>
                            <td style="color:var(--green-700);font-weight:600;">
                                @if($p->harga_gabah_per_kg > 0)
                                    Rp {{ number_format($p->jumlah_gabah * $p->harga_gabah_per_kg, 0, ',', '.') }}
                                @else
                                    -
                                @endif
                            </td>
                            <td>
                                @if($p->foto_bukti)
                                    <img src="{{ asset('storage/' . $p->foto_bukti) }}" alt="Bukti"
                                        style="width:44px;height:44px;object-fit:cover;border-radius:6px;border:1px solid var(--border);">
                                @else
                                    <span style="color:var(--text-muted);font-size:11px;">-</span>
                                @endif
                            </td>
                            <td><span class="badge badge-green" style="font-size:11px;">{{ $p->musim }}</span></td>
                            <td style="font-size:12px;color:var(--text-muted);">{{ optional($p->tanggal_panen)->format('Y-m-d') }}</td>
                            <td onclick="event.stopPropagation()">
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
            <div style="padding:16px;display:flex;flex-wrap:wrap;justify-content:center;align-items:center;gap:10px;border-top:1px solid var(--border,#e2e8f0);">
                <div style="width:100%;text-align:center;font-size:12px;color:var(--text-muted);">
                    Menampilkan {{ $panenList->firstItem() }}–{{ $panenList->lastItem() }} dari {{ $panenList->total() }} data
                </div>
                <div style="display:flex;flex-wrap:wrap;justify-content:center;gap:4px;">
                    @if($panenList->onFirstPage())
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;">First</span>
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;"><i class="fas fa-chevron-left"></i></span>
                    @else
                        <a href="{{ $panenList->url(1) }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;">First</a>
                        <a href="{{ $panenList->previousPageUrl() }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;"><i class="fas fa-chevron-left"></i></a>
                    @endif
                    @foreach($panenList->getUrlRange(max(1,$panenList->currentPage()-2), min($panenList->lastPage(),$panenList->currentPage()+2)) as $page => $url)
                        <a href="{{ $url }}" style="padding:6px 10px;border-radius:6px;font-size:12px;text-decoration:none;background:{{ $page == $panenList->currentPage() ? 'var(--green-600)' : 'var(--surface-3)' }};color:{{ $page == $panenList->currentPage() ? 'white' : 'var(--text-primary)' }};">{{ $page }}</a>
                    @endforeach
                    @if($panenList->hasMorePages())
                        <a href="{{ $panenList->nextPageUrl() }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;"><i class="fas fa-chevron-right"></i></a>
                        <a href="{{ $panenList->url($panenList->lastPage()) }}" style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-primary);font-size:12px;text-decoration:none;">Last</a>
                    @else
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;"><i class="fas fa-chevron-right"></i></span>
                        <span style="padding:6px 10px;min-width:66px;text-align:center;display:inline-flex;align-items:center;justify-content:center;border-radius:6px;background:var(--surface-3);color:var(--text-muted);font-size:12px;cursor:not-allowed;">Last</span>
                    @endif
                </div>
            </div>
        @endif
    </div>
</div>

{{-- LIGHTBOX FOTO BUKTI PANEN --}}
<div class="modal-overlay" id="panenImageLightbox" style="display:none;" onclick="closeImageModal()">
    <div style="position:relative;background:linear-gradient(180deg,rgba(46,125,50,0.95),rgba(16,64,20,0.95));padding:16px;border-radius:8px;max-width:900px;width:95%;max-height:90vh;" onclick="event.stopPropagation()">
        <button onclick="closeImageModal()" style="position:absolute;right:12px;top:12px;color:#fff;background:transparent;border:none;font-size:20px;cursor:pointer;z-index:1;"><i class="fas fa-times"></i></button>
        <div style="display:flex;align-items:center;justify-content:center;padding:24px;">
            <img id="panenImageFull" src="" alt="Bukti Panen"
                style="max-width:100%;max-height:80vh;border-radius:8px;box-shadow:0 8px 24px rgba(0,0,0,0.4);transform:scale(0.98);opacity:0;transition:all .25s ease-in-out;">
        </div>
    </div>
</div>

@push('scripts')
<script>
function previewFoto(input) {
    const dropZone = document.getElementById('foto-drop-zone');
    const placeholder = document.getElementById('foto-placeholder');
    const preview = document.getElementById('foto-preview');
    const clearWrap = document.getElementById('foto-clear-wrap');
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.src = e.target.result;
            preview.style.display = 'block';
            placeholder.style.display = 'none';
            dropZone.style.borderColor = 'var(--green-500)';
            dropZone.style.background = 'rgba(22,163,74,0.05)';
            clearWrap.style.display = 'block';
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function clearFoto(event) {
    event.stopPropagation();
    const input = document.getElementById('foto_bukti_input');
    const dropZone = document.getElementById('foto-drop-zone');
    const placeholder = document.getElementById('foto-placeholder');
    const preview = document.getElementById('foto-preview');
    const clearWrap = document.getElementById('foto-clear-wrap');
    input.value = '';
    preview.src = '';
    preview.style.display = 'none';
    placeholder.style.display = 'block';
    clearWrap.style.display = 'none';
    dropZone.style.borderColor = 'var(--border)';
    dropZone.style.background = '';
}
function openImageModal(src) {
    const overlay = document.getElementById('panenImageLightbox');
    const img = document.getElementById('panenImageFull');
    if (!overlay || !img) return;
    img.style.opacity = 0; img.style.transform = 'scale(0.98)';
    img.src = src;
    overlay.style.display = 'flex';
    setTimeout(() => { img.style.opacity = 1; img.style.transform = 'scale(1)'; }, 40);
}
function closeImageModal() {
    const overlay = document.getElementById('panenImageLightbox');
    const img = document.getElementById('panenImageFull');
    if (!overlay || !img) return;
    img.style.opacity = 0; img.style.transform = 'scale(0.98)';
    setTimeout(() => { overlay.style.display = 'none'; img.src = ''; }, 220);
}
document.addEventListener('click', function(e) {
    const anchor = e.target.closest && e.target.closest('.bukti-link');
    if (anchor) {
        e.preventDefault();
        openImageModal(anchor.dataset.src);
    }
});
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeImageModal();
});

// Klik baris → halaman detail
document.addEventListener('click', function(e) {
    const row = e.target.closest && e.target.closest('tr.panen-row');
    if (row && row.dataset.href) {
        // Jangan navigasi jika klik di dalam td yg sudah stopPropagation (Aksi/Foto)
        window.location.href = row.dataset.href;
    }
});
// ── Custom searchable dropdown petani ────────────────────────────
function togglePetaniDropdown() {
    const panel  = document.getElementById('petaniPanel');
    const chev   = document.getElementById('petaniChevron');
    const search = document.getElementById('petaniSearch');
    const isOpen = panel.style.display !== 'none';
    panel.style.display = isOpen ? 'none' : 'block';
    chev.style.transform = isOpen ? 'rotate(0deg)' : 'rotate(180deg)';
    if (!isOpen) { search.value = ''; filterPetaniList(''); search.focus(); }
}

function filterPetaniList(q) {
    const kw = q.toLowerCase();
    document.querySelectorAll('#petaniList .petani-opt').forEach(li => {
        li.style.display = li.dataset.search.includes(kw) ? '' : 'none';
    });
}

function selectPetani(li) {
    document.getElementById('petaniIdInput').value      = li.dataset.id;
    document.getElementById('petaniDisplayText').textContent = li.dataset.label;
    document.getElementById('petaniDisplayText').style.color = 'var(--text-primary, #111)';
    document.getElementById('petaniPanel').style.display    = 'none';
    document.getElementById('petaniChevron').style.transform = 'rotate(0deg)';
    // Tandai item aktif
    document.querySelectorAll('#petaniList .petani-opt').forEach(el => {
        el.style.background = el === li ? 'var(--green-50, #f0fdf4)' : '';
        el.style.fontWeight  = el === li ? '600' : '';
    });
}

// Tutup dropdown saat klik di luar
document.addEventListener('click', function(e) {
    const dd = document.getElementById('petaniDropdown');
    if (dd && !dd.contains(e.target)) {
        document.getElementById('petaniPanel').style.display = 'none';
        document.getElementById('petaniChevron').style.transform = 'rotate(0deg)';
    }
});

// Hover effect untuk list item
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('#petaniList .petani-opt').forEach(li => {
        li.addEventListener('mouseenter', function() {
            if (!this.style.background || this.style.background === '') {
                this.style.background = 'var(--surface-2, #f3f4f6)';
            }
        });
        li.addEventListener('mouseleave', function() {
            if (this.style.fontWeight !== '600') {
                this.style.background = '';
            }
        });
    });

    // Restore pilihan saat ada old value (validation error)
    const oldId = document.getElementById('petaniIdInput').value;
    if (oldId) {
        const li = document.querySelector(`#petaniList .petani-opt[data-id="${oldId}"]`);
        if (li) selectPetani(li);
    }
});
</script>
@endpush

@endsection
