<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SIMHP</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800;900&family=Lora:ital,wght@1,400;1,600&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r155/three.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/ScrollTrigger.min.js"></script>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }
        body { cursor: none; }
        html, body {
            width: 100%; min-height: 100%;
            overflow-x: hidden; overflow-y: auto;
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: #060f09;
        }
        nav {
            position: fixed; top: 0; left: 0; right: 0; z-index: 1000;
            display: flex; align-items: center; justify-content: space-between;
            padding: 18px 40px;
            background: rgba(6,15,9,.85);
            backdrop-filter: blur(16px);
            border-bottom: 1px solid rgba(79,213,133,.1);
            opacity: 0;
            transform: translateY(-20px);
            transition: padding 0.4s;
        }
        nav.scrolled { padding: 14px 40px; }
        .nav-brand { display: flex; align-items: center; gap: 12px; text-decoration: none; }
        .nav-logo {
            width: 36px; height: 36px;
            background: linear-gradient(145deg, #3ecf74, #22a157);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px;
        }
        .nav-name { font-size: 16px; font-weight: 800; color: #fff; }
        .nav-links { display: flex; gap: 24px; align-items: center; }
        .nav-links a {
            font-size: 13px; color: rgba(255,255,255,.55);
            text-decoration: none; font-weight: 500;
            transition: color .2s;
        }
        .nav-links a:hover, .nav-links a.active { color: #4fd585; }
        .nav-cta {
            padding: 8px 20px;
            background: linear-gradient(135deg, #38a169, #2b7a4f);
            color: #fff !important;
            border-radius: 10px;
            font-weight: 700 !important;
            font-size: 13px !important;
            transition: box-shadow .2s, transform .2s !important;
            box-shadow: 0 4px 14px rgba(56,161,105,.3);
        }
        .nav-cta:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(56,161,105,.45) !important; }
        .nav-download {
            display: inline-flex; align-items: center; gap: 8px;
            color: #d6f6d3; text-decoration: none; font-weight: 700; font-size: 13px;
            padding: 8px 14px; border: 1px solid rgba(79,213,133,.25);
            border-radius: 10px; transition: background .2s, border-color .2s;
        }
        .nav-download:hover { background: rgba(79,213,133,.08); border-color: rgba(79,213,133,.45); }
        .nav-toggle {
            display: none; border: none; background: transparent; color: #fff;
            cursor: pointer; width: 38px; height: 38px; border-radius: 12px;
            align-items: center; justify-content: center; transition: background .2s;
        }
        .nav-toggle:hover { background: rgba(79,213,133,.08); }
        .nav-toggle span { display: block; width: 20px; height: 2px; background: #fff; border-radius: 999px; position: relative; }
        .nav-toggle span::before, .nav-toggle span::after {
            content: ''; position: absolute; left: 0; width: 20px; height: 2px;
            background: #fff; border-radius: 999px; transition: transform .2s ease;
        }
        .nav-toggle span::before { top: -6px; }
        .nav-toggle span::after { top: 6px; }
        @media (max-width: 860px) {
            nav { padding: 14px 24px; gap: 12px; flex-wrap: wrap; justify-content: space-between; }
            .nav-logo { width: 32px; height: 32px; }
            .nav-name { font-size: 14px; }
            .nav-toggle { display: inline-flex; }
            .nav-links { display: none; width: 100%; flex-direction: column; gap: 12px; margin-top: 14px; }
            nav.open .nav-links { display: flex; }
            .nav-links a { padding: 12px 16px; background: rgba(15,33,24,.92); border-radius: 12px; }
            .nav-cta { padding: 10px 16px; font-size: 12px !important; width: 100%; }
        }
        @media (max-width: 560px) {
            nav { padding: 14px 18px; }
            .nav-links { justify-content: stretch; gap: 10px; padding: 10px 0 0; }
            .nav-links a, .nav-cta { text-align: center; }
        }
        #page {
            position: relative; min-height: 100vh; background: #060f09;
            display: flex; align-items: center; justify-content: center; padding: 60px 0;
        }
        .amb { position: absolute; border-radius: 50%; filter: blur(100px); pointer-events: none; }
        .amb-1 { width: 700px; height: 700px; background: radial-gradient(circle, rgba(34,100,60,.35) 0%, transparent 65%); top: -200px; left: -150px; }
        .amb-2 { width: 500px; height: 500px; background: radial-gradient(circle, rgba(56,161,105,.2) 0%, transparent 65%); bottom: -150px; right: -100px; }
        .amb-3 { width: 350px; height: 350px; background: radial-gradient(circle, rgba(79,213,133,.1) 0%, transparent 65%); top: 50%; left: 55%; transform: translate(-50%, -50%); }
        #page::after {
            content: ''; position: absolute; inset: 0;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.75' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.04'/%3E%3C/svg%3E");
            pointer-events: none; z-index: 1;
        }
        .grid-lines {
            position: absolute; inset: 0;
            background-image: linear-gradient(rgba(255,255,255,.025) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.025) 1px, transparent 1px);
            background-size: 72px 72px; pointer-events: none;
            mask-image: radial-gradient(ellipse 80% 70% at 50% 50%, black 20%, transparent 80%);
        }
        #dots-canvas { position: absolute; inset: 0; pointer-events: none; }
        #threeSceneWrapper { position: absolute; inset: 0; z-index: 2; overflow: hidden; pointer-events: none; }
        #threeScene { width: 100%; height: 100%; display: block; }
        .scene-overlay { position: absolute; inset: 0; pointer-events: none; background: linear-gradient(180deg, rgba(6,15,9,0) 0%, rgba(6,15,9,.55) 55%, rgba(6,15,9,.95) 100%); }
        .scene-layer { position: absolute; width: 280px; height: 280px; border-radius: 28px; background: radial-gradient(circle at 30% 30%, rgba(126,232,161,.35), transparent 55%); box-shadow: 0 0 80px rgba(79,213,133,.12); opacity: .6; transform-origin: center; }
        .scene-layer-1 { top: 12%; left: 8%; transform: rotate(-12deg) scale(1.05); }
        .scene-layer-2 { top: 8%; right: 8%; width: 340px; height: 220px; transform: rotate(8deg) scale(.96); }
        .scene-layer-3 { bottom: 10%; left: 14%; width: 360px; height: 240px; transform: rotate(-6deg) scale(.88); }
        .content { position: relative; z-index: 10; display: flex; flex-direction: column; align-items: center; text-align: center; padding: 0 24px; }
        .badge {
            display: inline-flex; align-items: center; gap: 7px; padding: 6px 14px 6px 8px;
            background: rgba(79,213,133,.1); border: 1px solid rgba(79,213,133,.25); border-radius: 100px;
            font-size: 11.5px; font-weight: 600; color: #4fd585; letter-spacing: 0.04em; text-transform: uppercase;
            margin-bottom: 28px; opacity: 0; transform: translateY(10px);
        }
        .badge-dot { width: 6px; height: 6px; border-radius: 50%; background: #4fd585; box-shadow: 0 0 8px #4fd585; animation: pulse-dot 2s ease-in-out infinite; }
        @keyframes pulse-dot { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: .5; transform: scale(.7); } }
        .logo-wrap {
            position: relative; margin-bottom: 24px; opacity: 0;
            transform: perspective(1000px) scale(.7) translateY(20px) rotateY(180deg);
            transform-style: preserve-3d; transform-origin: center; cursor: pointer;
        }
        .logo-container { transform-style: preserve-3d; perspective: 1000px; cursor: pointer; }
        .logo-icon {
            width: 150px; height: 150px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center; font-size: 50px;
            background: transparent;
        }
        .logo-img { filter: drop-shadow(0 20px 30px rgba(46,125,50,.4)); transition: filter .3s ease; }
        .logo-img:hover { filter: drop-shadow(0 30px 40px rgba(46,125,50,.6)); }
        .logo-ring { position: absolute; inset: -14px; border-radius: 50%; border: 1.5px solid rgba(79,213,133,.2); animation: ring-pulse 3s ease-in-out infinite; }
        .logo-ring-2 { position: absolute; inset: -28px; border-radius: 50%; border: 1.5px solid rgba(79,213,133,.08); animation: ring-pulse 3s ease-in-out infinite .5s; }
        @keyframes ring-pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: .3; transform: scale(1.04); } }
        .logo-ring-spin {
            position: absolute;
            inset: -20px;
            border-radius: 50%;
            background: conic-gradient(from 0deg, transparent 0%, rgba(79,213,133,.75) 12%, transparent 26%, transparent 100%);
            -webkit-mask: radial-gradient(farthest-side, transparent calc(100% - 3.5px), #000 calc(100% - 3.5px));
                    mask: radial-gradient(farthest-side, transparent calc(100% - 3.5px), #000 calc(100% - 3.5px));
            animation: ring-spin 4s linear infinite;
            will-change: transform;
        }
        .logo-ring-spin-2 {
            position: absolute;
            inset: -36px;
            border-radius: 50%;
            background: conic-gradient(from 180deg, transparent 0%, rgba(126,232,161,.4) 10%, transparent 22%, transparent 100%);
            -webkit-mask: radial-gradient(farthest-side, transparent calc(100% - 2.5px), #000 calc(100% - 2.5px));
                    mask: radial-gradient(farthest-side, transparent calc(100% - 2.5px), #000 calc(100% - 2.5px));
            animation: ring-spin 6s linear infinite reverse;
            will-change: transform;
        }
        @keyframes ring-spin { to { transform: rotate(360deg); } }
        .title {
            font-size: clamp(56px, 10vw, 96px); font-weight: 900; color: #fff;
            letter-spacing: -4px; line-height: .95; margin-bottom: 16px;
            padding-right: 12px; padding-bottom: 4px; overflow: visible;
        }
        .title-char { display: inline-block; opacity: 0; transform: translateY(80px) rotate(4deg); }
        .subtitle {
            font-family: 'Lora', serif; font-style: italic; font-size: clamp(13px, 1.8vw, 15.5px);
            color: rgba(255,255,255,.4); line-height: 1.8; margin-bottom: 44px;
            opacity: 0; transform: translateY(16px); max-width: 380px;
        }
        .divider { width: 1px; height: 0; background: linear-gradient(180deg, transparent, rgba(79,213,133,.5), transparent); margin: 0 auto 32px; }
        .stats { display: flex; gap: 0; margin-bottom: 44px; opacity: 0; transform: translateY(16px); }
        .stat { padding: 14px 28px; text-align: center; border-right: 1px solid rgba(255,255,255,.07); }
        .stat:last-child { border-right: none; }
        .stat-num { font-size: 22px; font-weight: 800; color: #fff; letter-spacing: -1px; display: block; }
        .stat-label { font-size: 11px; color: rgba(255,255,255,.35); text-transform: uppercase; letter-spacing: .08em; margin-top: 2px; display: block; }
        .cta-wrap { display: flex; flex-direction: column; align-items: center; gap: 14px; opacity: 0; transform: translateY(20px); }
        .btn-primary {
            position: relative; display: inline-flex; align-items: center; gap: 10px; padding: 15px 36px;
            background: linear-gradient(135deg, #38a169, #2b7a4f); color: #fff; border: none; border-radius: 14px;
            font-family: 'Plus Jakarta Sans', sans-serif; font-size: 14.5px; font-weight: 700; cursor: pointer;
            letter-spacing: .01em; overflow: hidden; transition: box-shadow .3s, transform .2s;
            box-shadow: 0 4px 20px rgba(56,161,105,.35), 0 0 0 1px rgba(79,213,133,.2);
        }
        .btn-primary::before { content: ''; position: absolute; inset: 0; background: linear-gradient(135deg, rgba(255,255,255,.12) 0%, transparent 60%); border-radius: inherit; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 32px rgba(56,161,105,.5), 0 0 0 1px rgba(79,213,133,.35); }
        .btn-primary:active { transform: translateY(0); }
        .btn-arrow { width: 20px; height: 20px; background: rgba(255,255,255,.15); border-radius: 6px; display: flex; align-items: center; justify-content: center; transition: transform .2s, background .2s; }
        .btn-primary:hover .btn-arrow { transform: translateX(3px); background: rgba(255,255,255,.25); }
        .hint-text { font-size: 11.5px; color: rgba(255,255,255,.2); letter-spacing: .03em; }
        #fade-overlay { position: fixed; inset: 0; background: #060f09; opacity: 0; pointer-events: none; z-index: 9999; backdrop-filter: blur(0px); }
        .corner { position: absolute; z-index: 10; opacity: 0; }
        .corner-tl { top: 20px; left: 24px; }
        .corner-br { bottom: 20px; right: 24px; text-align: right; }
        .corner-label { font-size: 10.5px; color: rgba(255,255,255,.2); letter-spacing: .08em; text-transform: uppercase; }
        .corner-val { font-size: 11px; color: rgba(79,213,133,.5); letter-spacing: .04em; }
        #skip {
            position: absolute; bottom: 22px; left: 50%; transform: translateX(-50%);
            font-size: 11px; color: rgba(255,255,255,.18); cursor: pointer; z-index: 20;
            letter-spacing: .04em; opacity: 0; transition: color .2s; white-space: nowrap;
        }
        #skip:hover { color: rgba(255,255,255,.45); }
        .cursor-dot, .cursor-ring { position: fixed; top: 0; left: 0; pointer-events: none; transform: translate(-50%, -50%); opacity: 0; z-index: 10010; }
        .cursor-dot { width: 10px; height: 10px; border-radius: 50%; background: rgba(255,255,255,.92); box-shadow: 0 0 20px rgba(255,255,255,.2); mix-blend-mode: screen; }
        .cursor-ring { width: 48px; height: 48px; border-radius: 50%; border: 1.5px solid rgba(79,213,133,.65); transition: transform .25s ease, border-color .25s ease, background .25s ease; display: grid; place-items: center; }
        .cursor-ring::after { content: attr(data-label); position: absolute; bottom: -30px; left: 50%; transform: translateX(-50%); color: #fff; font-size: 11px; letter-spacing: .1em; opacity: 0; white-space: nowrap; pointer-events: none; transition: opacity .2s ease; }
        .cursor-ring.cursor-hover { transform: translate(-50%, -50%) scale(1.35); border-color: rgba(126,232,161,.95); background: rgba(79,213,133,.08); }
        .cursor-ring.cursor-hover::after { opacity: 1; }
        ::-webkit-scrollbar { width: 14px; height: 14px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(79, 213, 133, 0.4); border-radius: 8px; border: 3px solid transparent; background-clip: padding-box; transition: background .2s ease, box-shadow .2s ease; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(79, 213, 133, 0.85); background-clip: padding-box; box-shadow: 0 0 12px rgba(79, 213, 133, 0.5); }
        ::-webkit-scrollbar-thumb:active { background: rgba(79, 213, 133, 1); }
    </style>
</head>
<body>

<div class="cursor-dot" id="cursorDot"></div>
<div class="cursor-ring" id="cursorRing" data-label=""></div>

<nav id="mainNav">
    <a href="{{ route('intro') }}" class="nav-brand">
        <div class="nav-logo">
            <img src="https://raw.githubusercontent.com/NoahMikhailovna/foto/c45c72f9adca95001eefebd49d7581e89d0de508/padi_logo_fitted.svg"
                 style="width:100%;height:100%;object-fit:contain;" alt="Logo">
        </div>
        <span class="nav-name">SIMHP</span>
    </a>
    <button class="nav-toggle" id="navToggle" aria-label="Buka menu" aria-expanded="false">
        <span></span>
    </button>
    <div class="nav-links" id="navLinks">
        <a href="{{ route('intro') }}" class="active">Beranda</a>
        <a href="{{ route('about') }}">Tentang</a>
        <a href="{{ asset('simhp.apk') }}" class="nav-download" download>
            <span>⬇</span>
            <span>Unduh APK</span>
        </a>
        <a href="javascript:void(0)" onclick="goLogin()" class="nav-cta">Masuk →</a>
    </div>
</nav>

<div id="page">
    <div class="amb amb-1"></div>
    <div class="amb amb-2"></div>
    <div class="amb amb-3"></div>
    <div class="grid-lines"></div>
    <div id="threeSceneWrapper">
        <canvas id="threeScene"></canvas>
        <div class="scene-overlay"></div>
        <div class="scene-layer scene-layer-1"></div>
        <div class="scene-layer scene-layer-2"></div>
        <div class="scene-layer scene-layer-3"></div>
    </div>
    <canvas id="dots-canvas"></canvas>

    <div class="corner corner-tl" id="cornerTl">
        <div class="corner-label">SIMHP</div>
        <div class="corner-val">v1.2 · 2025</div>
    </div>
    <div class="corner corner-br" id="cornerBr">
        <div class="corner-label"></div>
        <div class="corner-val">UKRI</div>
    </div>

    <div class="content">

        <div class="badge" id="badge">
            <span class="badge-dot"></span>
            Sistem Monitoring Pangan
        </div>

        <div class="logo-wrap logo-container" id="logoWrap">
            <div class="logo-ring-spin-2"></div>
            <div class="logo-ring-spin"></div>
            <div class="logo-ring"></div>
            <div class="logo-ring-2"></div>
            <div class="logo-icon logo-img"><img src="{{ asset('foto/petani_logo.png') }}" alt="SIMHP" style="width:100%;height:100%;object-fit:contain;"></div>
        </div>

        <div class="title" id="title"><!-- chars injected --></div>

        <div class="divider" id="divider"></div>

        <p class="subtitle" id="subtitle">
            Sistem Informasi Monitoring Hasil Panen<br>
             Berbasis Web
        </p>

        <div class="stats" id="stats">
            <div class="stat">
                <span class="stat-num">Real‑Time</span>
                <span class="stat-label">Dashboard</span>
            </div>
            <div class="stat">
                <span class="stat-num">Auto</span>
                <span class="stat-label">Alert Stok</span>
            </div>
            <div class="stat">
                <span class="stat-num">PDF</span>
                <span class="stat-label">Laporan</span>
            </div>
        </div>

        <div class="cta-wrap" id="ctaWrap">
            <button class="btn-primary" id="btnMasuk" onclick="handleEnter()">
                Masuk ke SIMHP
                <span class="btn-arrow">
                    <svg width="10" height="10" viewBox="0 0 10 10" fill="none">
                        <path d="M2 5H8M8 5L5.5 2.5M8 5L5.5 7.5" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </span>
            </button>
            <span class="hint-text">Tekan <kbd style="background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.1);border-radius:4px;padding:1px 5px;font-size:10px;">Enter</kbd> untuk masuk</span>
        </div>
    </div>

    <div id="skip" onclick="goLogin()">Lewati →</div>
</div>

<div id="fade-overlay"></div>

<script>
'SIMHP'.split('').forEach(c => {
    const s = document.createElement('span');
    s.className = 'title-char';
    s.textContent = c;
    document.getElementById('title').appendChild(s);
});

const canvas = document.getElementById('dots-canvas');
const ctx = canvas.getContext('2d');
let orbs = [];

function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}
resizeCanvas();
window.addEventListener('resize', resizeCanvas);

function createOrbs() {
    orbs = [];
    for (let i = 0; i < 56; i++) {
        orbs.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            r: Math.random() * 3.2 + 0.6,
            opacity: Math.random() * .35 + .06,
            vx: (Math.random() - .5) * 0.45,
            vy: (Math.random() - .5) * 0.45,
            phase: Math.random() * Math.PI * 2
        });
    }
}
createOrbs();

let animFrame;
function drawOrbs(ts) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    orbs.forEach(o => {
        o.x += o.vx;
        o.y += o.vy;
        o.phase += .008;
        const pulse = Math.sin(o.phase) * .3;
        if (o.x < 0) o.x = canvas.width;
        if (o.x > canvas.width) o.x = 0;
        if (o.y < 0) o.y = canvas.height;
        if (o.y > canvas.height) o.y = 0;
        ctx.beginPath();
        ctx.arc(o.x, o.y, o.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(79,213,133,${Math.max(0, o.opacity + pulse)})`;
        ctx.fill();
    });
    animFrame = requestAnimationFrame(drawOrbs);
}
drawOrbs();

const cursorDot = document.getElementById('cursorDot');
const cursorRing = document.getElementById('cursorRing');

function initCursor() {
    document.body.addEventListener('mousemove', e => {
        if (cursorDot) gsap.to(cursorDot, { x: e.clientX, y: e.clientY, duration: 0.14, ease: 'power3.out' });
        if (cursorRing) gsap.to(cursorRing, { x: e.clientX, y: e.clientY, duration: 0.28, ease: 'power3.out' });
    });

    const interactions = document.querySelectorAll('.btn-primary, .feature-card, .module-item, #skip, .logo-wrap');
    interactions.forEach(el => {
        el.addEventListener('mouseenter', () => {
            if (!cursorRing) return;
            cursorRing.classList.add('cursor-hover');
            if (el.id === 'skip') {
                cursorRing.dataset.label = 'Lewati';
            } else if (el.classList.contains('btn-primary')) {
                cursorRing.dataset.label = 'Klik';
            } else if (el.classList.contains('logo-wrap')) {
                cursorRing.dataset.label = 'Explore';
            } else {
                cursorRing.dataset.label = 'Telusuri';
            }
        });
        el.addEventListener('mouseleave', () => {
            if (!cursorRing) return;
            cursorRing.classList.remove('cursor-hover');
            cursorRing.dataset.label = '';
        });
    });

    document.querySelectorAll('.btn-primary').forEach(btn => {
        btn.addEventListener('mousemove', e => {
            const rect = btn.getBoundingClientRect();
            const dx = (e.clientX - rect.left - rect.width / 2) / 6;
            const dy = (e.clientY - rect.top - rect.height / 2) / 6;
            gsap.to(btn, { x: dx, y: dy, duration: 0.25, ease: 'power2.out' });
        });
        btn.addEventListener('mouseleave', () => {
            gsap.to(btn, { x: 0, y: 0, duration: 0.3, ease: 'power2.out' });
        });
    });
}

const tl = gsap.timeline({ defaults: { ease: 'power3.out' }, paused: true });

function showPage() {
    gsap.timeline({ defaults: { ease: 'power3.out' } })
        .to('#page', { opacity: 1, y: 0, duration: 0.9 })
        .call(() => {
            if (cursorDot || cursorRing) gsap.to([cursorDot, cursorRing].filter(Boolean), { opacity: 1, duration: 0.4, ease: 'power1.out' });
            if (tl) tl.play();
        }, null, '-=0.2');
}

window.addEventListener('load', () => {
    initCursor();
    showPage();
});

if (document.readyState === 'complete') {
    initCursor();
    showPage();
}

try {
    gsap.registerPlugin(ScrollTrigger);

    const threeCanvas = document.getElementById('threeScene');
    const renderer = new THREE.WebGLRenderer({ canvas: threeCanvas, alpha: true, antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setClearColor(0x060f09, 0);

    const scene = new THREE.Scene();
    scene.fog = new THREE.FogExp2(0x060f09, 0.02);

    const camera = new THREE.PerspectiveCamera(38, window.innerWidth / window.innerHeight, 0.1, 200);
    camera.position.set(0, 4, 38);
    camera.lookAt(0, 0, 0);

    const ambientLight = new THREE.AmbientLight(0x95ffb7, 0.78);
    const directionalLight = new THREE.DirectionalLight(0xdbfdf0, 1.2);
    directionalLight.position.set(12, 15, 8);
    const pointGlow = new THREE.PointLight(0x7effab, 0.6, 90, 2);
    pointGlow.position.set(-2, 3, 18);
    scene.add(ambientLight, directionalLight, pointGlow);

    const createLayer = (color, width, height, x, y, z, rotationZ, opacity) => {
        const geometry = new THREE.PlaneGeometry(width, height);
        const material = new THREE.MeshPhongMaterial({
            color, emissive: 0x0b3219, emissiveIntensity: 0.16, transparent: true, opacity,
            side: THREE.DoubleSide, shininess: 42, specular: 0x99ffb8
        });
        const mesh = new THREE.Mesh(geometry, material);
        mesh.position.set(x, y, z);
        mesh.rotation.set(-0.14, 0, rotationZ);
        scene.add(mesh);
        return mesh;
    };

    const planeA = createLayer(0x173422, 22, 12, -4, 0.8, -6, -0.12, 0.28);
    const planeB = createLayer(0x225230, 18, 10, 3.5, 1.8, -3, 0.14, 0.2);
    const planeC = createLayer(0x2f6b46, 14, 8, 0, -1.6, -1, -0.08, 0.14);

    const grainGroup = new THREE.Group();
    for (let i = 0; i < 40; i++) {
        const grain = new THREE.Mesh(
            new THREE.SphereGeometry(0.16, 8, 8),
            new THREE.MeshStandardMaterial({ color: 0xd9e9b0, roughness: 0.45, metalness: 0.05 })
        );
        grain.position.set(
            (Math.random() - 0.5) * 20,
            (Math.random() - 0.5) * 7,
            -Math.random() * 18
        );
        grain.rotation.set(Math.random() * 0.8, Math.random() * 0.8, Math.random() * 0.8);
        grainGroup.add(grain);
    }
    scene.add(grainGroup);

    const resizeThree = () => {
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        renderer.setSize(window.innerWidth, window.innerHeight);
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
    };
    window.addEventListener('resize', () => {
        resizeCanvas();
        resizeThree();
    });

    const animateThree = () => {
        grainGroup.rotation.y += 0.0008;
        grainGroup.children.forEach((grain, index) => {
            grain.position.x += Math.sin(index + performance.now() / 9000) * 0.0005;
        });
        renderer.render(scene, camera);
        requestAnimationFrame(animateThree);
    };
    animateThree();

    gsap.fromTo('#threeSceneWrapper',
        { autoAlpha: 0, y: 30 },
        { autoAlpha: 1, y: 0, duration: 1.4, ease: 'power3.out', delay: 0.2 }
    );

    gsap.to([document.querySelector('.scene-layer-1'), document.querySelector('.scene-layer-2'), document.querySelector('.scene-layer-3')], {
        y: '+=12', x: '-=8', duration: 6, yoyo: true, repeat: -1, ease: 'sine.inOut'
    });

    const scrollScene = gsap.timeline({
        scrollTrigger: { trigger: '#page', start: 'top top', end: '+=1200', scrub: 1, invalidateOnRefresh: true }
    });

    scrollScene
        .to(camera.position, { z: 14, y: 5.4, x: -0.8, duration: 1, ease: 'power2.inOut' }, 0)
        .to(camera.rotation, { y: 0.24, x: -0.08, duration: 1, ease: 'power2.inOut' }, 0)
        .to(planeA.position, { x: -10.5, y: 2.4, z: -7.5, duration: 1, ease: 'power2.inOut' }, 0)
        .to(planeB.position, { x: 7.8, y: 3.8, z: -8.2, duration: 1, ease: 'power2.inOut' }, 0)
        .to(planeC.position, { x: 3.8, y: -0.2, z: -4.2, duration: 1, ease: 'power2.inOut' }, 0)
        .to(planeA.rotation, { z: -0.32, duration: 1, ease: 'power2.inOut' }, 0)
        .to(planeB.rotation, { z: 0.24, duration: 1, ease: 'power2.inOut' }, 0)
        .to(planeC.rotation, { z: -0.15, duration: 1, ease: 'power2.inOut' }, 0)
        .to(planeA.material, { opacity: 0.14, duration: 1, ease: 'power2.inOut' }, 0)
        .to(planeB.material, { opacity: 0.1, duration: 1, ease: 'power2.inOut' }, 0)
        .to(planeC.material, { opacity: 0.06, duration: 1, ease: 'power2.inOut' }, 0)
        .to(scene.fog, { density: 0.062, duration: 1, ease: 'power2.inOut' }, 0)
        .to(grainGroup.rotation, { y: '+=0.38', duration: 1, ease: 'power2.inOut' }, 0);
} catch (error) {
    console.warn('3D scene initialization failed, continuing without Three.js:', error);
}

tl.to('nav',        { opacity: 1, y: 0, duration: 0.8 }, 0.1)
  .to('#badge',    { opacity: 1, y: 0, duration: .7 }, .2)
  .to('#logoWrap', { opacity: 1, scale: 1, y: 0, rotationY: 0, duration: 1.2, ease: 'back.out(1.7)' }, .35)
  .to('#logoWrap', { y: -10, duration: 3, ease: 'power1.inOut', repeat: -1, yoyo: true }, 1.8)
  .to('.title-char', {
        opacity: 1, y: 0, rotate: 0,
        duration: .6, stagger: .055, ease: 'back.out(1.4)'
    }, .55)
  .to('#divider',  { height: 48, duration: .6, ease: 'power2.out' }, .75)
  .to('#subtitle', { opacity: 1, y: 0, duration: .6 }, .85)
  .to('#stats',    { opacity: 1, y: 0, duration: .6 }, .95)
  .to('#ctaWrap',  { opacity: 1, y: 0, duration: .65, ease: 'back.out(1.3)' }, 1.05)
  .to(['#cornerTl','#cornerBr','#skip'], { opacity: 1, duration: .5, stagger: .1 }, 1.2);

const loginUrl = "{{ route('login') }}";
let going = false;

function goLogin() {
    if (going) return;
    going = true;

    cancelAnimationFrame(animFrame);

    const overlay = document.getElementById('fade-overlay');

    overlay.style.pointerEvents = 'all';

    gsap.to('.content, .corner, #skip, nav', {
        filter: 'blur(12px)', opacity: 0, duration: 0.55, ease: 'power2.inOut'
    });
    gsap.to('.amb, .grid-lines', { opacity: 0, duration: .5, ease: 'power2.in' });
    gsap.to(overlay, {
        opacity: 1, duration: .65, ease: 'power2.inOut', delay: .15,
        onComplete: () => { window.location.href = loginUrl; }
    });
}

function handleEnter() { goLogin(); }

const logoElem = document.getElementById('logoWrap');
logoElem.addEventListener('mousemove', (e) => {
    const rect = logoElem.getBoundingClientRect();
    const x = e.clientX - rect.left - rect.width / 2;
    const y = e.clientY - rect.top - rect.height / 2;
    gsap.to(logoElem, {
        rotationX: -y / 10, rotationY: x / 10, transformPerspective: 500, duration: 0.3, ease: 'power2.out'
    });
});
logoElem.addEventListener('mouseleave', () => {
    gsap.to(logoElem, { rotationX: 0, rotationY: 0, duration: 0.5, ease: 'elastic.out(1, 0.5)' });
});

document.addEventListener('keydown', e => {
    if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); goLogin(); }
});

const aboutUrl = "{{ route('about') }}";
let redirected = false;

function triggerForward() {
    if (redirected) return;
    redirected = true;

    const overlay = document.getElementById('fade-overlay');
    overlay.style.pointerEvents = 'all';

    gsap.to('.content, .corner, #skip, nav', {
        filter: 'blur(12px)', opacity: 0, duration: 0.55, ease: 'power2.inOut'
    });

    gsap.to(overlay, {
        opacity: 1, duration: 0.65, ease: 'power2.inOut',
        onComplete: () => { window.location.href = aboutUrl; }
    });
}

window.addEventListener('wheel', (e) => {
    if (!redirected && e.deltaY > 30) { triggerForward(); }
}, { passive: true });

let touchStart = 0;
window.addEventListener('touchstart', (e) => {
    touchStart = e.touches[0].screenY;
}, { passive: true });
window.addEventListener('touchmove', (e) => {
    let touchEnd = e.touches[0].screenY;
    if (!redirected && touchEnd < touchStart - 40) { triggerForward(); }
}, { passive: true });

window.addEventListener('scroll', () => {
    const nav = document.getElementById('mainNav');
    if (window.scrollY > 50) { nav.classList.add('scrolled'); } else { nav.classList.remove('scrolled'); }
});

const navToggle = document.getElementById('navToggle');
const nav = document.querySelector('nav');
const navLinks = document.getElementById('navLinks');

if (navToggle) {
    navToggle.addEventListener('click', () => {
        if (!nav) return;
        nav.classList.toggle('open');
        const expanded = nav.classList.contains('open');
        navToggle.setAttribute('aria-expanded', String(expanded));
    });
}

if (navLinks) {
    navLinks.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            if (!nav) return;
            nav.classList.remove('open');
            if (navToggle) navToggle.setAttribute('aria-expanded', 'false');
        });
    });
}
</script>
</body>
</html>
