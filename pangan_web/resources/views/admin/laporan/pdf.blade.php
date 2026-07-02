<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Laporan {{ ucfirst($jenis ?? 'stok') }}</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; font-size:12px; color:#333; margin:0; padding:0; }
        .page { padding:20px; }
        .header { display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:18px; }
        .header-left { max-width:70%; }
        .header h2 { margin:0 0 4px; font-size:18px; }
        .meta { font-size:11px; color:#555; line-height:1.5; }
        .badge { display:inline-block; background:#2f855a; color:#fff; padding:4px 10px; border-radius:999px; font-size:11px; margin-top:6px; }
        .info-box { margin-bottom:14px; padding:12px 14px; background:#f7fafc; border:1px solid #e2e8f0; border-radius:10px; }
        table { width:100%; border-collapse:collapse; margin-top:10px; }
        th, td { border:1px solid #cbd5e1; padding:8px 10px; text-align:left; vertical-align:top; }
        th { background:#edf2f7; font-weight:700; }
        tbody tr:nth-child(odd) { background:#fff; }
        tbody tr:nth-child(even) { background:#f8fafc; }
    </style>
</head>
<body>
    <div class="page">
        <div class="header">
            <div class="header-left">
                <h2>Laporan {{ ucfirst($jenis ?? 'stok') }}</h2>
                <div class="meta">Periode: {{ $dari }} — {{ $sampai }}</div>
                @if(!empty($petaniLabel))
                    <div class="meta">Filter Petani: <strong>{{ $petaniLabel }}</strong></div>
                @endif
                @if(!empty($komoditas) && $jenis === 'stok')
                    <div class="meta">Filter Komoditas: <strong>{{ $komoditas }}</strong></div>
                @elseif($jenis === 'stok')
                    <div class="meta">Filter Komoditas: <strong>Semua Komoditas</strong></div>
                @endif
            </div>
            <div class="badge">Tanggal cetak: {{ date('Y-m-d') }}</div>
        </div>

        <div class="info-box">
            <strong>Ringkasan:</strong>
            <div>Jenis laporan: {{ ucfirst($jenis === 'stok' ? 'Stok' : 'Panen') }}.</div>
            <div>Jumlah baris: {{ $items->count() }}</div>
        </div>

        <table>
            <thead>
                <tr>
                    <th>No</th>
                    @if(($jenis ?? 'stok') === 'stok')
                        <th>Gudang</th>
                        <th>Komoditas</th>
                        <th>Jumlah Stok (kg)</th>
                        <th>Batas Minimum (kg)</th>
                        <th>Tanggal Update</th>
                        <th>Catatan</th>
                    @else
                        <th>Petani</th>
                        <th>Lahan (m²)</th>
                        <th>Jumlah Gabah (kg)</th>
                        <th>Tanggal Panen</th>
                    @endif
                </tr>
            </thead>
            <tbody>
                @foreach($items as $i => $item)
                    <tr>
                        <td>{{ $i + 1 }}</td>
                        @if(($jenis ?? 'stok') === 'stok')
                            <td>{{ $item->gudang->nama_gudang ?? '-' }}</td>
                            <td>{{ $item->komoditas ?? '-' }}</td>
                            <td>{{ number_format($item->jumlah_stok) }}</td>
                            <td>{{ number_format($item->batas_minimum) }}</td>
                            <td>{{ optional($item->tanggal_update)->format('Y-m-d H:i:s') }}</td>
                            <td>{{ $item->catatan ?? '-' }}</td>
                        @else
                            <td>{{ $item->petani->nama ?? '-' }}</td>
                            <td>{{ number_format(optional($item->petani)->luas_lahan ?? 0) }}</td>
                            <td>{{ number_format($item->jumlah_gabah) }}</td>
                            <td>{{ optional($item->tanggal_panen)->format('Y-m-d') }}</td>
                        @endif
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</body>
</html>