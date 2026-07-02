@extends('layout.admin')

@section('title', 'Edit Data Panen')
@section('page-title', 'Edit Data Panen')
@section('page-subtitle', 'Perbarui data hasil panen')

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

<div style="max-width:640px;margin:0 auto;">
    <div class="card">
        <div class="card-header">
            <div class="card-title">Edit Data Panen</div>
        </div>
        <div class="card-body">
            <form method="POST" action="{{ route('admin.panen.update', $panen->id) }}">
                @csrf
                @method('PUT')

                {{-- Lahan --}}
                <div class="form-group">
                    <label>Lahan <span style="color:var(--red-500)">*</span></label>
                    <select name="lahan_id" required>
                        <option value="">Pilih lahan...</option>
                        @foreach($lahans as $l)
                            <option value="{{ $l->id }}"
                                {{ old('lahan_id', $panen->lahan_id) == $l->id ? 'selected' : '' }}>
                                {{ $l->petani->nama ?? '-' }} – {{ $l->nama_lahan }}
                            </option>
                        @endforeach
                    </select>
                    @error('lahan_id')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Musim --}}
                <div class="form-group">
                    <label>Musim Tanam</label>
                    <select name="musim">
                        <option value="">Pilih musim</option>
                        <option value="Kemarau" {{ old('musim', $panen->musim) == 'Kemarau' ? 'selected' : '' }}>Kemarau</option>
                        <option value="Hujan"   {{ old('musim', $panen->musim) == 'Hujan'   ? 'selected' : '' }}>Hujan</option>
                    </select>
                    @error('musim')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Tanggal Panen --}}
                <div class="form-group">
                    <label>Tanggal Panen <span style="color:var(--red-500)">*</span></label>
                    <input type="date" name="tanggal_panen"
                           value="{{ old('tanggal_panen', optional($panen->tanggal_panen)->format('Y-m-d')) }}"
                           required>
                    @error('tanggal_panen')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Tonase Gabah --}}
                <div class="form-group">
                    <label>Jumlah Gabah (kg) <span style="color:var(--red-500)">*</span></label>
                    <input type="number" name="jumlah_gabah" id="jumlahGabah"
                           value="{{ old('jumlah_gabah', $panen->jumlah_gabah) }}"
                           step="0.01" min="0.1" required>
                    @error('jumlah_gabah')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>


                {{-- Catatan --}}
                <div class="form-group">
                    <label>Catatan</label>
                    <textarea name="catatan" rows="3"
                              placeholder="Kondisi panen, cuaca, dll. (opsional)">{{ old('catatan', $panen->catatan) }}</textarea>
                    @error('catatan')<span style="color:red;font-size:12px;">{{ $message }}</span>@enderror
                </div>

                {{-- Actions --}}
                <div style="display:flex;gap:12px;margin-top:8px;">
                    <a href="{{ route('admin.panen.index') }}"
                       style="flex:1;display:inline-flex;align-items:center;justify-content:center;gap:8px;padding:12px;background:var(--surface-3);color:var(--text-primary);border:1px solid var(--border,#e2e8f0);border-radius:10px;text-decoration:none;font-weight:600;">
                        <i class="fas fa-arrow-left"></i> Batal
                    </a>
                    <button type="submit"
                            style="flex:2;display:inline-flex;align-items:center;justify-content:center;gap:8px;padding:12px;background:var(--green-600);color:white;border:none;border-radius:10px;font-weight:700;cursor:pointer;font-size:15px;">
                        <i class="fas fa-save"></i> Simpan Perubahan
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

@endsection


