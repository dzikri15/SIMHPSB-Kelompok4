<div align="center">

<img src="https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" />
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
<img src="https://img.shields.io/badge/Groq-F55036?style=for-the-badge&logo=groq&logoColor=white" />
<img src="https://img.shields.io/badge/JWT-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white" />

# 🌾 SIMHP
### Sistem Informasi Monitoring Hasil Panen Berbasis Web & Mobile

*Tugas Besar Rekayasa Sistem Informasi — Kelas-A1 Kelompok 4*
*Program Studi Sistem Informasi — Universitas Kebangsaan Republik Indonesia (UKRI) 2026*

</div>

---

## 📌 Tentang Proyek

**SIMHP** adalah sistem informasi berbasis web dan mobile yang dirancang untuk membantu pengelola gudang penggilingan padi dalam:

- Memantau stok gabah dan beras secara **real-time**
- Mencatat hasil panen beserta **foto bukti** dan **harga gabah per kg** yang disimpan sebagai snapshot
- Mengelola distribusi ke pelanggan tetap (MBG, toko mitra)
- Mendapatkan **alert otomatis** saat stok mendekati batas minimum yang dikonfigurasi
- Menghasilkan **laporan panen & stok** yang bisa diekspor ke PDF & Excel
- Integrasi dengan **Groq API (Llama 3.3 70B)** untuk chatbot AI HPSBBot

> Sistem ini dikembangkan berdasarkan hasil observasi lapangan pada gudang penggilingan padi milik **Silvy Halimatusyadiah** di Desa Gunung Manik, Kecamatan Talaga, Kabupaten Majalengka.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 📊 Dashboard Real-Time | Ringkasan stok, grafik tren panen, alert aktif, harga gabah terkini |
| 🌾 Pencatatan Panen | Input hasil gabah + foto bukti wajib, snapshot harga, gabah otomatis masuk stok gudang |
| 📦 Stok Gudang | Transaksi masuk/keluar (foto bukti wajib), saldo real-time, beras masuk input manual setelah giling |
| 🔔 Alert Otomatis | Notifikasi real-time saat stok ≤ batas minimum (konfigurasi beras & gabah) |
| 💰 Manajemen Harga | Konfigurasi harga beli gabah per kg & harga jual beras per kg |
| 👨‍🌾 Data Petani | CRUD data petani mitra, lahan, kontak, riwayat panen & penghasilan gabah |
| 📋 Laporan | Rekapitulasi panen & stok — ekspor PDF & Excel |
| 📍 Tujuan Distribusi | Manajemen daftar lokasi pengiriman (akses Admin & Petugas) |
| 🤖 Chatbot HPSBBot | Asisten AI berbasis Groq API + Llama 3.3 70B untuk tanya stok & harga real-time (khusus Admin & Petugas) |
| 📱 Mobile App | Aplikasi Flutter untuk petugas lapangan & petani monitoring dari lokasi |
| 🔐 Autentikasi | JWT Token-based authentication, session management, role-based access |
| 🔄 Sinkronisasi | Real-time data sync antara web dan mobile app via REST API |

---

## 🛠️ Teknologi & Stack

### Backend
- **Laravel 12.x** — Full-stack web framework dengan Blade & REST API
- **MySQL 8.0** — Relational Database Management System
- **JWT (JSON Web Token)** — Token-based authentication (TTL: 8 jam, Refresh: 20160 jam)
- **Redis 7** — In-memory cache & queue management
- **HS256** — JWT Algorithm untuk signing tokens

### Frontend Web
- **HTML5 / CSS3 / JavaScript** — UI Components
- **Blade Templating** — Dynamic template rendering
- **Custom CSS** — Dark mode support, responsive design

### Mobile
- **Flutter 3.x** — Cross-platform mobile framework
- **Dart 3.x** — Programming language
- **http** — HTTP client untuk REST API
- **SharedPreferences** — Local data storage untuk JWT tokens
- **image_picker** — Upload foto bukti transaksi

### Infrastructure & DevOps
- **Docker** — Containerization
- **Docker Compose** — Multi-container orchestration
- **Nginx** — Reverse proxy & web server
- **Groq API** — AI inference engine (LPU architecture, latency rendah)
- **Meta Llama 3.3 70B Versatile** — AI model untuk chatbot HPSBBot
- **phpMyAdmin** — Database management interface

---

## 📁 Struktur Repository

```
SIMHPSB-Kelompok4/
├── pangan_web/                           # Laravel Backend + Web Admin
│   ├── app/
│   │   ├── Http/Controllers/
│   │   │   ├── Api/
│   │   │   │   ├── AuthController.php           # JWT Authentication
│   │   │   │   ├── PetaniController.php         # Farmer Management (CRUD)
│   │   │   │   ├── LahanController.php          # Land/Field Management
│   │   │   │   ├── PanenController.php          # Harvest Recording
│   │   │   │   ├── StokController.php           # Inventory Management
│   │   │   │   ├── HargaController.php          # Price Configuration
│   │   │   │   ├── AlertController.php          # Stock Alerts
│   │   │   │   ├── TujuanDistribusiController.php # Distribution Targets
│   │   │   │   ├── LaporanController.php        # Reports & Analytics
│   │   │   │   └── PetaniProfileController.php  # Farmer Profile (Mobile)
│   │   │   ├── Admin/                           # Web Admin Controllers
│   │   │   ├── ChatbotController.php            # Proxy ke Groq API (Chatbot)
│   │   │   └── PetaniDashboardController.php    # Petani Web Dashboard
│   │   ├── Models/
│   │   │   ├── User.php                  # User accounts
│   │   │   ├── Petani.php                # Farmers
│   │   │   ├── Lahan.php                 # Land/Fields
│   │   │   ├── Panen.php                 # Harvest records
│   │   │   ├── Stok.php                  # Inventory (stok_beras)
│   │   │   ├── KonfigurasiHarga.php      # Price configuration
│   │   │   ├── Alert.php                 # Alerts
│   │   │   ├── AlertConfiguration.php    # Alert thresholds
│   │   │   └── TujuanDistribusi.php      # Distribution targets
│   ├── routes/
│   │   ├── api.php                       # API Routes (Protected by auth:api)
│   │   └── web.php                       # Web Admin Routes
│   ├── database/
│   │   ├── migrations/                   # Schema creation scripts
│   │   └── seeders/                      # Sample data seeds
│   ├── resources/views/
│   │   ├── auth/                         # Login, Intro, About pages
│   │   ├── admin/                        # Web admin pages
│   │   ├── petani/                       # Petani dashboard
│   │   ├── layout/                       # Base layouts
│   │   └── chat-widget.blade.php         # Chatbot HPSBBot widget
│   ├── storage/                          # File storage (foto bukti)
│   ├── Dockerfile                        # Laravel + PHP-FPM container
│   ├── docker-compose.yml                # Full stack orchestration
│   ├── docker-entrypoint.sh              # Container startup script
│   ├── .dockerignore                     # Docker build exclusions
│   ├── simhpsb_db.sql                    # Database dump with seed data
│   └── composer.json                     # PHP dependencies
│
├── pangan_mobile/                        # Flutter Mobile App (Android)
│   ├── lib/
│   │   ├── main.dart                     # App entry point
│   │   ├── main_shell.dart               # Shell routing + Chatbot widget
│   │   ├── screens/                      # UI Pages
│   │   │   ├── beranda_screen.dart       # Home/Dashboard (Petugas & Petani)
│   │   │   ├── login_screen.dart         # Authentication
│   │   │   ├── gudang_screen.dart        # Stok Gudang
│   │   │   ├── panen_screen.dart         # Pencatatan Panen
│   │   │   ├── distribusi_tujuan_screen.dart # Tujuan Distribusi
│   │   │   └── petani_profile_screen.dart    # Profil Petani
│   │   ├── services/
│   │   │   ├── auth_service.dart         # JWT authentication
│   │   │   ├── api_service.dart          # HTTP client with token refresh
│   │   │   └── transaksi_stok_service.dart   # Stok transactions
│   │   │   
│   │   ├── models/                       # Data models
│   │   ├── widgets/
│   │   │   └── catat_transaksi_dialog.dart   # Dialog catat stok
│   │   │   
│   │   └── core/
│   │       └── constants.dart            # Base URL & app constants
│   ├── android/
│   ├── pubspec.yaml                      # Flutter dependencies
│   └── pubspec.lock
│
├── Diagram/                              # System Architecture Diagrams
│   ├── ERD.drawio.xml
│   ├── Class Diagram.drawio.xml
│   ├── Use Case Diagram.drawio.xml
│   ├── Component Diagram.drawio.xml
│   ├── Deployment Diagram.drawio.xml
│   ├── Aktivity Diagram.drawio.xml
│   └── SequenceDiagram*.xml
│
├── docs/                                 # Documentation & Guides
│   ├── testing/
│   ├── screenshots/
│   ├── API.md
│   └── USER_GUIDE.md
│
├── CHANGELOG.md                          # Riwayat perubahan sistem
├── GITHUB_ISSUES.md                      # Issue tracking & task management
├── README.md                             # Main documentation (this file)
└── simhpsb_db.sql                        # Master database backup
```

---

## 📸 Screenshot Aplikasi

### Web Dashboard
![Login Page](./pangan_web/foto/login.png)
*Halaman login dengan validasi JWT authentication*

### Mobile App
Aplikasi Flutter untuk monitoring real-time dari lapangan oleh petugas dan petani:
- Home dashboard dengan ringkasan stok & aktivitas terakhir
- Pencatatan panen dengan foto bukti
- Monitoring stok gudang + catat transaksi
- Manajemen tujuan distribusi

---

## 🚀 Quick Start - Docker Setup

### Prerequisites

Verifikasi semua sudah terinstall:
```cmd
docker --version
docker compose version
git --version
```

**Download jika belum ada:**
- Docker Desktop: https://www.docker.com/products/docker-desktop
- Git: https://git-scm.com/download/win

---

### Setup

#### STEP 1: Clone Repository
```cmd
git clone https://github.com/dzikri15/SIMHPSB-Kelompok4.git
cd SIMHPSB-Kelompok4\pangan_web
```

#### STEP 2: Setup Environment
```cmd
copy .env.example .env
```
✅ File `.env` sudah configured untuk Docker

#### STEP 3: Start Docker Services
```cmd
docker compose up -d --build
```
⏳ Tunggu 3-5 menit sampai semua container healthy

Cek status:
```cmd
docker compose ps
```

**Semua services harus "running" atau "healthy"** ✅

#### STEP 4: Clear Cache
```cmd
docker compose exec app php artisan config:clear
docker compose exec app php artisan cache:clear
docker compose exec app php artisan route:clear
```

✅ **SELESAI! Aplikasi sudah siap diakses.**

---

## 🌐 Akses Aplikasi

| Service | URL | Kredensial |
|---------|-----|-----------|
| **Web App (Admin)** | http://localhost | admin@simhpsb.com / password |
| **Web App (Petugas)** | http://localhost | petugas@simhpsb.com / password |
| **Web App (Petani)** | http://localhost | petani@simhpsb.com / password |
| **phpMyAdmin** | http://localhost:8080 | root / root |

> **Catatan:** Web App sekarang diakses via Nginx di port 80 (`http://localhost`), bukan port 8000.

---

## 🔐 Testing API Endpoints

### 1. Login & Get JWT Token
```cmd
curl -X POST http://localhost/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"petugas@simhpsb.com\",\"password\":\"password\"}"
```

Response:
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 28800
}
```

### 2. Get Dashboard Summary
```cmd
curl -X GET http://localhost/api/stok/summary ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 3. List Petani
```cmd
curl -X GET "http://localhost/api/petani?per_page=10" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 4. Get Alert Minimum
```cmd
curl -X GET http://localhost/api/alert/minimum ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📋 API Endpoints Reference

### Authentication
- `POST /api/auth/login` — Login & get JWT token
- `POST /api/auth/logout` — Logout & invalidate token
- `GET /api/auth/me` — Get current user info
- `POST /api/auth/refresh` — Refresh expired token

### Petani (Farmers)
- `GET /api/petani` — List all farmers (paginated)
- `POST /api/petani` — Create new farmer
- `GET /api/petani/{id}` — Get farmer details
- `PUT /api/petani/{id}` — Update farmer
- `DELETE /api/petani/{id}` — Delete farmer

### Panen (Harvest)
- `GET /api/panen` — List harvest records
- `POST /api/panen` — Create harvest record (foto bukti wajib)
- `GET /api/panen/{id}` — Get harvest details
- `PUT /api/panen/{id}` — Update harvest
- `DELETE /api/panen/{id}` — Delete harvest

### Stok (Inventory)
- `GET /api/stok/summary` — Dashboard summary
- `GET /api/stok/monitoring` — Monitoring per warehouse
- `GET /api/stok/transaksi` — List transactions
- `POST /api/stok/catat` — Record transaction (foto bukti wajib)
- `PATCH /api/stok/{id}/toggle-status` — Aktifkan/batalkan transaksi

### Harga (Prices)
- `GET /api/harga` — List konfigurasi harga
- `POST /api/harga` — Create price config (harga_beli_gabah, harga_jual_beras)
- `PUT /api/harga/{id}` — Update price

### Tujuan Distribusi
- `GET /api/tujuan-distribusi` — List tujuan
- `POST /api/tujuan-distribusi` — Tambah tujuan baru
- `DELETE /api/tujuan-distribusi/{id}` — Hapus tujuan

### Alerts
- `GET /api/alert` — List all alerts
- `GET /api/alert/minimum` — Alerts below minimum
- `GET /api/alert/konfigurasi` — Get alert thresholds
- `PUT /api/alert/konfigurasi` — Update alert thresholds
- `POST /api/alert/{id}/handle` — Mark alert as handled

### Laporan (Reports)
- `GET /api/laporan/panen` — Harvest report
- `GET /api/laporan/stok` — Inventory report

### Petani Profile (Mobile)
- `GET /api/petani-profile` — Get logged-in petani profile
- `GET /api/petani-profile/panen` — Petani's harvest history
- `GET /api/petani-profile/summary` — Petani's harvest summary

---

## 📱 Mobile App Setup

### Prerequisites
- Flutter SDK: https://flutter.dev/docs/get-started/install
- Android Studio atau VS Code + Dart extension
- Android device atau emulator

### Run Mobile App
```bash
cd pangan_mobile
flutter pub get
flutter run
```

### Configure API Endpoint
Edit `lib/core/constants.dart`:
```dart
class AppConstants {
  // Local network (HP + laptop satu WiFi)
  static const String baseUrl = 'http://192.168.1.X/api';

  // Emulator Android
  // static const String baseUrl = 'http://10.0.2.2/api';

  // Production VPS
  // static const String baseUrl = 'http://IP_VPS:3002/api';
}
```

> **Catatan:** Pastikan HP dan laptop terhubung ke WiFi yang sama saat testing lokal.

---

## 🤖 Chatbot HPSBBot Setup (Groq)

Chatbot HPSBBot menggunakan arsitektur Prompt Engineering / RAG sederhana:
```
Browser/Mobile → Laravel (ChatbotController) → inject ringkasan stok & harga
dari MySQL ke system prompt → Groq API (Llama 3.3 70B) → jawaban ke user
```

> Akses fitur ini dibatasi hanya untuk role **Admin** dan **Petugas**; Petani tidak memiliki akses.

### Setup Groq API
1. Buat akun di https://console.groq.com
2. Generate API key di halaman **API Keys**
3. Masukkan API key ke `.env` (lihat Environment Variables di bawah)
4. Model yang digunakan: `llama-3.3-70b-versatile`

### Environment Variables
Tambahkan di `.env`:
```
GROQ_API_KEY=your_groq_api_key
GROQ_MODEL=llama-3.3-70b-versatile
```

---

## 🛑 Container Management

```cmd
# Lihat status semua container
docker compose ps

# Stop (data tetap aman)
docker compose stop

# Start kembali
docker compose start

# Restart
docker compose restart

# Lihat log
docker compose logs -f app

# Masuk container Laravel
docker compose exec app bash

# Stop + hapus container (data volume AMAN)
docker compose down

# Stop + hapus SEMUA termasuk data (HATI-HATI!)
docker compose down -v
```

---

## 🔧 Troubleshooting

### Web tidak bisa diakses
```cmd
docker compose logs nginx
docker compose restart nginx
```

### MySQL Connection Failed
```cmd
docker compose logs db
docker compose restart db
```

### Cache/Config Errors
```cmd
docker compose exec app php artisan cache:clear
docker compose exec app php artisan config:clear
docker compose exec app php artisan route:clear
```

### Storage foto tidak muncul
```cmd
docker compose exec app php artisan storage:link
```

### Rebuild setelah perubahan kode
```cmd
docker compose up -d --build app
```

---

## 📚 Documentation

- **[CHANGELOG.md](./CHANGELOG.md)** — Riwayat semua perubahan sistem
- **[Database Schema](./Diagram/ERD.drawio.xml)** — Entity Relationship Diagram
- **[Test Cases](./docs/testing/)** — QA test specifications

---

## 👥 Tim Pengembang

**Kelompok 4 — Sistem Informasi UKRI 2026**

| # | Nama | GitHub | Peran Utama | Tanggung Jawab |
|---|------|--------|-------------|----------------|
| 1️⃣ | Muhammad Dzikri Sagara | [@dzikri15](https://github.com/dzikri15) | PM · Backend · DevOps | Arsitektur backend, REST API, Docker setup, integrasi AI (Groq), deployment |
| 2️⃣ | Fakhry Ahmad Fauzan | [@NoahMikhailovna](https://github.com/NoahMikhailovna) | Frontend Web · Flutter Mobile | UI/UX web admin, Flutter mobile app, API integration |
| 3️⃣ | Muhammad Alamsyah | [@L-6969](https://github.com/L-6969) | AI Integration · DevOps · QA Web | Integrasi Groq API, diagram sistem, QA web, dokumentasi |
| 4️⃣ | Difa Nisa Lutfiah | [@difanisa](https://github.com/difanisa) | QA Web · Diagram · Dokumentasi | Diagram sistem, QA web, manual book web |
| 5️⃣ | Devina Ayuliani | [@ayoel99](https://github.com/ayoel99) | QA Mobile · ERD · Final Report | ERD, QA mobile, panduan pengguna mobile |
| 6️⃣ | Agusta Firman Firdaus | [@AgustaFirmanFirdaus](https://github.com/AgustaFirmanFirdaus) | QA Mobile · Testing | Testing aplikasi mobile, dokumentasi manual mobile |

---

## 📊 Project Progress

### ✅ Selesai
- Backend API Laravel 12 — Production Ready
- Docker containerization (Nginx + PHP-FPM + MySQL + Redis + phpMyAdmin)
- JWT Authentication & Role-based Access (Admin, Petugas, Petani)
- Pencatatan Panen + foto bukti wajib + snapshot harga gabah
- Stok Gudang — transaksi masuk/keluar, foto bukti wajib, gabah masuk otomatis dari panen
- Alert stok otomatis
- Manajemen Harga (harga beli gabah & jual beras)
- Tujuan Distribusi (akses Admin & Petugas)
- Laporan Panen & Stok (PDF & Excel)
- Dashboard Petani — harga gabah terkini, rekap harian, paginasi
- Chatbot HPSBBot (Groq API + Llama 3.3 70B) — web & mobile, khusus Admin & Petugas
- Flutter Mobile App (Petugas & Petani)
- Halaman About/Profile sistem
- Testing & QA menyeluruh
- Deployment ke VPS production — **live di [simhp.my.id](https://simhp.my.id)**

---

## 📈 Statistik Proyek

| Metrik | Value |
|--------|-------|
| Total Lines of Code | ~20,000+ |
| API Endpoints | 35+ |
| Database Tables | 11 |
| Container Services | 5 (app, nginx, db, redis, phpmyadmin) |
| Team Size | 6 |
| Platform | Web + Android |

---

## 📄 License

MIT License — See [LICENSE](./LICENSE) file for details.

---

**Last Updated:** 10 Juli 2026
**Version:** 3.1
**Status:** 🟢 Live in Production
**Production URL:** https://simhp.my.id
**Repository:** https://github.com/dzikri15/SIMHPSB-Kelompok4
│   │   │   │   └── PetaniProfileController.php  # Farmer Profile (Mobile)
│   │   │   ├── Admin/                           # Web Admin Controllers
│   │   │   ├── ChatbotController.php            # Proxy ke n8n Chatbot
│   │   │   └── PetaniDashboardController.php    # Petani Web Dashboard
│   │   ├── Models/
│   │   │   ├── User.php                  # User accounts
│   │   │   ├── Petani.php                # Farmers
│   │   │   ├── Lahan.php                 # Land/Fields
│   │   │   ├── Panen.php                 # Harvest records
│   │   │   ├── Stok.php                  # Inventory (stok_beras)
│   │   │   ├── KonfigurasiHarga.php      # Price configuration
│   │   │   ├── Alert.php                 # Alerts
│   │   │   ├── AlertConfiguration.php    # Alert thresholds
│   │   │   └── TujuanDistribusi.php      # Distribution targets
│   ├── routes/
│   │   ├── api.php                       # API Routes (Protected by auth:api)
│   │   └── web.php                       # Web Admin Routes
│   ├── database/
│   │   ├── migrations/                   # Schema creation scripts
│   │   └── seeders/                      # Sample data seeds
│   ├── resources/views/
│   │   ├── auth/                         # Login, Intro, About pages
│   │   ├── admin/                        # Web admin pages
│   │   ├── petani/                       # Petani dashboard
│   │   ├── layout/                       # Base layouts
│   │   └── chat-widget.blade.php         # Chatbot HPSBBot widget
│   ├── storage/                          # File storage (foto bukti)
│   ├── Dockerfile                        # Laravel + PHP-FPM container
│   ├── docker-compose.yml                # Full stack orchestration
│   ├── docker-entrypoint.sh              # Container startup script
│   ├── .dockerignore                     # Docker build exclusions
│   ├── simhpsb_db.sql                    # Database dump with seed data
│   └── composer.json                     # PHP dependencies
│
├── pangan_mobile/                        # Flutter Mobile App (Android)
│   ├── lib/
│   │   ├── main.dart                     # App entry point
│   │   ├── main_shell.dart               # Shell routing + Chatbot widget
│   │   ├── screens/                      # UI Pages
│   │   │   ├── beranda_screen.dart       # Home/Dashboard (Petugas & Petani)
│   │   │   ├── login_screen.dart         # Authentication
│   │   │   ├── gudang_screen.dart        # Stok Gudang
│   │   │   ├── panen_screen.dart         # Pencatatan Panen
│   │   │   ├── distribusi_tujuan_screen.dart # Tujuan Distribusi
│   │   │   └── petani_profile_screen.dart    # Profil Petani
│   │   ├── services/
│   │   │   ├── auth_service.dart         # JWT authentication
│   │   │   ├── api_service.dart          # HTTP client with token refresh
│   │   │   └── transaksi_stok_service.dart   # Stok transactions
│   │   │   
│   │   ├── models/                       # Data models
│   │   ├── widgets/
│   │   │   └── catat_transaksi_dialog.dart   # Dialog catat stok
│   │   │   
│   │   └── core/
│   │       └── constants.dart            # Base URL & app constants
│   ├── android/
│   ├── pubspec.yaml                      # Flutter dependencies
│   └── pubspec.lock
│
├── Diagram/                              # System Architecture Diagrams
│   ├── ERD.drawio.xml
│   ├── Class Diagram.drawio.xml
│   ├── Use Case Diagram.drawio.xml
│   ├── Component Diagram.drawio.xml
│   ├── Deployment Diagram.drawio.xml
│   ├── Aktivity Diagram.drawio.xml
│   └── SequenceDiagram*.xml
│
├── docs/                                 # Documentation & Guides
│   ├── testing/
│   ├── screenshots/
│   ├── API.md
│   └── USER_GUIDE.md
│
├── CHANGELOG.md                          # Riwayat perubahan sistem
├── GITHUB_ISSUES.md                      # Issue tracking & task management
├── README.md                             # Main documentation (this file)
└── simhpsb_db.sql                        # Master database backup
```

---

## 📸 Screenshot Aplikasi

### Web Dashboard
![Login Page](./pangan_web/foto/login.png)
*Halaman login dengan validasi JWT authentication*

### Mobile App
Aplikasi Flutter untuk monitoring real-time dari lapangan oleh petugas dan petani:
- Home dashboard dengan ringkasan stok & aktivitas terakhir
- Pencatatan panen dengan foto bukti
- Monitoring stok gudang + catat transaksi
- Manajemen tujuan distribusi

---

## 🚀 Quick Start - Docker Setup

### Prerequisites

Verifikasi semua sudah terinstall:
```cmd
docker --version
docker compose version
git --version
```

**Download jika belum ada:**
- Docker Desktop: https://www.docker.com/products/docker-desktop
- Git: https://git-scm.com/download/win

---

### Setup

#### STEP 1: Clone Repository
```cmd
git clone https://github.com/dzikri15/SIMHPSB-Kelompok4.git
cd SIMHPSB-Kelompok4\pangan_web
```

#### STEP 2: Setup Environment
```cmd
copy .env.example .env
```
✅ File `.env` sudah configured untuk Docker

#### STEP 3: Start Docker Services
```cmd
docker compose up -d --build
```
⏳ Tunggu 3-5 menit sampai semua container healthy

Cek status:
```cmd
docker compose ps
```

**Semua services harus "running" atau "healthy"** ✅

#### STEP 4: Clear Cache
```cmd
docker compose exec app php artisan config:clear
docker compose exec app php artisan cache:clear
docker compose exec app php artisan route:clear
```

✅ **SELESAI! Aplikasi sudah siap diakses.**

---

## 🌐 Akses Aplikasi

| Service | URL | Kredensial |
|---------|-----|-----------|
| **Web App (Admin)** | http://localhost | admin@simhpsb.com / password |
| **Web App (Petugas)** | http://localhost | petugas@simhpsb.com / password |
| **Web App (Petani)** | http://localhost | petani@simhpsb.com / password |
| **phpMyAdmin** | http://localhost:8080 | root / root |
| **n8n Automation** | http://localhost:5678 | — setup saat pertama buka |

> **Catatan:** Web App sekarang diakses via Nginx di port 80 (`http://localhost`), bukan port 8000.

---

## 🔐 Testing API Endpoints

### 1. Login & Get JWT Token
```cmd
curl -X POST http://localhost/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"petugas@simhpsb.com\",\"password\":\"password\"}"
```

Response:
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 28800
}
```

### 2. Get Dashboard Summary
```cmd
curl -X GET http://localhost/api/stok/summary ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 3. List Petani
```cmd
curl -X GET "http://localhost/api/petani?per_page=10" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 4. Get Alert Minimum
```cmd
curl -X GET http://localhost/api/alert/minimum ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📋 API Endpoints Reference

### Authentication
- `POST /api/auth/login` — Login & get JWT token
- `POST /api/auth/logout` — Logout & invalidate token
- `GET /api/auth/me` — Get current user info
- `POST /api/auth/refresh` — Refresh expired token

### Petani (Farmers)
- `GET /api/petani` — List all farmers (paginated)
- `POST /api/petani` — Create new farmer
- `GET /api/petani/{id}` — Get farmer details
- `PUT /api/petani/{id}` — Update farmer
- `DELETE /api/petani/{id}` — Delete farmer

### Panen (Harvest)
- `GET /api/panen` — List harvest records
- `POST /api/panen` — Create harvest record (foto bukti wajib)
- `GET /api/panen/{id}` — Get harvest details
- `PUT /api/panen/{id}` — Update harvest
- `DELETE /api/panen/{id}` — Delete harvest

### Stok (Inventory)
- `GET /api/stok/summary` — Dashboard summary
- `GET /api/stok/monitoring` — Monitoring per warehouse
- `GET /api/stok/transaksi` — List transactions
- `POST /api/stok/catat` — Record transaction (foto bukti wajib)
- `PATCH /api/stok/{id}/toggle-status` — Aktifkan/batalkan transaksi

### Harga (Prices)
- `GET /api/harga` — List konfigurasi harga
- `POST /api/harga` — Create price config (harga_beli_gabah, harga_jual_beras)
- `PUT /api/harga/{id}` — Update price

### Tujuan Distribusi
- `GET /api/tujuan-distribusi` — List tujuan
- `POST /api/tujuan-distribusi` — Tambah tujuan baru
- `DELETE /api/tujuan-distribusi/{id}` — Hapus tujuan

### Alerts
- `GET /api/alert` — List all alerts
- `GET /api/alert/minimum` — Alerts below minimum
- `GET /api/alert/konfigurasi` — Get alert thresholds
- `PUT /api/alert/konfigurasi` — Update alert thresholds
- `POST /api/alert/{id}/handle` — Mark alert as handled

### Laporan (Reports)
- `GET /api/laporan/panen` — Harvest report
- `GET /api/laporan/stok` — Inventory report

### Petani Profile (Mobile)
- `GET /api/petani-profile` — Get logged-in petani profile
- `GET /api/petani-profile/panen` — Petani's harvest history
- `GET /api/petani-profile/summary` — Petani's harvest summary

---

## 📱 Mobile App Setup

### Prerequisites
- Flutter SDK: https://flutter.dev/docs/get-started/install
- Android Studio atau VS Code + Dart extension
- Android device atau emulator

### Run Mobile App
```bash
cd pangan_mobile
flutter pub get
flutter run
```

### Configure API Endpoint
Edit `lib/core/constants.dart`:
```dart
class AppConstants {
  // Local network (HP + laptop satu WiFi)
  static const String baseUrl = 'http://192.168.1.X/api';

  // Emulator Android
  // static const String baseUrl = 'http://10.0.2.2/api';

  // Production VPS
  // static const String baseUrl = 'http://IP_VPS:3002/api';
}
```

> **Catatan:** Pastikan HP dan laptop terhubung ke WiFi yang sama saat testing lokal.

---

## 🤖 Chatbot HPSBBot Setup (n8n)

Chatbot HPSBBot menggunakan arsitektur:
```
Browser/Mobile → Laravel (/chatbot/HPSBBot) → n8n Webhook → Google Gemini → Balik ke user
```

### Setup n8n
1. Buka http://localhost:5678 → setup akun pertama kali
2. Import workflow `SIMHPSB-Stage3-AutoToken.json` (ada di repo)
3. Tambah credential **Google Gemini** dengan API key dari https://aistudio.google.com
4. Publish workflow

### Environment Variables
Tambahkan di `.env`:
```
N8N_WEBHOOK_URL=http://n8n:5678/webhook/simhpsb-chat
N8N_BASIC_AUTH_USER=your_n8n_email
N8N_BASIC_AUTH_PASSWORD=your_n8n_password
GEMINI_API_KEY=your_gemini_api_key
```

---

## 🛑 Container Management

```cmd
# Lihat status semua container
docker compose ps

# Stop (data tetap aman)
docker compose stop

# Start kembali
docker compose start

# Restart
docker compose restart

# Lihat log
docker compose logs -f app

# Masuk container Laravel
docker compose exec app bash

# Stop + hapus container (data volume AMAN)
docker compose down

# Stop + hapus SEMUA termasuk data (HATI-HATI!)
docker compose down -v
```

---

## 🔧 Troubleshooting

### Web tidak bisa diakses
```cmd
docker compose logs nginx
docker compose restart nginx
```

### MySQL Connection Failed
```cmd
docker compose logs db
docker compose restart db
```

### Cache/Config Errors
```cmd
docker compose exec app php artisan cache:clear
docker compose exec app php artisan config:clear
docker compose exec app php artisan route:clear
```

### Storage foto tidak muncul
```cmd
docker compose exec app php artisan storage:link
```

### Rebuild setelah perubahan kode
```cmd
docker compose up -d --build app
```

---

## 📚 Documentation

- **[CHANGELOG.md](./CHANGELOG.md)** — Riwayat semua perubahan sistem
- **[Database Schema](./Diagram/ERD.drawio.xml)** — Entity Relationship Diagram
- **[Test Cases](./docs/testing/)** — QA test specifications

---

## 👥 Tim Pengembang

**Kelompok 4 — Sistem Informasi UKRI 2026**

| # | Nama | GitHub | Peran Utama | Tanggung Jawab |
|---|------|--------|-------------|----------------|
| 1️⃣ | Muhammad Dzikri Sagara | [@dzikri15](https://github.com/dzikri15) | PM · Backend · DevOps | Arsitektur backend, REST API, Docker setup, n8n AI integration, deployment |
| 2️⃣ | Fakhry Ahmad Fauzan | [@NoahMikhailovna](https://github.com/NoahMikhailovna) | Frontend Web · Flutter Mobile | UI/UX web admin, Flutter mobile app, API integration |
| 3️⃣ | Muhammad Alamsyah | [@L-6969](https://github.com/L-6969) | n8n · DevOps · QA Web | n8n workflows, diagram sistem, QA web, dokumentasi |
| 4️⃣ | Difa Nisa Lutfiah | [@difanisa](https://github.com/difanisa) | QA Web · Diagram · Dokumentasi | Diagram sistem, QA web, manual book web |
| 5️⃣ | Devina Ayuliani | [@ayoel99](https://github.com/ayoel99) | QA Mobile · ERD · Final Report | ERD, QA mobile, panduan pengguna mobile |
| 6️⃣ | Agusta Firman Firdaus | [@AgustaFirmanFirdaus](https://github.com/AgustaFirmanFirdaus) | QA Mobile · Testing | Testing aplikasi mobile, dokumentasi manual mobile |

---

## 📊 Project Progress

### ✅ Selesai
- Backend API Laravel 12 — Production Ready
- Docker containerization (Nginx + PHP-FPM + MySQL + Redis + n8n)
- JWT Authentication & Role-based Access (Admin, Petugas, Petani)
- Pencatatan Panen + foto bukti wajib + snapshot harga gabah
- Stok Gudang — transaksi masuk/keluar, foto bukti wajib, gabah masuk otomatis dari panen
- Alert stok otomatis
- Manajemen Harga (harga beli gabah & jual beras)
- Tujuan Distribusi (akses Admin & Petugas)
- Laporan Panen & Stok (PDF & Excel)
- Dashboard Petani — harga gabah terkini, rekap harian, paginasi
- Chatbot HPSBBot (n8n + Gemini 2.5 Flash) — web & mobile
- Flutter Mobile App (Petugas & Petani)
- Halaman About/Profile sistem

### 🟡 Ongoing
- Testing & QA menyeluruh
- Deployment ke VPS production

---

## 📈 Statistik Proyek

| Metrik | Value |
|--------|-------|
| Total Lines of Code | ~20,000+ |
| API Endpoints | 35+ |
| Database Tables | 11 |
| Container Services | 6 (app, nginx, db, redis, phpmyadmin, n8n) |
| Team Size | 6 |
| Platform | Web + Android |

---

## 📄 License

MIT License — See [LICENSE](./LICENSE) file for details.

---

**Last Updated:** 3 Juli 2026
**Version:** 2.0
**Status:** 🟢 Production Ready
**Repository:** https://github.com/dzikri15/SIMHPSB-Kelompok4
