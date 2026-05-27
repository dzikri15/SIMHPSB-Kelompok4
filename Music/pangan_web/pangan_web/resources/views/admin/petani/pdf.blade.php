<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Data Petani</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; font-size:12px; }
        h2 { margin-bottom: 4px; }
        .meta { margin-bottom: 12px; color: #444; }
        table { width:100%; border-collapse:collapse; }
        th, td { border:1px solid #ccc; padding:6px; text-align:left; }
        th { background:#f3f4f6; }
    </style>
</head>
<body>
    <h2>Data Petani</h2>
    <div class="meta">Tanggal export: {{ date('Y-m-d H:i:s') }}</div>
    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Nama</th>
                <th>NIK</th>
                <th>No HP</th>
                <th>Email</th>
                <th>Alamat</th>
                <th>Luas Lahan</th>
                <th>Komoditas</th>
                <th>Status</th>
                <th>Tgl Lahir</th>
            </tr>
        </thead>
        <tbody>
            @foreach($petani as $index => $item)
                <tr>
                    <td>{{ $index + 1 }}</td>
                    <td>{{ $item->nama }}</td>
                    <td>{{ $item->nik ?? '-' }}</td>
                    <td>{{ $item->telepon ?? '-' }}</td>
                    <td>{{ $item->email ?? '-' }}</td>
                    <td>{{ $item->alamat ?? '-' }}</td>
                    <td>{{ number_format($item->luas_lahan ?? 0) }} m²</td>
                    <td>{{ $item->komoditas }}</td>
                    <td>{{ $item->status === 'nonaktif' ? 'Non-aktif' : ucfirst($item->status) }}</td>
                    <td>{{ optional($item->tanggal_lahir)->format('Y-m-d') ?? '-' }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>
