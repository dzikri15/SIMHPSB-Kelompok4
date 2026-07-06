<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tentang SIMHP</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800;900&family=Lora:ital,wght@1,400;1,600&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/ScrollTrigger.min.js"></script>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }
        html, body {
            width: 100%; min-height: 100%;
            overflow-x: hidden;
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: #060f09;
            color: #e4f8e1;
        }

        /* ── AMBIENT ── */
        .amb { position: fixed; border-radius: 50%; filter: blur(120px); pointer-events: none; z-index: 0; }
        .amb-1 { width: 700px; height: 700px; background: radial-gradient(circle, rgba(34,100,60,.3) 0%, transparent 65%); top: -200px; left: -150px; }
        .amb-2 { width: 500px; height: 500px; background: radial-gradient(circle, rgba(56,161,105,.18) 0%, transparent 65%); bottom: 10%; right: -100px; }

        /* ── GRID ── */
        .grid-lines {
            position: fixed; inset: 0; z-index: 0;
            background-image:
                linear-gradient(rgba(255,255,255,.02) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,.02) 1px, transparent 1px);
            background-size: 72px 72px;
            pointer-events: none;
            mask-image: radial-gradient(ellipse 80% 70% at 50% 50%, black 20%, transparent 80%);
        }

        /* ── NAV ── */
        nav {
            position: fixed; top: 0; left: 0; right: 0; z-index: 1000;
            display: flex; align-items: center; justify-content: space-between;
            padding: 18px 40px;
            background: rgba(6,15,9,.85);
            backdrop-filter: blur(16px);
            border-bottom: 1px solid rgba(79,213,133,.1);
            transition: padding 0.4s;
        }
        nav.scrolled {
            padding: 14px 40px;
        }
        .nav-brand {
            display: flex; align-items: center; gap: 12px;
            text-decoration: none;
        }
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
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #d6f6d3;
            text-decoration: none;
            font-weight: 700;
            font-size: 13px;
            padding: 8px 14px;
            border: 1px solid rgba(79,213,133,.25);
            border-radius: 10px;
            transition: background .2s, border-color .2s;
        }
        .nav-download:hover {
            background: rgba(79,213,133,.08);
            border-color: rgba(79,213,133,.45);
        }

        .nav-toggle {
            display: none;
            border: none;
            background: transparent;
            color: #fff;
            cursor: pointer;
            width: 38px;
            height: 38px;
            border-radius: 12px;
            align-items: center;
            justify-content: center;
            transition: background .2s;
        }
        .nav-toggle:hover {
            background: rgba(79,213,133,.08);
        }
        .nav-toggle span {
            display: block;
            width: 20px;
            height: 2px;
            background: #fff;
            border-radius: 999px;
            position: relative;
        }
        .nav-toggle span::before,
        .nav-toggle span::after {
            content: '';
            position: absolute;
            left: 0;
            width: 20px;
            height: 2px;
            background: #fff;
            border-radius: 999px;
            transition: transform .2s ease;
        }
        .nav-toggle span::before { top: -6px; }
        .nav-toggle span::after { top: 6px; }

        @media (max-width: 860px) {
            nav {
                padding: 14px 24px;
                gap: 12px;
                flex-wrap: wrap;
                justify-content: space-between;
            }
            .nav-logo {
                width: 32px;
                height: 32px;
            }
            .nav-name { font-size: 14px; }
            .nav-toggle {
                display: inline-flex;
            }
            .nav-links {
                display: none;
                width: 100%;
                flex-direction: column;
                gap: 12px;
                margin-top: 14px;
            }
            nav.open .nav-links {
                display: flex;
            }
            .nav-links a {
                padding: 12px 16px;
                background: rgba(15,33,24,.92);
                border-radius: 12px;
            }
            .nav-cta {
                padding: 10px 16px;
                font-size: 12px !important;
                width: 100%;
            }
        }

        @media (max-width: 560px) {
            nav {
                padding: 14px 18px;
            }
            .nav-links {
                justify-content: stretch;
                gap: 10px;
                padding: 10px 0 0;
            }
            .nav-links a,
            .nav-cta {
                text-align: center;
            }
        }

        @media (max-width: 860px) {
            nav {
                padding: 14px 24px;
                gap: 12px;
                flex-wrap: wrap;
                justify-content: space-between;
            }
            .nav-logo {
                width: 32px;
                height: 32px;
            }
            .nav-name { font-size: 14px; }
            .nav-links {
                flex: 1 1 100%;
                justify-content: flex-end;
                gap: 16px;
                flex-wrap: wrap;
            }
            .nav-links a {
                font-size: 12px;
            }
            .nav-cta {
                padding: 8px 16px;
                font-size: 12px !important;
            }
        }

        @media (max-width: 560px) {
            nav {
                flex-direction: column;
                align-items: flex-start;
                padding: 14px 18px;
            }
            .nav-links {
                width: 100%;
                justify-content: space-between;
                gap: 10px;
            }
            .nav-links a,
            .nav-cta {
                flex: 1 1 100%;
                text-align: center;
            }
            .nav-links {
                padding: 10px 0 0;
            }
            .nav-cta {
                width: 100%;
            }
        }

        /* ── EXIT OVERLAY ── */
        #fade-overlay {
            position: fixed; inset: 0; background: #060f09; opacity: 0;
            pointer-events: none; z-index: 9999;
        }

        /* ── CONTENT WRAPPER ── */
        .wrapper {
            position: relative; z-index: 10;
            max-width: 1100px;
            margin: 0 auto;
            padding: 120px 24px 80px;
        }

        /* ── HERO SECTION ── */
        .hero {
            text-align: center;
            padding: 60px 0 80px;
            opacity: 0; transform: translateY(30px);
        }
        .hero-badge {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 6px 14px 6px 8px;
            background: rgba(79,213,133,.1);
            border: 1px solid rgba(79,213,133,.25);
            border-radius: 100px;
            font-size: 11.5px; font-weight: 600; color: #4fd585;
            letter-spacing: .04em; text-transform: uppercase;
            margin-bottom: 28px;
        }
        .badge-dot {
            width: 6px; height: 6px; border-radius: 50%;
            background: #4fd585; box-shadow: 0 0 8px #4fd585;
            animation: pulse-dot 2s ease-in-out infinite;
        }
        @keyframes pulse-dot {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: .5; transform: scale(.7); }
        }
        .hero h1 {
            font-size: clamp(40px, 6vw, 72px);
            font-weight: 900; color: #fff;
            letter-spacing: -3px; line-height: .95;
            margin-bottom: 20px;
        }
        .hero h1 span { color: #4fd585; }
        .hero p {
            font-family: 'Lora', serif;
            font-style: italic;
            font-size: clamp(14px, 1.8vw, 16px);
            color: rgba(255,255,255,.55);
            line-height: 1.8; max-width: 520px; margin: 0 auto 40px;
        }

        /* ── SECTION ── */
        .section { margin-bottom: 80px; opacity: 0; transform: translateY(24px); }
        .section-label {
            display: inline-flex; align-items: center; gap: 8px;
            font-size: 11px; font-weight: 700; color: #4fd585;
            letter-spacing: .12em; text-transform: uppercase;
            margin-bottom: 14px;
        }
        .section-label::before {
            content: ''; width: 20px; height: 2px;
            background: #4fd585; border-radius: 2px;
        }
        .section h2 {
            font-size: clamp(28px, 3.5vw, 40px);
            font-weight: 800; color: #fff;
            letter-spacing: -1.5px; margin-bottom: 16px; line-height: 1.1;
        }
        .section > p {
            color: rgba(255,255,255,.6); line-height: 1.85; font-size: 15px;
            max-width: 680px; margin-bottom: 40px;
        }

        /* ── INFO CARDS ── */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 20px;
        }
        .info-card {
            background: rgba(15,33,24,.9);
            border: 1px solid rgba(79,213,133,.13);
            border-radius: 20px; padding: 28px;
            backdrop-filter: blur(14px);
            transition: transform .25s, border-color .25s;
        }
        .info-card:hover { transform: translateY(-4px); border-color: rgba(79,213,133,.28); }
        .info-card-icon {
            width: 44px; height: 44px;
            background: rgba(79,213,133,.12);
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px; margin-bottom: 16px;
        }
        .info-card h4 { font-size: 16px; color: #fff; font-weight: 700; margin-bottom: 8px; }
        .info-card p { font-size: 13.5px; color: rgba(255,255,255,.6); line-height: 1.75; }
        .info-card .highlight {
            font-size: 24px; font-weight: 900; color: #4fd585;
            margin-bottom: 4px; letter-spacing: -1px;
        }

        /* ── TIMELINE ── */
        .timeline { position: relative; padding-left: 28px; }
        .timeline::before {
            content: ''; position: absolute;
            left: 0; top: 6px; bottom: 6px; width: 2px;
            background: linear-gradient(180deg, #4fd585, rgba(79,213,133,.1));
            border-radius: 2px;
        }
        .timeline-item { position: relative; margin-bottom: 36px; }
        .timeline-item::before {
            content: ''; position: absolute;
            left: -34px; top: 6px;
            width: 12px; height: 12px; border-radius: 50%;
            background: #4fd585; box-shadow: 0 0 12px rgba(79,213,133,.5);
            border: 2px solid #060f09;
        }
        .timeline-date {
            font-size: 11px; font-weight: 700; color: #4fd585;
            letter-spacing: .08em; text-transform: uppercase; margin-bottom: 6px;
        }
        .timeline-item h4 { font-size: 16px; color: #fff; font-weight: 700; margin-bottom: 6px; }
        .timeline-item p { font-size: 13.5px; color: rgba(255,255,255,.6); line-height: 1.7; }

        /* ── TEAM ── */
        .team-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .team-card {
            background: rgba(15,33,24,.9);
            border: 1px solid rgba(79,213,133,.13);
            border-radius: 20px; padding: 28px 20px;
            text-align: center;
            backdrop-filter: blur(14px);
            transition: transform .25s, border-color .25s;
        }
        .team-card:hover { transform: translateY(-4px); border-color: rgba(79,213,133,.28); }
        .team-avatar {
            width: 64px; height: 64px;
            border-radius: 50%;
            background: linear-gradient(145deg, #3ecf74, #22a157);
            display: flex; align-items: center; justify-content: center;
            font-size: 26px; font-weight: 800; color: #fff;
            margin: 0 auto 14px;
            box-shadow: 0 0 0 3px rgba(79,213,133,.2), 0 8px 24px rgba(34,161,85,.3);
        }
        .team-name { font-size: 15px; font-weight: 700; color: #fff; margin-bottom: 4px; }
        .team-role {
            font-size: 12px; color: #4fd585;
            font-weight: 600; letter-spacing: .04em;
            text-transform: uppercase; margin-bottom: 10px;
        }
        .team-npm { font-size: 11px; color: rgba(255,255,255,.35); margin-bottom: 12px; }
        .team-tags { display: flex; flex-wrap: wrap; gap: 6px; justify-content: center; }
        .tag {
            padding: 3px 9px;
            background: rgba(79,213,133,.1);
            border: 1px solid rgba(79,213,133,.2);
            border-radius: 100px;
            font-size: 10px; color: #4fd585; font-weight: 600;
        }
        .team-card.leader { border-color: rgba(79,213,133,.35); }
        .team-card.leader .team-avatar { background: linear-gradient(145deg, #4fd585, #2b7a4f); }

        /* ── STACK ── */
        .stack-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 14px;
        }
        .stack-item {
            background: rgba(15,33,24,.9);
            border: 1px solid rgba(79,213,133,.12);
            border-radius: 14px; padding: 18px 16px;
            text-align: center;
            transition: transform .2s, border-color .2s;
        }
        .stack-item:hover { transform: translateY(-3px); border-color: rgba(79,213,133,.28); }
        .stack-icon {
            font-size: 28px; margin-bottom: 8px;
            display: flex; align-items: center; justify-content: center;
            height: 32px;
        }
        .stack-icon img {
            display: block;
            object-fit: contain;
        }
        .stack-name { font-size: 13px; font-weight: 700; color: #fff; margin-bottom: 4px; }
        .stack-desc { font-size: 11px; color: rgba(255,255,255,.4); }

        /* ── DIVIDER ── */
        .divider-line {
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(79,213,133,.3), transparent);
            margin: 60px 0;
        }

        /* ── BACK BTN ── */
        .back-btn {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 22px;
            background: rgba(79,213,133,.1);
            border: 1px solid rgba(79,213,133,.25);
            border-radius: 12px;
            color: #4fd585; font-size: 13px; font-weight: 700;
            text-decoration: none; letter-spacing: .02em;
            transition: background .2s, transform .2s;
            margin-bottom: 8px;
        }
        .back-btn:hover { background: rgba(79,213,133,.18); transform: translateX(-3px); }

        /* ── SCROLLBAR ── */
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb {
            background: rgba(79,213,133,.35); border-radius: 8px;
            border: 2px solid transparent; background-clip: padding-box;
        }
        ::-webkit-scrollbar-thumb:hover { background: rgba(79,213,133,.7); }
    </style>
</head>
<body>

<div id="fade-overlay"></div>
<div class="amb amb-1"></div>
<div class="amb amb-2"></div>
<div class="grid-lines"></div>

<!-- NAV -->
<nav>
    <a href="{{ route('intro') }}" class="nav-brand">
        <div class="nav-logo">
            <img src="https://raw.githubusercontent.com/NoahMikhailovna/foto/c45c72f9adca95001eefebd49d7581e89d0de508/padi_logo_fitted.svg"
                 style="width:100%;height:100%;object-fit:contain;" alt="Logo">
        </div>
        <span class="nav-name">SIMHP</span>
    </a>
    <button class="nav-toggle" id="navToggle" aria-label="Buka menu">
        <span></span>
    </button>
    <div class="nav-links" id="navLinks">
        <a href="{{ route('intro') }}">Beranda</a>
        <a href="{{ route('about') }}" class="active">Tentang</a>
        <a href="{{ asset('simhp.apk') }}" class="nav-download" download>
            <span>⬇</span>
            <span>Unduh APK</span>
        </a>
        <a href="{{ route('login') }}" class="nav-cta">Masuk →</a>
    </div>
</nav>

<div class="wrapper">

    <!-- HERO -->
    <div class="hero" id="hero">
        <div class="hero-badge">
            <span class="badge-dot"></span>
            Kelompok 4 · UKRI 2026
        </div>
        <h1>Tentang <span>SIMHP</span></h1>
        <p>Sistem Informasi Monitoring Hasil Panen — dibangun oleh mahasiswa Sistem Informasi UKRI sebagai proyek UAS Semester 4.</p>
    </div>

    <!-- OVERVIEW -->
    <div class="info-grid">
    <div class="info-card">
        <div class="info-card-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#4fd585" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 2c0 4-3 5-3 9a3 3 0 0 0 6 0c0-4-3-5-3-9Z"/>
                <path d="M12 11v11"/>
                <path d="M8 14c-2 1-3 3-3 5"/>
                <path d="M16 14c2 1 3 3 3 5"/>
            </svg>
        </div>
        <h4>Tujuan Dibangun</h4>
        <p>Mengatasi tantangan pencatatan manual hasil panen dan stok beras yang rawan error, tidak real-time, dan sulit dipantau secara terpusat.</p>
    </div>
    <div class="info-card">
        <div class="info-card-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#4fd585" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <circle cx="12" cy="12" r="6"/>
                <circle cx="12" cy="12" r="2"/>
            </svg>
        </div>
        <h4>Target Pengguna</h4>
        <p>Admin gudang, petugas lapangan, dan manajemen yang membutuhkan visibilitas data pangan secara cepat dan akurat.</p>
    </div>
    <div class="info-card">
        <div class="info-card-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#4fd585" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
                <circle cx="12" cy="10" r="3"/>
            </svg>
        </div>
        <h4>Studi Kasus</h4>
        <p>Berdasarkan studi lapangan di wilayah Majalengka — dengan kapasitas gudang 2 ton gabah / 1 ton beras dan target distribusi 9.000 kg beras/bulan.</p>
    </div>
    <div class="info-card">
        <div class="info-card-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#4fd585" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="8" width="18" height="12" rx="2"/>
                <circle cx="8.5" cy="14" r="1.5" fill="#4fd585"/>
                <circle cx="15.5" cy="14" r="1.5" fill="#4fd585"/>
                <path d="M12 8V4"/>
                <circle cx="12" cy="3" r="1" fill="#4fd585"/>
                <path d="M7 8V6a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v2"/>
            </svg>
        </div>
        <h4>AI Terintegrasi</h4>
        <p>Dilengkapi chatbot HPSBBot berbasis Google Gemini + n8n yang bisa menjawab pertanyaan stok dan harga secara real-time dari database.</p>
    </div>
</div>

    <div class="divider-line"></div>

    <!-- TIMELINE -->
    <div class="section" id="s2">
        <div class="section-label">Perjalanan</div>
        <h2>Dibangun kapan?</h2>
        <p>SIMHP dikembangkan dalam satu semester penuh dengan tahapan agile — dari riset lapangan hingga deployment ke server produksi.</p>

        <div class="timeline">
            <div class="timeline-item">
                <div class="timeline-date">Februari 2026</div>
                <h4>Riset & Perencanaan</h4>
                <p>Studi lapangan di Majalengka, analisis kebutuhan sistem, pembentukan tim Kelompok 4, dan penyusunan SRS (Software Requirements Specification) IEEE format v2.1.</p>
            </div>
            <div class="timeline-item">
                <div class="timeline-date">Maret 2026</div>
                <h4>Desain Sistem & Database</h4>
                <p>Perancangan ERD 9 tabel, Context Diagram, DFD Level 1, dan desain UI/UX untuk web admin dan aplikasi mobile Flutter.</p>
            </div>
            <div class="timeline-item">
                <div class="timeline-date">April – Mei 2026</div>
                <h4>Development Sprint</h4>
                <p>Implementasi Laravel 12 backend, Flutter mobile app, integrasi JWT authentication, fitur stok gudang, pencatatan panen, alert, dan manajemen harga.</p>
            </div>
            <div class="timeline-item">
                <div class="timeline-date">Juni 2026</div>
                <h4>Integrasi AI & DevOps</h4>
                <p>Penambahan chatbot HPSBBot (n8n + Gemini 2.5 Flash), Docker deployment, dan finalisasi fitur foto bukti distribusi serta tujuan distribusi.</p>
            </div>
            <div class="timeline-item">
                <div class="timeline-date">Juni 2026 — Sekarang</div>
                <h4>Production & Hosting</h4>
                <p>Deployment ke VPS dengan Docker Compose — Laravel + MySQL + Redis + n8n + nginx dalam satu stack terintegrasi.</p>
            </div>
        </div>
    </div>

    <div class="divider-line"></div>

    <!-- TEAM -->
    <div class="section" id="s3">
        <div class="section-label">Tim</div>
        <h2>Siapa yang membangun?</h2>
        <p>Kelompok 4 mahasiswa Program Studi Sistem Informasi, Universitas Kebangsaan Republik Indonesia (UKRI) — Semester 4, Kelas A1.</p>

        <div class="team-grid">
            <div class="team-card leader">
                <div class="team-avatar">D</div>
                <div class="team-name">Muhammad Dzikri Sagara</div>
                <div class="team-role">PM · Backend · DevOps · Database</div>
                <div class="team-npm">NPM: 20241320004</div>
                <div class="team-tags">
                    <span class="tag">Laravel</span>
                    <span class="tag">REST API</span>
                    <span class="tag">JWT</span>
                    <span class="tag">Docker Setup</span>
                    <span class="tag">Redis</span>
                    <span class="tag">Migration</span>
                </div>
            </div>
            <div class="team-card">
                <div class="team-avatar">F</div>
                <div class="team-name">Fakhry Ahmad Fauzan</div>
                <div class="team-role">Frontend Web · Flutter Mobile · API Integration</div>
                <div class="team-npm">NPM: 20241320038</div>
                <div class="team-tags">
                    <span class="tag">Blade</span>
                    <span class="tag">Flutter</span>
                    <span class="tag">UI/UX</span>
                    <span class="tag">API Integration</span>
                    <span class="tag">JWT</span>
                    <span class="tag">Setup</span>
                </div>
            </div>
            <div class="team-card">
                <div class="team-avatar">A</div>
                <div class="team-name">Muhammad Alamsyah</div>
                <div class="team-role">n8n · DevOps · QA Web · Diagram</div>
                <div class="team-npm">NPM: 20241320030</div>
                <div class="team-tags">
                    <span class="tag">n8n</span>
                    <span class="tag">Gemini AI</span>
                    <span class="tag">DevOps</span>
                    <span class="tag">POSTMAN</span>
                    <span class="tag">Diagram</span>
                    <span class="tag">Final Report</span>
                </div>
            </div>
            <div class="team-card">
                <div class="team-avatar">D</div>
                <div class="team-name">Difa Nisa Lutfiah</div>
                <div class="team-role">QA Web · Diagram · Dokumentasi</div>
                <div class="team-npm">NPM: 20241320013</div>
                <div class="team-tags">
                    <span class="tag">POSTMAN</span>
                    <span class="tag">Diagram</span>
                    <span class="tag">Manual Book</span>
                    <span class="tag">Final Report</span>
                </div>
            </div>
            <div class="team-card">
                <div class="team-avatar">D</div>
                <div class="team-name">Devina Ayuliani</div>
                <div class="team-role">QA Mobile · ERD · Laporan</div>
                <div class="team-npm">NPM: 20241320019</div>
                <div class="team-tags">
                    <span class="tag">Testing</span>
                    <span class="tag">ERD</span>
                    <span class="tag">Final Report</span>
                </div>
            </div>
            <div class="team-card">
                <div class="team-avatar">A</div>
                <div class="team-name">Agusta Firman Firdaus</div>
                <div class="team-role">QA Mobile · Testing</div>
                <div class="team-npm">NPM: 20241320016</div>
                <div class="team-tags">
                    <span class="tag">Testing</span>
                    <span class="tag">Manual Book</span>
                </div>
            </div>
            <div class="team-card">
                <div class="team-avatar">P</div>
                <div class="team-name">Paiton Wenda</div>
                <div class="team-role">Anggota Tim</div>
                <div class="team-npm">NPM: 20241320043</div>
                <div class="team-tags">
                    <span class="tag">Support</span>
                </div>
            </div>
        </div>
    </div>

    <div class="divider-line"></div>

    <!-- TECH STACK -->
    <div class="section" id="s4">
        <div class="section-label">Teknologi</div>
        <h2>Dibangun dengan apa?</h2>
        <p>Stack modern yang dipilih untuk kehandalan, skalabilitas, dan kemudahan pengembangan di lingkungan akademis maupun produksi.</p>

        <div class="stack-grid">
            <div class="stack-item">
                <div class="stack-icon">
                    <img src="https://cdn.simpleicons.org/laravel/FF2D20" alt="Laravel" width="32" height="32">
                </div>
                <div class="stack-name">Laravel 12</div>
                <div class="stack-desc">Backend & API</div>
            </div>
            <div class="stack-item">
                <div class="stack-icon">
                    <img src="https://cdn.simpleicons.org/flutter/02569B" alt="Flutter" width="32" height="32">
                </div>
                <div class="stack-name">Flutter</div>
                <div class="stack-desc">Mobile App</div>
            </div>
            <div class="stack-item">
                <div class="stack-icon">
                    <img src="https://cdn.simpleicons.org/mysql/4479A1" alt="MySQL" width="32" height="32">
                </div>
                <div class="stack-name">MySQL 8</div>
                <div class="stack-desc">Database</div>
            </div>
            <div class="stack-item">
                <div class="stack-icon">
                    <img src="https://cdn.simpleicons.org/redis/FF4438" alt="Redis" width="32" height="32">
                </div>
                <div class="stack-name">Redis</div>
                <div class="stack-desc">Cache & Queue</div>
            </div>
            <div class="stack-item">
                <div class="stack-icon">
                    <img src="https://cdn.simpleicons.org/docker/2496ED" alt="Docker" width="32" height="32">
                </div>
                <div class="stack-name">Docker</div>
                <div class="stack-desc">Containerization</div>
            </div>
            <div class="stack-item">
                <div class="stack-icon">
                    <img src="https://cdn.simpleicons.org/nginx/009639" alt="Nginx" width="32" height="32">
                </div>
                <div class="stack-name">Nginx</div>
                <div class="stack-desc">Web Server</div>
            </div>
            <div class="stack-item">
                <div class="stack-icon">
                    <img src="https://cdn.simpleicons.org/n8n/EA4B71" alt="n8n" width="32" height="32">
                </div>
                <div class="stack-name">n8n</div>
                <div class="stack-desc">AI Workflow</div>
            </div>
            <div class="stack-item">
                <div class="stack-icon">
                    <img src="https://cdn.simpleicons.org/googlegemini/8E75B2" alt="Gemini" width="32" height="32">
                </div>
                <div class="stack-name">Gemini 2.5</div>
                <div class="stack-desc">AI Model</div>
            </div>
        </div>
    </div>

    <div class="divider-line"></div>

    <!-- STATS -->
    <div class="section" id="s5">
        <div class="section-label">Fakta</div>
        <h2>SIMHP dalam angka</h2>
        <div class="info-grid">
            <div class="info-card" style="text-align:center;">
                <div class="highlight">9+</div>
                <h4>Tabel Database</h4>
                <p>ERD dengan 9 entitas utama termasuk petani, lahan, panen, stok, harga, dan distribusi.</p>
            </div>
            <div class="info-card" style="text-align:center;">
                <div class="highlight">9.000 kg</div>
                <h4>Target Distribusi</h4>
                <p>Target distribusi beras per bulan berdasarkan studi kasus lapangan di Majalengka.</p>
            </div>
            <div class="info-card" style="text-align:center;">
                <div class="highlight">5 Role</div>
                <h4>Multi Akses</h4>
                <p>Admin, Petugas Gudang, dan Petani dengan hak akses berbeda di web dan mobile.</p>
            </div>
        </div>
    </div>

    <!-- BACK TO INTRO -->
    <div style="text-align:center; padding: 20px 0 60px;">
        <a href="{{ route('intro') }}?skip_loader=1" class="back-btn">
            ← Kembali ke Beranda
        </a>
        <div style="margin-top:16px;">
            <a href="{{ route('login') }}"
               style="display:inline-flex;align-items:center;gap:10px;padding:14px 32px;background:linear-gradient(135deg,#38a169,#2b7a4f);color:#fff;border-radius:14px;font-weight:700;text-decoration:none;font-size:14px;box-shadow:0 4px 20px rgba(56,161,105,.35);">
                Masuk ke SIMHP →
            </a>
        </div>
    </div>

</div>

<script>
gsap.registerPlugin(ScrollTrigger);

// Hero
gsap.to('#hero', { opacity: 1, y: 0, duration: 1, delay: .3, ease: 'power3.out' });

// Sections
document.querySelectorAll('.section').forEach((el, i) => {
    gsap.to(el, {
        opacity: 1, y: 0, duration: .8,
        ease: 'power3.out',
        scrollTrigger: {
            trigger: el,
            start: 'top 85%',
            once: true
        },
        delay: i * .05
    });
});

// Cards hover glow
document.querySelectorAll('.info-card, .team-card, .stack-item').forEach(card => {
    card.addEventListener('mouseenter', () => {
        gsap.to(card, { scale: 1.02, duration: .2, ease: 'power2.out' });
    });
    card.addEventListener('mouseleave', () => {
        gsap.to(card, { scale: 1, duration: .3, ease: 'power2.out' });
    });
});

// Nav scroll effect & Auto redirect at top
const introUrl = "{{ route('intro') }}?skip_loader=1";
let redirected = false;

window.addEventListener('scroll', () => {
    const nav = document.querySelector('nav');

    // Nav shrink effect
    if (window.scrollY > 50) {
        nav.classList.add('scrolled');
    } else {
        nav.classList.remove('scrolled');
    }

    // Auto redirect to intro when scrolling up at the very top
    if (!redirected && window.scrollY <= 0) {
        // Detect additional upward scroll attempt
        window.addEventListener('wheel', (e) => {
            if (!redirected && e.deltaY < -30 && window.scrollY <= 0) {
                triggerBack();
            }
        }, { passive: true });

        // For touch devices
        let touchStart = 0;
        window.addEventListener('touchstart', (e) => {
            touchStart = e.touches[0].screenY;
        }, { passive: true });
        window.addEventListener('touchmove', (e) => {
            let touchEnd = e.touches[0].screenY;
            if (!redirected && touchEnd > touchStart + 40 && window.scrollY <= 0) {
                triggerBack();
            }
        }, { passive: true });
    }
});

function triggerBack() {
    if (redirected) return;
    redirected = true;

    const overlay = document.getElementById('fade-overlay');
    overlay.style.pointerEvents = 'all';

    gsap.to('.wrapper, nav', {
        filter: 'blur(12px)',
        opacity: 0,
        duration: 0.55,
        ease: 'power2.inOut'
    });

    gsap.to(overlay, {
        opacity: 1,
        duration: 0.65,
        ease: 'power2.inOut',
        onComplete: () => {
            window.location.href = introUrl;
        }
    });
}

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