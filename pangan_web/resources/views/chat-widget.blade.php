{{-- ====================================================
     SIMHP Chat Widget — HPSBBot
     Include di layout admin.blade.php sebelum </body>
==================================================== --}}

{{-- Floating Chat Button --}}
<div id="chat-fab" onclick="chatToggle()" title="Chat dengan HPSBBot" aria-label="Buka chat HPSBBot">
    {{-- Icon chat (default) --}}
    <svg id="chat-fab-icon-open" width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/>
    </svg>
    {{-- Icon X (saat chat terbuka) --}}
    <svg id="chat-fab-icon-close" width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" style="display:none;">
        <line x1="18" y1="6" x2="6" y2="18"/>
        <line x1="6" y1="6" x2="18" y2="18"/>
    </svg>
</div>

{{-- Chat Window --}}
<div id="chat-window">
    {{-- Header --}}
    <div id="chat-header">
        <div style="display:flex;align-items:center;gap:10px;">
            <div id="chat-bot-avatar">🤖</div>
            <div>
                <div style="color:white;font-weight:700;font-size:14px;line-height:1.2;">HPSBBot</div>
                <div style="color:rgba(255,255,255,0.75);font-size:11px;">Asisten AI SIMHP</div>
            </div>
        </div>
        <button onclick="chatToggle()" id="chat-close-btn" title="Tutup chat" aria-label="Tutup chat">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round">
                <line x1="18" y1="6" x2="6" y2="18"/>
                <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
        </button>
    </div>

    {{-- Messages --}}
    <div id="chat-messages">
        <div class="chat-bubble bot">Halo Kak! Saya HPSBBot, asisten AI untuk SIMHP. Ada yang bisa saya bantu terkait stok dan harga? 🌾</div>
    </div>

    {{-- Input --}}
    <div id="chat-input-area">
        <input
            id="chat-input"
            type="text"
            placeholder="Tulis pertanyaan..."
            autocomplete="off"
            onkeypress="if(event.key==='Enter')chatSend()"
        />
        <button id="chat-send-btn" onclick="chatSend()" title="Kirim" aria-label="Kirim pesan">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
                <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
            </svg>
        </button>
    </div>
</div>

<style>
/* ── FAB Button ── */
#chat-fab {
    position: fixed;
    bottom: 24px;
    right: 24px;
    width: 56px;
    height: 56px;
    background: linear-gradient(135deg, #16a34a, #15803d);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 4px 16px rgba(22,163,74,0.45);
    z-index: 10000;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    user-select: none;
}
#chat-fab:hover {
    transform: scale(1.08);
    box-shadow: 0 6px 24px rgba(22,163,74,0.6);
}
#chat-fab:active { transform: scale(0.95); }

/* ── Chat Window ── */
#chat-window {
    position: fixed;
    bottom: 90px;
    right: 24px;
    width: 340px;
    height: 460px;
    max-height: calc(100vh - 110px);
    background: #111827;
    border-radius: 18px;
    box-shadow: 0 12px 40px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.07);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    z-index: 9999;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    /* Animation */
    transform: scale(0.85) translateY(20px);
    opacity: 0;
    pointer-events: none;
    transform-origin: bottom right;
    transition: transform 0.25s cubic-bezier(0.34,1.56,0.64,1), opacity 0.2s ease;
}
#chat-window.open {
    transform: scale(1) translateY(0);
    opacity: 1;
    pointer-events: all;
}

/* ── Header ── */
#chat-header {
    background: linear-gradient(135deg, #16a34a, #15803d);
    padding: 12px 14px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-shrink: 0;
}
#chat-bot-avatar {
    width: 34px;
    height: 34px;
    background: rgba(255,255,255,0.18);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 17px;
}
#chat-close-btn {
    background: rgba(255,255,255,0.15);
    border: none;
    border-radius: 8px;
    width: 30px;
    height: 30px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.15s;
    padding: 0;
}
#chat-close-btn:hover { background: rgba(255,255,255,0.28); }

/* ── Messages ── */
#chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 14px;
    display: flex;
    flex-direction: column;
    gap: 9px;
    background: #0d1117;
    scroll-behavior: smooth;
}
#chat-messages::-webkit-scrollbar { width: 4px; }
#chat-messages::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.12); border-radius: 4px; }

.chat-bubble {
    padding: 9px 13px;
    border-radius: 14px;
    font-size: 13px;
    max-width: 85%;
    line-height: 1.55;
    white-space: pre-wrap;
    word-break: break-word;
    animation: bubblePop 0.18s ease;
}
@keyframes bubblePop {
    from { opacity: 0; transform: scale(0.92) translateY(4px); }
    to   { opacity: 1; transform: scale(1) translateY(0); }
}
.chat-bubble.bot {
    background: #1f2937;
    color: #e5e7eb;
    align-self: flex-start;
    border-bottom-left-radius: 4px;
}
.chat-bubble.user {
    background: linear-gradient(135deg, #16a34a, #15803d);
    color: white;
    align-self: flex-end;
    border-bottom-right-radius: 4px;
}
.chat-bubble.typing {
    background: #1f2937;
    color: #6b7280;
    align-self: flex-start;
}

/* ── Input Area ── */
#chat-input-area {
    padding: 10px 12px;
    background: #111827;
    border-top: 1px solid rgba(255,255,255,0.07);
    display: flex;
    gap: 8px;
    align-items: center;
    flex-shrink: 0;
}
#chat-input {
    flex: 1;
    background: #1f2937;
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 20px;
    padding: 9px 14px;
    color: white;
    font-size: 13px;
    outline: none;
    transition: border-color 0.2s;
    font-family: inherit;
}
#chat-input:focus { border-color: rgba(22,163,74,0.6); }
#chat-input::placeholder { color: #6b7280; }
#chat-send-btn {
    background: linear-gradient(135deg, #16a34a, #15803d);
    border: none;
    border-radius: 50%;
    width: 36px;
    height: 36px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    transition: transform 0.15s, box-shadow 0.15s;
    box-shadow: 0 2px 8px rgba(22,163,74,0.4);
}
#chat-send-btn:hover { transform: scale(1.08); }
#chat-send-btn:active { transform: scale(0.93); }

/* ── Mobile responsive ── */
@media (max-width: 480px) {
    #chat-window {
        width: calc(100vw - 24px);
        right: 12px;
        bottom: 82px;
        height: min(460px, calc(100vh - 110px));
    }
    #chat-fab {
        bottom: 16px;
        right: 16px;
        width: 52px;
        height: 52px;
    }
}
</style>

<script>
(function () {
    const CHAT_ENDPOINT = '{{ route("chatbot.prabowo") }}';
    const CSRF_TOKEN    = '{{ csrf_token() }}';

    const fab       = document.getElementById('chat-fab');
    const win       = document.getElementById('chat-window');
    const messages  = document.getElementById('chat-messages');
    const input     = document.getElementById('chat-input');
    const iconOpen  = document.getElementById('chat-fab-icon-open');
    const iconClose = document.getElementById('chat-fab-icon-close');

    let isOpen = false;

    window.chatToggle = function () {
        isOpen = !isOpen;
        win.classList.toggle('open', isOpen);
        iconOpen.style.display  = isOpen ? 'none'  : 'block';
        iconClose.style.display = isOpen ? 'block' : 'none';
        if (isOpen) {
            setTimeout(() => input.focus(), 250);
        }
    };

    function addBubble(text, type) {
        const b = document.createElement('div');
        b.className = `chat-bubble ${type}`;
        b.textContent = text;
        messages.appendChild(b);
        messages.scrollTop = messages.scrollHeight;
        return b;
    }

    window.chatSend = async function () {
        const text = input.value.trim();
        if (!text) return;
        addBubble(text, 'user');
        input.value = '';
        const loading = addBubble('Mengetik...', 'typing');

        try {
            const res  = await fetch(CHAT_ENDPOINT, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': CSRF_TOKEN,
                    'Accept': 'application/json',
                },
                body: JSON.stringify({ message: text }),
            });
            const data = await res.json();
            loading.className = 'chat-bubble bot';
            loading.textContent = data.reply || 'Maaf Kak, tidak ada respons. Coba lagi ya.';
        } catch {
            loading.className = 'chat-bubble bot';
            loading.textContent = 'Maaf Kak, gagal menghubungi server.';
        }
        messages.scrollTop = messages.scrollHeight;
    };
})();
</script>