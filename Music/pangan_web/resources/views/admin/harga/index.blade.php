@extends('layout.admin')

@section('title', 'Manajemen Harga')
@section('page-title', 'Manajemen Harga')
@section('page-subtitle', 'Riwayat konfigurasi harga beli gabah, ongkos giling, dan harga jual beras')

@section('content')

@if(session('success'))
    <div style="background: var(--green-100); color: var(--green-700); padding: 16px; border-radius: 8px; margin-bottom: 24px;">
        <i class="fas fa-check-circle" style="margin-right: 8px;"></i> {{ session('success') }}
    </div>
@endif

@if(session('error'))
    <div style="background: var(--red-100); color: var(--red-700); padding: 16px; border-radius: 8px; margin-bottom: 24px;">
        <i class="fas fa-exclamation-circle" style="margin-right: 8px;"></i> {{ session('error') }}
    </div>
@endif

@if(isset($activeConfig))
    <div class="card" style="margin-bottom:24px; border: 1px solid #d1d5db;">
        <div class="card-header" style="display:flex; justify-content:space-between; align-items:center;">
            <div class="card-title">Rasio Konversi Aktif</div>
            <span style="color:#475569;">Konfigurasi aktif berlaku mulai {{ $activeConfig->berlaku_mulai->format('d M Y') }}</span>
        </div>
        <div class="card-body" style="padding:20px;">
            <form action="{{ route('admin.harga.updateRasio', $activeConfig->id) }}" method="POST" style="display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap;">
                @csrf
                @method('PATCH')
                <div style="flex:1; min-width:260px;">
                    <label for="rasio_konversi" style="display:block; margin-bottom:8px; font-weight:600;">Rasio Konversi Gabah → Beras (%)</label>
                    <input type="number" id="rasio_konversi" name="rasio_konversi" step="0.1" min="0" max="100" value="{{ old('rasio_konversi', $activeConfig->rasio_konversi) }}" style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:8px;" required>
                    @error('rasio_konversi')
                        <div style="color:#b91c1c; margin-top:6px; font-size:13px;">{{ $message }}</div>
                    @enderror
                </div>
                <button type="submit" class="btn btn-primary" style="height:42px;">Simpan Rasio</button>
            </form>
        </div>
    </div>
@endif

<div class="card" style="margin-bottom:24px;">
    <div class="card-header" style="display:flex; justify-content:space-between; align-items:center;">
        <div class="card-title">Riwayat Konfigurasi Harga</div>
        <a href="{{ route('admin.harga.create') }}" class="btn btn-primary"><i class="fas fa-plus"></i> Tambah Konfigurasi</a>
    </div>
    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Tanggal Berlaku</th>
                    <th>Harga Gabah</th>
                    <th>Ongkos Giling</th>
                    <th>Harga Jual Beras</th>
                    <th>Rasio Konversi</th>
                    <th>Status</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($konfigurasi as $k)
                    <tr>
                        <td style="font-size:13.5px;">{{ $k->berlaku_mulai->format('d M Y') }}</td>
                        <td>Rp {{ number_format($k->harga_beli_gabah, 0, ',', '.') }}</td>
                        <td>Rp {{ number_format($k->ongkos_giling, 0, ',', '.') }}</td>
                        <td>Rp {{ number_format($k->harga_jual_beras, 0, ',', '.') }}</td>
                        <td>{{ number_format($k->rasio_konversi, 1, ',', '.') }}%</td>
                        <td>
                            @if($k->is_active)
                                <span class="badge badge-green">Aktif</span>
                            @else
                                <span class="badge badge-gray" style="background:#e2e8f0;color:#475569;">Tidak Aktif</span>
                            @endif
                        </td>
                        <td style="display:flex; gap:8px;">
                            @if(!$k->is_active)
                            <form action="{{ route('admin.harga.activate', $k->id) }}" method="POST">
                                @csrf @method('PATCH')
                                <button type="submit" class="btn btn-sm btn-secondary" title="Jadikan Aktif"><i class="fas fa-check"></i></button>
                            </form>
                            @endif
                            <a href="{{ route('admin.harga.edit', $k->id) }}" class="btn btn-sm btn-secondary" title="Edit"><i class="fas fa-edit"></i></a>
                            @if(!$k->is_active)
                            <form action="{{ route('admin.harga.destroy', $k->id) }}" method="POST" onsubmit="return confirm('Hapus konfigurasi ini?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-secondary" style="color:var(--red-500)" title="Hapus"><i class="fas fa-trash"></i></button>
                            </form>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" class="text-center text-muted" style="padding:24px;">Belum ada konfigurasi harga.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

@endsection
