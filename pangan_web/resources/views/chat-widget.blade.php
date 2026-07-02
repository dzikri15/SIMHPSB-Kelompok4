<!-- ====================================================
     SIMHP Chat Widget — Prabowo AI
     Cara pakai: include file ini di layout admin.blade.php
     sebelum tag </body>, atau copy-paste langsung isinya.
==================================================== -->

<!-- Floating Chat Button -->
<div id="prabowo-chat-button" style="
    position: fixed;
    bottom: 24px;
    right: 24px;
    width: 60px;
    height: 60px;
    background: #16a34a;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(0,0,0,0.25);
    z-index: 9999;
    transition: transform 0.2s;
">
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
        <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/>
    </svg>
</div>

<!-- Chat Window -->
<div id="prabowo-chat-window" style="
    position: fixed;
    bottom: 96px;
    right: 24px;
    width: 360px;
    height: 480px;
    background: #1a1a1a;
    border-radius: 16px;
    box-shadow: 0 8px 30px rgba(0,0,0,0.4);
    display: none;
    flex-direction: column;
    overflow: hidden;
    z-index: 9999;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
">
    <!-- Header -->
    <div style="
        background: #16a34a;
        padding: 14px 16px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    ">
        <div style="display: flex; align-items: center; gap: 10px;">
            <div style="
                width: 36px; height: 36px;
                background: rgba(255,255,255,0.2);
                border-radius: 50%;
                display: flex; align-items: center; justify-content: center;
                font-size: 18px;
            ">🤖</div>
            <div>
                <div style="color: white; font-weight: 700; font-size: 14px;">HPSBBot</div>
                <div style="color: rgba(255,255,255,0.8); font-size: 11px;">Asisten AI SIMHP</div>
            </div>
        </div>
        <span id="prabowo-close-btn" style="color: white; cursor: pointer; font-size: 20px; line-height: 1;">&times;</span>
    </div>

    <!-- Messages -->
    <div id="prabowo-messages" style="
        flex: 1;
        overflow-y: auto;
        padding: 16px;
        display: flex;
        flex-direction: column;
        gap: 10px;
        background: #0f0f0f;
    ">
        <div style="
            background: #262626;
            color: #e5e5e5;
            padding: 10px 14px;
            border-radius: 12px;
            font-size: 13px;
            max-width: 85%;
            align-self: flex-start;
            line-height: 1.5;
        ">Halo Kak! Saya HPSBBot, asisten AI untuk SIMHP. Ada yang bisa saya bantu terkait stok, dan harga?</div>
    </div>

    <!-- Input -->
    <div style="
        padding: 12px;
        background: #1a1a1a;
        border-top: 1px solid #333;
        display: flex;
        gap: 8px;
    ">
        <input
            id="prabowo-input"
            type="text"
            placeholder="Tulis pertanyaan..."
            style="
                flex: 1;
                background: #262626;
                border: 1px solid #404040;
                border-radius: 20px;
                padding: 10px 16px;
                color: white;
                font-size: 13px;
                outline: none;
            "
        />
        <button id="prabowo-send-btn" style="
            background: #16a34a;
            border: none;
            border-radius: 50%;
            width: 38px;
            height: 38px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        ">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
                <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
            </svg>
        </button>
    </div>
</div>

<script>
(function () {
    // ── Ganti URL ini sesuai webhook n8n kamu ──────────────────────────
    // Chat diproxy lewat Laravel (route: /chatbot/prabowo), bukan langsung ke n8n.
    // Ini supaya browser hanya komunikasi dengan satu origin (server Laravel),
    // tidak perlu expose port n8n ke publik / kena isu CORS.
    const CHAT_ENDPOINT = '{{ route("chatbot.prabowo") }}';
    const CSRF_TOKEN = '{{ csrf_token() }}';

    const chatButton  = document.getElementById('prabowo-chat-button');
    const chatWindow  = document.getElementById('prabowo-chat-window');
    const closeBtn    = document.getElementById('prabowo-close-btn');
    const messagesBox = document.getElementById('prabowo-messages');
    const input       = document.getElementById('prabowo-input');
    const sendBtn     = document.getElementById('prabowo-send-btn');

    chatButton.addEventListener('click', () => {
        const isHidden = chatWindow.style.display === 'none';
        chatWindow.style.display = isHidden ? 'flex' : 'none';
    });

    closeBtn.addEventListener('click', () => {
        chatWindow.style.display = 'none';
    });

    function addMessage(text, sender) {
        const bubble = document.createElement('div');
        bubble.style.padding = '10px 14px';
        bubble.style.borderRadius = '12px';
        bubble.style.fontSize = '13px';
        bubble.style.maxWidth = '85%';
        bubble.style.lineHeight = '1.5';
        bubble.style.whiteSpace = 'pre-wrap';

        if (sender === 'user') {
            bubble.style.background = '#16a34a';
            bubble.style.color = 'white';
            bubble.style.alignSelf = 'flex-end';
        } else {
            bubble.style.background = '#262626';
            bubble.style.color = '#e5e5e5';
            bubble.style.alignSelf = 'flex-start';
        }

        bubble.textContent = text;
        messagesBox.appendChild(bubble);
        messagesBox.scrollTop = messagesBox.scrollHeight;
        return bubble;
    }

    async function sendMessage() {
        const text = input.value.trim();
        if (!text) return;

        addMessage(text, 'user');
        input.value = '';

        const loadingBubble = addMessage('Mengetik...', 'bot');

        try {
            const response = await fetch(CHAT_ENDPOINT, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': CSRF_TOKEN,
                    'Accept': 'application/json',
                },
                body: JSON.stringify({ message: text }),
            });

            const data = await response.json();
            loadingBubble.textContent = data.reply || 'Maaf Kak, ada kendala. Coba lagi ya.';
        } catch (err) {
            loadingBubble.textContent = 'Maaf Kak, gagal menghubungi server. Coba beberapa saat lagi.';
            console.error('Prabowo chat error:', err);
        }
    }

    sendBtn.addEventListener('click', sendMessage);
    input.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') sendMessage();
    });
})();
</script>