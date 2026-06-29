<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ChatbotController extends Controller
{
    /**
     * POST /chatbot/prabowo
     * Proxy request dari chat widget (browser) ke n8n webhook.
     * Tujuannya supaya browser hanya komunikasi dengan satu origin
     * (server Laravel via nginx), bukan langsung ke n8n.
     */
    public function send(Request $request)
    {
        $data = $request->validate([
            'message' => 'required|string|max:1000',
        ]);

        // URL internal n8n di dalam Docker network.
        // Diambil dari .env supaya mudah diganti saat pindah ke VPS.
        $n8nConfig = config('services.n8n', []);
        $n8nWebhookUrl = $n8nConfig['webhook_url'] ?? 'http://n8n:5678/webhook/simhpsb-chat';

        $http = Http::timeout(30);
        if (!empty($n8nConfig['username']) && !empty($n8nConfig['password'])) {
            $http = $http->withBasicAuth($n8nConfig['username'], $n8nConfig['password']);
        }

        try {
            $response = $http->post($n8nWebhookUrl, [
                'message' => $data['message'],
            ]);

            if ($response->failed()) {
                return response()->json([
                    'reply' => 'Maaf Kak, HPSBBot sedang tidak bisa diakses. Coba lagi sebentar ya.',
                ], 200);
            }

            $result = $response->json();

            return response()->json([
                'reply' => $result['reply'] ?? 'Maaf Kak, ada kendala saat memproses pesan.',
            ]);
        } catch (\Exception $e) {
            \Log::error('Chatbot HPSBBot error: ' . $e->getMessage());

            return response()->json([
                'reply' => 'Maaf Kak, gagal menghubungi HPSBBot. Coba beberapa saat lagi.',
            ], 200);
        }
    }
}
