<div align="center">

<img src="https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" />
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
<img src="https://img.shields.io/badge/JWT-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white" />

# 🌾 SIMHPSB
### Sistem Informasi Monitoring Hasil Panen dan Stok Beras Berbasis Web

*Tugas Besar Rekayasa Sistem Informasi — Kelas-A1 Kelompok 4*
*Program Studi Sistem Informasi — Universitas Kebangsaan Republik Indonesia (UKRI) 2025*

</div>

---

## 📌 Tentang Proyek

**SIMHPSB** adalah sistem informasi berbasis web dan mobile yang dirancang untuk membantu pengelola gudang penggilingan padi dalam:

- Memantau stok gabah dan beras secara **real-time**
- Mencatat hasil panen dengan **konversi otomatis** gabah → beras
- Mengelola distribusi ke pelanggan tetap (MBG, toko mitra)
- Mendapatkan **alert otomatis** saat stok mendekati batas minimum
- Menghitung **HPP & margin keuntungan** secara otomatis
- Menghasilkan **laporan periodik** yang bisa diekspor ke PDF & Excel

> Sistem ini dikembangkan berdasarkan hasil observasi lapangan pada gudang penggilingan padi milik **Silvy Halimatusyadiah** di Desa Gunung Manik, Kecamatan Talaga, Kabupaten Majalengka.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 📊 Dashboard Real-Time | Ringkasan stok, grafik tren panen, alert aktif, kalkulasi margin |
| 🌾 Pencatatan Panen | Input tonase gabah, konversi otomatis ke estimasi beras (default 61,5%) |
| 📦 Stok Gudang | Transaksi masuk/keluar, saldo real-time, kapasitas maks gabah 2.000 kg & beras 1.000 kg |
| 🔔 Alert Otomatis | Notifikasi otomatis saat stok ≤ batas minimum yang dikonfigurasi |
| 💰 Manajemen Harga | Konfigurasi harga beli gabah, ongkos giling, harga jual, kalkulasi HPP & margin |
| 👨‍🌾 Data Petani | CRUD data petani mitra dan lahan |
| 📋 Laporan | Rekapitulasi panen, stok, distribusi, margin — ekspor PDF & Excel |
| 📱 Mobile App | Aplikasi Flutter untuk petugas lapangan (Android) |

---

## 🛠️ Teknologi

### Backend
- **Laravel 10.x** — REST API only (tidak render HTML Blade)
- **MySQL 8.0** — Database utama
- **JWT (JSON Web Token)** — Autentikasi, TTL 8 jam
- **Redis** — Cache & queue jobs

### Frontend Web
- **HTML / CSS / JavaScript** (Blade / Vue.js)

### Mobile
- **Flutter** — Android
- **Dio** — HTTP client
- **flutter_secure_storage** — Penyimpanan JWT

### DevOps
- **Docker** + **Docker Compose** — Containerisasi environment
- **Nginx** — Reverse proxy + SSL

---

## 📁 Struktur Repository

```
SIMHPSB-Kelompok4/
├── backend/                  # Laravel REST API
│   ├── app/
│   │   ├── Http/Controllers/Api/
│   │   ├── Models/
│   │   └── Services/
│   ├── routes/api.php
│   ├── Dockerfile
│   └── .env.example
├── mobile/                   # Flutter Android
│   └── lib/
├── dokumen/                  # SRS & dokumentasi
│   ├── SRS_Kelompok4_v1.2.docx
│   └── notulensi/
├── docker-compose.yml
└── README.md
```

---

## 🚀 Cara Menjalankan (Local Development)

### Prasyarat
- Docker & Docker Compose terinstall
- Git terinstall

### Langkah

**1. Clone repository**
```bash
git clone https://github.com/dzikri15/SIMHPSB-Kelompok4.git
cd SIMHPSB-Kelompok4
```

**2. Salin file environment**
```bash
cp backend/.env.example backend/.env
```

**3. Sesuaikan konfigurasi `.env`**
```env
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=simhpsb_db
DB_USERNAME=root
DB_PASSWORD=secret
JWT_SECRET=your_jwt_secret
```

**4. Jalankan Docker**
```bash
docker-compose up -d
```

**5. Generate key & jalankan migrasi**
```bash
docker exec simhpsb_app php artisan key:generate
docker exec simhpsb_app php artisan jwt:secret
docker exec simhpsb_app php artisan migrate --seed
```

**6. Akses aplikasi**
```
Web     : http://localhost:8080
API     : http://localhost:8080/api
```

---

## 🔑 Akun Default (Seeder)

| Role | Email | Password |
|---|---|---|
| Admin | admin@simhpsb.com | password |
| Petugas | petugas@simhpsb.com | password |
| Petani | petani@simhpsb.com | password |

---

## 📡 API Endpoints

Base URL: `/api`  
Auth: `Authorization: Bearer {token}`

| Method | Endpoint | Deskripsi |
|---|---|---|
| POST | `/api/auth/login` | Login, return JWT token |
| POST | `/api/auth/logout` | Logout, invalidate token |
| GET | `/api/dashboard` | Data ringkasan dashboard |
| GET/POST | `/api/petani` | List / tambah petani |
| GET/POST | `/api/panen` | Riwayat / catat panen |
| GET/POST | `/api/stok` | Riwayat / catat transaksi stok |
| GET | `/api/stok/summary` | Saldo stok real-time |
| GET/PUT | `/api/harga` | Konfigurasi harga |
| GET | `/api/harga/hpp` | Kalkulasi HPP & margin |
| GET | `/api/alert` | List alert aktif |
| PUT | `/api/alert/{id}/resolve` | Tandai alert ditangani |
| GET/POST | `/api/distribusi` | Riwayat / catat distribusi |
| GET | `/api/laporan/panen` | Laporan panen per periode |
| GET | `/api/laporan/stok` | Laporan stok per periode |
| GET | `/api/laporan/margin` | Laporan HPP & margin |

---

## 📊 Data Referensi Lapangan

| Parameter | Nilai |
|---|---|
| Harga beli gabah | Rp 760.000 / 100 kg |
| Ongkos giling | Rp 700 / kg beras |
| Harga jual beras | Rp 13.500 / kg |
| Rasio konversi default | 61,5% (0.615) |
| Kapasitas gudang gabah | 2.000 kg |
| Kapasitas gudang beras | 1.000 kg |
| Target pasar / bulan | 9.000 kg beras |
| Konsumsi MBG / hari | 465 kg (3 dapur × 155 kg) |

---

## 👥 Tim Pengembang

| Nama | NPM | Role |
|---|---|---|
| Muhammad Dzikri Sagara | 20241320004 | Project Manager · Backend Developer · Video Editor |
| Muhammad Alamsyah | 20241320030 | Use Case · Activity · Business Process Diagram |
| Difa Nisa Lutfiah | 20241320013 | Functional Analyst · Class Diagram · Video Editor |
| Fakhry Ahmad Fauzan | 20241320036 | Frontend Developer · UI Designer |
| Devina Ayuliani | 20241320019 | ERD Designer |
| Agusta Firman Firdaus | 20241320016 | Reviewer & Quality Assurance |
| Paiton Wenda | 20241320042 | Documentation & Secretary |

---

## 🏫 Informasi Akademik

| | |
|---|---|
| Mata Kuliah | Rekayasa Sistem Informasi |
| Program Studi | Sistem Informasi |
| Universitas | Kebangsaan Republik Indonesia (UKRI) |
| Kelas | A1 — Kelompok 4 |
| Tahun | 2025 |

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan akademik. Seluruh hak cipta milik Kelompok 4 — Program Studi Sistem Informasi UKRI 2025.

---

<div align="center">

Made with ❤️ by **Kelompok 4 — UKRI 2025**

</div>
