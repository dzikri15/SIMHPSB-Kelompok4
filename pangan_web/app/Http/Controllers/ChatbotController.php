<?php

namespace App\Http\Controllers;

use App\Models\KonfigurasiHarga;
use App\Models\Stok;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ChatbotController extends Controller
{
    /**
     * POST /chatbot/prabowo
     * Langsung panggil Gemini API dengan konteks data dari database.
     * Tidak perlu n8n — lebih simpel dan lebih cepat.
     */
    public function send(Request $request)
    {
        $data = $request->validate([
            'message' => 'required|string|max:1000',
        ]);

        $geminiKey   = config('services.gemini.api_key');
        $geminiModel = 'gemini-2.0-flash'; // hardcoded — tidak dipengaruhi env Docker

        if (empty($geminiKey)) {
            return response()->json([
                'reply' => 'Maaf Kak, HPSBBot belum dikonfigurasi. Hubungi admin.',
            ]);
        }

        // ── Ambil konteks data dari database ─────────────────────────────────
        $konteks = $this->buildKonteks();

        // ── Buat system prompt ────────────────────────────────────────────────
        $systemPrompt = <<<PROMPT
Kamu adalah HPSBBot, asisten AI untuk Sistem Informasi Monitoring Hasil Panen (SIMHP) Kelompok 4.
Tugasmu membantu admin dan petugas menjawab pertanyaan seputar stok beras dan harga pangan.

Data terkini dari sistem:
{$konteks}

Aturan menjawab:
- Gunakan Bahasa Indonesia yang ramah dan sopan.
- Jawab singkat, padat, dan akurat berdasarkan data di atas.
- Jika data tidak tersedia, katakan dengan jujur.
- Jangan membuat angka atau data fiktif.
- Panggil pengguna dengan "Kak".
PROMPT;

        // ── Kirim ke Gemini API ───────────────────────────────────────────────
        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$geminiModel}:generateContent?key={$geminiKey}";

        try {
            $response = Http::timeout(30)->post($url, [
                'system_instruction' => [
                    'parts' => [['text' => $systemPrompt]],
                ],
                'contents' => [
                    [
                        'role'  => 'user',
                        'parts' => [['text' => $data['message']]],
                    ],
                ],
                'generationConfig' => [
                    'temperature'     => 0.7,
                    'maxOutputTokens' => 512,
                ],
            ]);

            if ($response->failed()) {
                $statusCode = $response->status();
                $body       = $response->body();
                Log::error("Gemini API error [{$statusCode}]: {$body}");

                // Pesan debug sementara — hapus setelah masalah teridentifikasi
                $errJson = $response->json();
                $errMsg  = $errJson['error']['message'] ?? $body;

                if ($statusCode === 429) {
                    return response()->json(['reply' => "Debug [429]: {$errMsg}"]);
                }
                if ($statusCode === 400) {
                    return response()->json(['reply' => "Debug [400]: {$errMsg}"]);
                }
                return response()->json(['reply' => "Debug [{$statusCode}]: {$errMsg}"]);
            }

            $result = $response->json();
            $reply  = $result['candidates'][0]['content']['parts'][0]['text']
                      ?? 'Maaf Kak, tidak ada respons dari HPSBBot.';

            return response()->json(['reply' => trim($reply)]);

        } catch (\Exception $e) {
            Log::error('ChatbotController error: ' . $e->getMessage());
            return response()->json([
                'reply' => 'Debug Exception: ' . $e->getMessage(),
            ]);
        }
    }

    /**
     * Bangun konteks data dari database untuk dikirim ke Gemini.
     */
    private function buildKonteks(): string
    {
        $lines = [];

        // ── Harga aktif ───────────────────────────────────────────────────────
        $harga = KonfigurasiHarga::where('is_active', true)
            ->latest('berlaku_mulai')
            ->first();

        if ($harga) {
            $lines[] = "=== HARGA AKTIF ===";
            $lines[] = "Harga Beli Gabah : Rp " . number_format($harga->harga_beli_gabah, 0, ',', '.');
            $lines[] = "Harga Jual Beras : Rp " . number_format($harga->harga_jual_beras, 0, ',', '.');
            if ($harga->ongkos_giling) {
                $lines[] = "Ongkos Giling    : Rp " . number_format($harga->ongkos_giling, 0, ',', '.');
            }
            if ($harga->rasio_konversi) {
                $lines[] = "Rasio Konversi   : " . $harga->rasio_konversi;
            }
            $lines[] = "Berlaku Mulai    : " . optional($harga->berlaku_mulai)->format('d M Y');
        } else {
            $lines[] = "=== HARGA === Belum ada konfigurasi harga aktif.";
        }

        // ── Total Stok Saat Ini ──────────────────────────────────────────────
        $stokBeras = Stok::where('komoditas', 'Beras')
            ->where(function($q) { $q->where('status', 'aktif')->orWhereNull('status'); })
            ->latest('tanggal_update')
            ->value('jumlah_stok') ?: 0;

        $stokGabah = Stok::where('komoditas', 'Gabah')
            ->where(function($q) { $q->where('status', 'aktif')->orWhereNull('status'); })
            ->latest('tanggal_update')
            ->value('jumlah_stok') ?: 0;

        $lines[] = "";
        $lines[] = "=== TOTAL STOK SAAT INI ===";
        $lines[] = "Stok Beras : " . number_format($stokBeras, 0, ',', '.') . " kg";
        $lines[] = "Stok Gabah : " . number_format($stokGabah, 0, ',', '.') . " kg";

        // ── Stok terbaru (5 transaksi terakhir) ──────────────────────────────
        $stoks = Stok::latest('tanggal_update')->take(5)->get();

        if ($stoks->isNotEmpty()) {
            $lines[] = "";
            $lines[] = "=== 5 TRANSAKSI TERAKHIR ===";
            foreach ($stoks as $s) {
                $tgl    = optional($s->tanggal_update)->format('d M Y') ?? '-';
                $jumlah = number_format($s->jumlah, 0, ',', '.'); // gunakan jumlah transaksinya saja
                $jenis  = $s->jenis_transaksi ?? '-';
                $lines[] = "- [{$tgl}] {$s->komoditas}: {$jumlah} kg ({$jenis})";
            }
        } else {
            $lines[] = "";
            $lines[] = "=== TRANSAKSI === Belum ada data transaksi.";
        }

        return implode("\n", $lines);
    }
}
