@extends('layout.admin')

@section('title', 'Detail Petani')
@section('page-title', 'Detail Data Petani')

@section('content')

<div class="card">
    <div style="margin-bottom:20px;">
        <a href="{{ route('admin.petani.index') }}" style="color:#0066cc; text-decoration:none;">← Kembali ke Data Petani</a>
    </div>

    <div style="display:grid; grid-template-columns:200px 1fr; gap:15px; margin-bottom:30px;">
        <div style="font-weight:bold;">Nama</div>
        <div>{{ $petani->nama }}</div>

        <div style="font-weight:bold;">Alamat</div>
        <div>{{ $petani->alamat }}</div>

        <div style="font-weight:bold;">No HP</div>
        <div>{{ $petani->no_hp ?? '-' }}</div>

        <div style="font-weight:bold;">Email</div>
        <div>{{ $petani->email ?? '-' }}</div>

        <div style="font-weight:bold;">Tanggal Lahir</div>
        <div>{{ $petani->tanggal_lahir ? \Carbon\Carbon::parse($petani->tanggal_lahir)->format('d M Y') : '-' }}</div>

        <div style="font-weight:bold;">Status</div>
        <div>
            <span style="padding:4px 8px; border-radius:4px; color:white; font-size:12px; background-color:{{ $petani->status === 'aktif' ? '#28a745' : '#dc3545' }};">
                {{ ucfirst($petani->status) }}
            </span>
        </div>

        <div style="font-weight:bold;">Terdaftar</div>
        <div>{{ $petani->created_at->format('d M Y H:i') }}</div>
    </div>

    <div style="border-top:1px solid #ddd; padding-top:20px;">
        <h3>Data Lahan</h3>

        @if ($petani->lahan->count() > 0)
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Nama Lahan</th>
                        <th>Luas (ha)</th>
                        <th>Lokasi</th>
                        <th>Jenis Tanah</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($petani->lahan as $lahan)
                        <tr>
                            <td>{{ $loop->iteration }}</td>
                            <td>{{ $lahan->nama_lahan }}</td>
                            <td>{{ $lahan->luas }}</td>
                            <td style="font-size:12px;">{{ $lahan->lokasi }}</td>
                            <td>{{ ucfirst($lahan->jenis_tanah) }}</td>
                            <td>
                                <span style="padding:4px 8px; border-radius:4px; color:white; font-size:12px; background-color:{{ $lahan->status === 'aktif' ? '#28a745' : '#dc3545' }};">
                                    {{ ucfirst($lahan->status) }}
                                </span>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        @else
            <p style="color:#999; font-style:italic;">Belum ada data lahan untuk petani ini</p>
        @endif
    </div>

    <div style="display:flex; gap:10px; margin-top:20px;">
        <a href="{{ route('admin.petani.edit', $petani) }}" style="background-color:#ff9800; color:white; padding:10px 20px; border-radius:4px; text-decoration:none; display:inline-block;">
            ✏️ Edit
        </a>
        <form action="{{ route('admin.petani.destroy', $petani) }}" method="POST" style="display:inline;" onsubmit="return confirm('Yakin hapus?')">
            @csrf
            @method('DELETE')
            <button type="submit" style="background-color:#dc3545; color:white; padding:10px 20px; border:none; border-radius:4px; cursor:pointer;">
                🗑️ Hapus
            </button>
        </form>
        <a href="{{ route('admin.petani.index') }}" style="background-color:#6c757d; color:white; padding:10px 20px; border-radius:4px; text-decoration:none; display:inline-block;">
            Kembali
        </a>
    </div>
</div>

@endsection
