<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Petani;
use Illuminate\Http\Request;
use App\Models\Lahan;
use Barryvdh\DomPDF\Facade\Pdf;

class PetaniController extends Controller
{
    public function index()
    {
        $petani = Petani::paginate(10);
        return view('admin.petani.index', compact('petani'));
    }

    public function create()
    {
        return view('admin.petani.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:255',
            'nik' => 'nullable|string|max:32',
            'alamat' => 'required|string',
            'telepon' => 'nullable|string|max:50',
            'no_hp' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:255|unique:petani,email',
            'tanggal_lahir' => 'nullable|date',
            'status' => 'required|string|in:aktif,nonaktif',
            'luas_lahan' => 'nullable|integer|min:0',
            'komoditas' => 'required|string|in:Padi,Jagung,Padi & Jagung',
            'catatan' => 'nullable|string',
        ]);

        $petani = Petani::create($data);

        // Jika user mengisi luas_lahan pada form Petani, buatkan juga entri Lahan
        // supaya fitur yang mengandalkan relasi lahan (mis. pencatatan panen) bekerja.
        if (! empty($data['luas_lahan']) && $data['luas_lahan'] > 0) {
            Lahan::create([
                'petani_id' => $petani->id,
                'nama_lahan' => 'Lahan utama',
                'luas' => $data['luas_lahan'],
                'lokasi' => $data['alamat'] ?? null,
                'status' => 'aktif',
            ]);
        }

        return redirect()->route('admin.petani.index')->with('success', 'Petani berhasil ditambahkan');
    }

    public function show(Petani $petani)
    {
        $petani->load('lahan');
        return view('admin.petani.show', compact('petani'));
    }

    public function edit(Petani $petani)
    {
        return view('admin.petani.edit', compact('petani'));
    }

    public function update(Request $request, Petani $petani)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:255',
            'nik' => 'nullable|string|max:32',
            'alamat' => 'required|string',
            'telepon' => 'nullable|string|max:50',
            'no_hp' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:255|unique:petani,email,' . $petani->id,
            'tanggal_lahir' => 'nullable|date',
            'status' => 'required|string|in:aktif,non-aktif,nonaktif',
            'luas_lahan' => 'nullable|integer|min:0',
            'komoditas' => 'required|string|in:Padi,Jagung,Padi & Jagung',
            'catatan' => 'nullable|string',
        ]);

        if ($data['status'] === 'non-aktif') {
            $data['status'] = 'nonaktif';
        }

        $petani->update($data);

        return redirect()->route('admin.petani.index')->with('success', 'Petani berhasil diperbarui');
    }

    public function destroy(Petani $petani)
    {
        $petani->delete();
        return redirect()->route('admin.petani.index')->with('success', 'Petani berhasil dihapus');
    }

    public function export()
    {
        $format = request('format', 'csv');
        $petani = Petani::all();

        if ($format === 'pdf') {
            try {
                $filename = 'petani_' . date('Ymd_His') . '.pdf';
                $pdf = Pdf::loadView('admin.petani.pdf', compact('petani'));
                return $pdf->download($filename);
            } catch (\Throwable $e) {
                return redirect()->back()->with('error', 'PDF export gagal. Pastikan barryvdh/laravel-dompdf telah terpasang.');
            }
        }

        if ($format === 'excel') {
            $filename = 'petani_' . date('Ymd_His') . '.xls';
            $html = '<table border="1"><thead><tr>' .
                '<th>No</th>' .
                '<th>Nama Petani</th>' .
                '<th>NIK</th>' .
                '<th>No. Telepon/HP</th>' .
                '<th>Email</th>' .
                '<th>Tanggal Lahir</th>' .
                '<th>Luas Lahan (m²)</th>' .
                '<th>Komoditas</th>' .
                '<th>Status</th>' .
                '<th>Alamat</th>' .
                '</tr></thead><tbody>';

            foreach ($petani as $index => $p) {
                $html .= '<tr>' .
                    '<td>' . ($index + 1) . '</td>' .
                    '<td>' . e($p->nama) . '</td>' .
                    '<td>' . e($p->nik ?? '-') . '</td>' .
                    '<td>' . e($p->telepon ?? '-') . '</td>' .
                    '<td>' . e($p->email ?? '-') . '</td>' .
                    '<td>' . e(optional($p->tanggal_lahir)->format('Y-m-d') ?? '-') . '</td>' .
                    '<td>' . ($p->luas_lahan !== null ? number_format($p->luas_lahan) : '-') . '</td>' .
                    '<td>' . e($p->komoditas) . '</td>' .
                    '<td>' . e($p->status === 'nonaktif' ? 'Non-aktif' : ucfirst($p->status)) . '</td>' .
                    '<td>' . e($p->alamat ?? '-') . '</td>' .
                    '</tr>';
            }

            $html .= '</tbody></table>';
            return response($html)
                ->header('Content-Type', 'application/vnd.ms-excel; charset=UTF-8')
                ->header('Content-Disposition', "attachment; filename={$filename}");
        }

        $csv = chr(0xEF) . chr(0xBB) . chr(0xBF);
        $csv .= "No,Nama Petani,NIK,No. Telepon/HP,Email,Tanggal Lahir,Luas Lahan (m²),Komoditas,Status,Alamat\n";
        foreach ($petani as $index => $p) {
            $csv .= implode(',', [
                $index + 1,
                '"' . str_replace('"', '""', $p->nama) . '"',
                '"' . str_replace('"', '""', $p->nik ?? '-') . '"',
                '"' . str_replace('"', '""', $p->telepon ?? '-') . '"',
                '"' . str_replace('"', '""', $p->email ?? '-') . '"',
                '"' . str_replace('"', '""', optional($p->tanggal_lahir)->format('Y-m-d') ?? '-') . '"',
                '"' . ($p->luas_lahan !== null ? number_format($p->luas_lahan) : '-') . '"',
                '"' . str_replace('"', '""', $p->komoditas) . '"',
                '"' . str_replace('"', '""', $p->status === 'nonaktif' ? 'Non-aktif' : ucfirst($p->status)) . '"',
                '"' . str_replace('"', '""', $p->alamat ?? '-') . '"',
            ]) . "\n";
        }

        $filename = 'petani_' . date('Ymd_His') . '.csv';
        return response($csv)
            ->header('Content-Type', 'text/csv; charset=UTF-8')
            ->header('Content-Disposition', "attachment; filename={$filename}");
    }
}