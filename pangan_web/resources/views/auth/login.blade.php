<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login – SIMHPSB</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Lora:ital@1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            min-height: 100vh;
            display: flex;
            background: #0f2218;
            overflow: hidden;
        }

        /* LEFT PANEL */
        .panel-left {
            flex: 1;
            background: linear-gradient(135deg, #1a3a2a 0%, #0f2218 50%, #1e4d35 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 60px 40px;
            position: relative;
            overflow: hidden;
        }

        .panel-left::before {
            content: '';
            position: absolute;
            width: 500px; height: 500px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(56,161,105,.15) 0%, transparent 70%);
            top: -100px; right: -100px;
        }

        .panel-left::after {
            content: '';
            position: absolute;
            width: 300px; height: 300px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(79,213,133,.08) 0%, transparent 70%);
            bottom: -50px; left: -50px;
        }

        .grain {
            position: absolute;
            inset: 0;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.04'/%3E%3C/svg%3E");
            opacity: .4;
            pointer-events: none;
        }

        .left-content { position: relative; z-index: 1; text-align: center; max-width: 380px; }

        .logo-big {
            width: 72px; height: 72px;
            background: linear-gradient(135deg, #4fd585, #38a169);
            border-radius: 20px;
            display: flex; align-items: center; justify-content: center;
            font-size: 34px;
            margin: 0 auto 28px;
            box-shadow: 0 8px 32px rgba(56,161,105,.4);
        }

        .brand-name {
            font-size: 36px;
            font-weight: 800;
            color: #fff;
            letter-spacing: -1px;
            margin-bottom: 8px;
        }

        .brand-tagline {
            font-family: 'Lora', serif;
            font-style: italic;
            color: rgba(255,255,255,.5);
            font-size: 14.5px;
            margin-bottom: 48px;
            line-height: 1.6;
        }

        .features {
            display: flex;
            flex-direction: column;
            gap: 16px;
            text-align: left;
        }

        .feature-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 18px;
            background: rgba(255,255,255,.05);
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,.07);
        }

        .feature-icon {
            width: 38px; height: 38px;
            border-radius: 10px;
            background: rgba(56,161,105,.2);
            display: flex; align-items: center; justify-content: center;
            font-size: 16px;
            color: #4fd585;
            flex-shrink: 0;
        }

        .feature-text { font-size: 13px; color: rgba(255,255,255,.7); line-height: 1.4; }
        .feature-text strong { display: block; color: rgba(255,255,255,.9); font-size: 13.5px; }

        /* RIGHT PANEL */
        .panel-right {
            width: 460px;
            background: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px;
        }

        .login-box { width: 100%; max-width: 360px; }

        .login-header { margin-bottom: 36px; }
        .login-header h2 { font-size: 26px; font-weight: 800; color: #0f2218; margin-bottom: 6px; }
        .login-header p { font-size: 13.5px; color: #7d9a8a; }

        .form-group { margin-bottom: 18px; }

        label {
            display: block;
            font-size: 12.5px;
            font-weight: 600;
            color: #4b6358;
            margin-bottom: 6px;
        }

        .input-wrap {
            position: relative;
        }

        .input-wrap i.icon-left {
            position: absolute;
            left: 13px;
            top: 50%;
            transform: translateY(-50%);
            color: #7d9a8a;
            font-size: 14px;
        }

        .input-wrap input {
            width: 100%;
            padding: 12px 14px 12px 40px;
            border: 1.5px solid #e2e8e4;
            border-radius: 10px;
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 14px;
            color: #0f2218;
            background: #fff;
            transition: border-color .2s, box-shadow .2s;
            outline: none;
        }

        .input-wrap input:focus {
            border-color: #38a169;
            box-shadow: 0 0 0 3px rgba(56,161,105,.12);
        }

        .input-wrap .toggle-pw {
            position: absolute;
            right: 13px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #7d9a8a;
            cursor: pointer;
            font-size: 14px;
            padding: 4px;
        }

        .remember-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }

        .remember-row label {
            display: flex;
            align-items: center;
            gap: 7px;
            font-size: 13px;
            font-weight: 500;
            color: #4b6358;
            cursor: pointer;
            margin: 0;
        }

        .remember-row a {
            font-size: 13px;
            color: #38a169;
            text-decoration: none;
            font-weight: 600;
        }

        .btn-login {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, #38a169, #2d7a52);
            color: #fff;
            border: none;
            border-radius: 10px;
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all .2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            box-shadow: 0 4px 14px rgba(56,161,105,.35);
        }

        .btn-login:hover {
            background: linear-gradient(135deg, #2d7a52, #236040);
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(56,161,105,.4);
        }

        .error-alert {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 14px;
            background: #fee2e2;
            border: 1px solid #fecaca;
            border-radius: 10px;
            color: #991b1b;
            font-size: 13px;
            margin-bottom: 20px;
        }

        .login-footer {
            margin-top: 32px;
            text-align: center;
        }

        .login-footer p {
            font-size: 12px;
            color: #7d9a8a;
        }

        @media (max-width: 900px) {
            .panel-left { display: none; }
            .panel-right { width: 100%; }
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .login-box { animation: slideIn .4s ease; }
    </style>
</head>
<body>

<!-- LEFT PANEL -->
<div class="panel-left">
    <div class="grain"></div>
    <div class="left-content">
        <div class="logo-big">🌾</div>
        <div class="brand-name">SIMHPSB</div>
        <div class="brand-tagline">Sistem Informasi Monitoring Hasil Panen<br>dan Stok Beras Berbasis Web</div>

        <div class="features">
            <div class="feature-item">
                <div class="feature-icon"><i class="fas fa-chart-pie"></i></div>
                <div class="feature-text">
                    <strong>Dashboard Real-Time</strong>
                    Pantau stok gabah & beras kapan saja
                </div>
            </div>
            <div class="feature-item">
                <div class="feature-icon"><i class="fas fa-bell"></i></div>
                <div class="feature-text">
                    <strong>Alert Otomatis</strong>
                    Notifikasi langsung saat stok menipis
                </div>
            </div>
            <div class="feature-item">
                <div class="feature-icon"><i class="fas fa-file-chart-line"></i></div>
                <div class="feature-text">
                    <strong>Laporan & Ekspor</strong>
                    Rekap panen dan margin per periode
                </div>
            </div>
        </div>
    </div>
</div>

<!-- RIGHT PANEL -->
<div class="panel-right">
    <div class="login-box">
        <div class="login-header">
            <h2>Selamat datang 👋</h2>
            <p>Masuk ke panel admin SIMHPSB</p>
        </div>

        @if($errors->any())
            <div class="error-alert">
                <i class="fas fa-exclamation-circle"></i>
                {{ $errors->first() }}
            </div>
        @endif

        @if(session('error'))
            <div class="error-alert">
                <i class="fas fa-exclamation-circle"></i>
                {{ session('error') }}
            </div>
        @endif

        <form method="POST" action="{{ route('login') }}">
            @csrf

            <div class="form-group">
                <label for="email">Email</label>
                <div class="input-wrap">
                    <i class="fas fa-envelope icon-left"></i>
                    <input type="email" id="email" name="email"
                        value="{{ old('email') }}"
                        placeholder="admin@simhpsb.id"
                        required autofocus autocomplete="email">
                </div>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrap">
                    <i class="fas fa-lock icon-left"></i>
                    <input type="password" id="password" name="password"
                        placeholder="••••••••"
                        required autocomplete="current-password">
                    <button type="button" class="toggle-pw" onclick="togglePw()" tabindex="-1">
                        <i class="fas fa-eye" id="eyeIcon"></i>
                    </button>
                </div>
            </div>

            <div class="remember-row">
                <label>
                    <input type="checkbox" name="remember" style="width:auto;margin:0;" {{ old('remember') ? 'checked' : '' }}>
                    Ingat saya
                </label>
                <a href="{{ route('password.request') }}">Lupa password?</a>
            </div>

            <button type="submit" class="btn-login">
                <i class="fas fa-sign-in-alt"></i>
                Masuk ke Dashboard
            </button>
        </form>

        <div class="login-footer">
            <p>SIMHPSB v1.2 &nbsp;·&nbsp; Kelompok 4 UKRI 2025</p>
            <p style="margin-top:4px;">Universitas Kebangsaan Republik Indonesia</p>
        </div>
    </div>
</div>

<script>
function togglePw() {
    const pw = document.getElementById('password');
    const icon = document.getElementById('eyeIcon');
    if (pw.type === 'password') {
        pw.type = 'text';
        icon.className = 'fas fa-eye-slash';
    } else {
        pw.type = 'password';
        icon.className = 'fas fa-eye';
    }
}
</script>
</body>
</html>
