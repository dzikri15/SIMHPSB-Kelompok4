# 📋 SIMHPSB — GitHub Issues & Sprint Planning

Sistem Informasi Monitoring Hasil Panen dan Stok Beras  
**Kelompok 4 | Rekayasa Sistem Informasi A1 | UKRI**

---

## 👥 Pembagian Tim

| Anggota | GitHub | Peran |
|---------|--------|-------|
| Muhammad Dzikri Sagara | dzikri15 | PM + Backend + DevOps |
| Fahri | NoahMikhailovna | Frontend Web + Mobile Flutter |
| Alamsyah | - | Diagram + QA Web + Manual Book Web |
| Difa | - | Diagram + QA Web + Manual Book Web |
| Devina | - | Diagram + QA Mobile + Manual Book Mobile |
| Agusta | - | QA Mobile + Manual Book Mobile + Testing |

---

## 🏷️ Label yang Digunakan

| Label | Warna | Keterangan |
|-------|-------|------------|
| backend | 🔵 Biru | Laravel API, database, server |
| mobile | 🟢 Hijau | Flutter, Dart |
| frontend | 🟡 Kuning | Laravel Blade, HTML, CSS, JS |
| database | 🟠 Orange | Migration, model, seeder |
| devops | 🔴 Merah | Docker, Redis, deployment |
| diagram | 🟣 Ungu | UML, ERD, draw.io |
| documentation | ⚪ Abu | README, manual book, laporan |
| testing | 🩷 Pink | QA, test case, bug fixing |
| setup | ⬛ Hitam | Setup awal project |

---

## 📌 Sprint Planning

| Sprint | Periode | Fokus |
|--------|---------|-------|
| Sprint 1 | 3 Mei — 17 Mei 2026 | Setup, diagram, UI web & mobile HTML |
| Sprint 2 | 18 Mei — 24 Mei 2026 | Backend auth & database + konversi Flutter |
| Sprint 3 | 25 Mei — 31 Mei 2026 | Backend API + integrasi Flutter |
| Sprint 4 | 1 Jun — 7 Jun 2026 | QA Web + QA Mobile |
| Sprint 5 | 8 Jun — 14 Jun 2026 | Manual book + dokumentasi akhir + video |

---

## 🗂️ Issues Lengkap

---

### 🔧 Cleanup & Setup

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #1 | Upload dokumen SRS SIMHPSB v2.2 | documentation | dzikri15 | High | Sprint 1 | ✅ Done |
| #2 | Buat README awal project SIMHPSB | documentation | dzikri15 | High | Sprint 1 | ✅ Done |
| #3 | Upload Component & Deployment Diagram | diagram | dzikri15 | Medium | Sprint 1 | ✅ Done |
| #4 | Upload Sequence Diagram Login & Stok Alert | diagram | dzikri15 | Medium | Sprint 1 | ✅ Done |
| #5 | Hapus file .DS_Store dari folder Diagram | setup | dzikri15 | Low | Sprint 1 | ✅ Done |
| #6 | Gabungkan folder Diagram-2 ke folder Diagram | setup | dzikri15 | Low | Sprint 1 | ✅ Done |
| #7 | Tambah .gitignore untuk ignore .DS_Store & .env | setup | dzikri15 | Medium | Sprint 1 | ✅ Done |

---

### 📊 Diagram & UML

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #8 | Buat Class Diagram SIMHPSB | diagram | difa | High | Sprint 1 | ✅ Done |
| #9 | Buat ERD SIMHPSB | diagram | devina | High | Sprint 1 | ✅ Done |
| #10 | Buat Business Process Diagram (BPD) | diagram | alamsyah | High | Sprint 1 | ✅ Done |
| #11 | Buat Use Case Diagram | diagram | alamsyah | High | Sprint 1 | ✅ Done |
| #12 | Buat Activity Diagram | diagram | alamsyah | Medium | Sprint 1 | ✅ Done |
| #13 | Validasi dan finalisasi semua diagram | diagram | difa | Medium | Sprint 2 | Todo |

---

### 🖥️ Frontend Web — Laravel Blade (Fahri)

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #14 | Setup folder & struktur project pangan_web | setup | fahri | High | Sprint 1 | ✅ Done |
| #15 | Buat halaman login & register web | frontend | fahri | High | Sprint 1 | ✅ Done |
| #16 | Buat halaman admin dashboard web | frontend | fahri | High | Sprint 1 | ✅ Done |
| #17 | Buat halaman manajemen petani & lahan web | frontend | fahri | High | Sprint 1 | ✅ Done |
| #18 | Buat halaman pencatatan & riwayat panen web | frontend | fahri | High | Sprint 1 | ✅ Done |
| #19 | Buat halaman monitoring stok gudang web | frontend | fahri | High | Sprint 1 | ✅ Done |
| #20 | Buat halaman manajemen harga & HPP web | frontend | fahri | Medium | Sprint 1 | ✅ Done |
| #21 | Buat halaman alert stok minimum web | frontend | fahri | Medium | Sprint 1 | ✅ Done |
| #22 | Buat halaman laporan export PDF/Excel web | frontend | fahri | Medium | Sprint 1 | ✅ Done |

---

### 📱 Mobile Flutter (Fahri)

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #23 | Upload folder pangan_mobile ke repo | setup | fahri | High | Sprint 1 | ✅ Done |
| #24 | Buat UI login & dashboard Flutter (HTML) | mobile | fahri | High | Sprint 1 | ✅ Done |
| #25 | Buat UI petani, lahan, panen Flutter (HTML) | mobile | fahri | High | Sprint 1 | ✅ Done |
| #26 | Buat UI stok, alert, laporan Flutter (HTML) | mobile | fahri | Medium | Sprint 1 | ✅ Done |
| #27 | Setup project Flutter dart (struktur folder & pubspec.yaml) | mobile | fahri | High | Sprint 2 | In Progress |
| #28 | Konversi halaman login HTML ke Flutter dart | mobile | fahri | High | Sprint 2 | Todo |
| #29 | Konversi halaman dashboard HTML ke Flutter dart | mobile | fahri | High | Sprint 2 | Todo |
| #30 | Konversi halaman petani & lahan HTML ke Flutter dart | mobile | fahri | High | Sprint 2 | Todo |
| #31 | Konversi halaman panen HTML ke Flutter dart | mobile | fahri | High | Sprint 2 | Todo |
| #32 | Konversi halaman stok & alert HTML ke Flutter dart | mobile | fahri | Medium | Sprint 2 | Todo |
| #33 | Konversi halaman laporan HTML ke Flutter dart | mobile | fahri | Medium | Sprint 2 | Todo |
| #34 | Setup bottom navigation bar & routing antar screen | mobile | fahri | Medium | Sprint 2 | Todo |
| #35 | Buat model dart (User, Petani, Lahan, Panen, StokBeras) | mobile | fahri | High | Sprint 3 | Todo |
| #36 | Implementasi JWT auth Flutter (login, logout, simpan token) | mobile | fahri | High | Sprint 3 | Todo |
| #37 | Integrasi Flutter ke API Auth Laravel | mobile | fahri | High | Sprint 3 | Todo |
| #38 | Integrasi Flutter ke API petani & lahan | mobile | fahri | High | Sprint 3 | Todo |
| #39 | Integrasi Flutter ke API panen & stok | mobile | fahri | High | Sprint 3 | Todo |
| #40 | Integrasi Flutter ke API alert & laporan | mobile | fahri | Medium | Sprint 3 | Todo |
| #41 | Handling error & token expired (auto redirect login) | mobile | fahri | Medium | Sprint 3 | Todo |

---

### 🗄️ Database & Migration (Dzikri)

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #42 | Buat migrasi tabel users | database | dzikri15 | High | Sprint 2 | ✅ Done |
| #43 | Buat migrasi tabel petani dan lahan | database | dzikri15 | High | Sprint 2 | ✅ Done |
| #44 | Buat migrasi tabel panen | database | dzikri15 | High | Sprint 2 | ✅ Done |
| #45 | Buat migrasi tabel stok_beras dan gudang | database | dzikri15 | High | Sprint 2 | ✅ Done |
| #46 | Buat migrasi tabel harga, alert, distribusi | database | dzikri15 | High | Sprint 2 | ✅ Done |
| #47 | Buat Model (Petani, Lahan, Panen, Stok, Harga, Alert) | database | dzikri15 | High | Sprint 2 | ✅ Done |
| #48 | Buat DatabaseSeeder untuk data dummy | database | dzikri15 | Medium | Sprint 2 | Todo |
| #91 | Buat RoleAndPermissionSeeder untuk data user dan role | database | dzikri15 | Medium | Sprint 2 | Todo |
| #93 | Buat konfigurasi harga & migrasi tabel konfigurasi harga | database | dzikri15 | High | Sprint 3 | Todo |

---

### 🔐 Backend Auth & API (Dzikri)

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #49 | Setup Laravel 12 environment & konfigurasi | backend | dzikri15 | High | Sprint 2 | ✅ Done |
| #50 | Implementasi JWT Auth API (login, register, logout) | backend | dzikri15 | High | Sprint 2 | ✅ Done |
| #51 | Buat REST API endpoint data petani & lahan | backend | dzikri15 | High | Sprint 2 | In Progress |
| #52 | Buat REST API endpoint pencatatan panen + konversi gabah | backend | dzikri15 | High | Sprint 3 | Todo |
| #90 | Buat REST API endpoint monitoring stok gudang | backend | dzikri15 | High | Sprint 3 | Todo |
| #54 | Buat REST API endpoint manajemen harga & kalkulasi HPP | backend | dzikri15 | Medium | Sprint 3 | Done |
| #55 | Buat REST API endpoint alert stok minimum | backend | dzikri15 | Medium | Sprint 3 | Todo |
| #56 | Buat REST API endpoint distribusi | backend | dzikri15 | Medium | Sprint 3 | Todo |
| #57 | Registrasi middleware JWT di bootstrap/app.php | backend | dzikri15 | High | Sprint 2 | Todo |
| #58 | Konfigurasi CORS untuk Flutter & web | backend | dzikri15 | High | Sprint 2 | Todo |
| #92 | Buat API Controllers baru untuk endpoint backend | backend | dzikri15 | High | Sprint 3 | Todo |

---

### ⚙️ DevOps & Infrastructure (Dzikri)

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #59 | Buat docker-compose.yml (Laravel + MySQL + Redis + Nginx) | devops | dzikri15 | High | Sprint 3 | Todo |
| #60 | Buat Dockerfile untuk aplikasi Laravel | devops | dzikri15 | High | Sprint 3 | Todo |
| #61 | Konfigurasi Redis cache dan queue | devops | dzikri15 | Medium | Sprint 3 | Todo |
| #62 | Update README lengkap + screenshot + cara deploy | documentation | dzikri15 | Medium | Sprint 5 | Todo |
| #63 | Buat BACKEND.md dokumentasi API lengkap | documentation | dzikri15 | Medium | Sprint 3 | ✅ Done |

---

### 🧪 QA & Testing Web (Alamsyah & Difa)

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #64 | Buat test case fitur login & register web | testing | alamsyah | High | Sprint 4 | Todo |
| #65 | Buat test case input data panen web | testing | alamsyah | High | Sprint 4 | Todo |
| #66 | Buat test case monitoring stok gudang web | testing | alamsyah | Medium | Sprint 4 | Todo |
| #67 | Buat test case manajemen petani & lahan web | testing | difa | Medium | Sprint 4 | Todo |
| #68 | Buat test case halaman harga & HPP web | testing | difa | Medium | Sprint 4 | Todo |
| #69 | Buat test case alert stok & distribusi web | testing | difa | Low | Sprint 4 | Todo |
| #70 | Bug fixing hasil QA web | testing | dzikri15 | High | Sprint 4 | Todo |
| #71 | Verifikasi semua fitur web sebelum demo | testing | alamsyah | High | Sprint 4 | Todo |

---

### 🧪 QA & Testing Mobile (Devina & Agusta)

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #72 | Buat test case fitur login & register mobile | testing | devina | High | Sprint 4 | Todo |
| #73 | Buat test case input data panen mobile | testing | devina | High | Sprint 4 | Todo |
| #74 | Buat test case monitoring stok mobile | testing | devina | Medium | Sprint 4 | Todo |
| #75 | Buat test case manajemen petani & lahan mobile | testing | agusta | Medium | Sprint 4 | Todo |
| #76 | Buat test case alert stok mobile | testing | agusta | Low | Sprint 4 | Todo |
| #77 | Testing UI/UX & kompatibilitas device Android | testing | agusta | Medium | Sprint 4 | Todo |
| #78 | Bug fixing hasil QA mobile | testing | fahri | High | Sprint 4 | Todo |
| #79 | Verifikasi semua fitur mobile sebelum demo | testing | devina | High | Sprint 4 | Todo |

---

### 📖 Manual Book & Dokumentasi Akhir

| No | Judul Issue | Label | PIC | Priority | Sprint | Status |
|----|-------------|-------|-----|----------|--------|--------|
| #80 | Buat manual book web — panduan login & dashboard | documentation | alamsyah | High | Sprint 5 | Todo |
| #81 | Buat manual book web — panduan input panen & stok | documentation | alamsyah | High | Sprint 5 | Todo |
| #82 | Buat manual book web — panduan manajemen harga & laporan | documentation | difa | Medium | Sprint 5 | Todo |
| #83 | Buat manual book web — panduan manajemen petani & lahan | documentation | difa | Medium | Sprint 5 | Todo |
| #84 | Buat manual book mobile — panduan login & dashboard | documentation | devina | High | Sprint 5 | Todo |
| #85 | Buat manual book mobile — panduan input panen & stok | documentation | devina | High | Sprint 5 | Todo |
| #86 | Buat manual book mobile — panduan manajemen petani & lahan | documentation | agusta | Medium | Sprint 5 | Todo |
| #87 | Buat manual book mobile — panduan alert & notifikasi | documentation | agusta | Medium | Sprint 5 | Todo |
| #88 | Buat Laporan Akhir bab 1-2 (latar belakang & perancangan) | documentation | devina | High | Sprint 5 | Todo |
| #89 | Buat Laporan Akhir bab 3-4 (implementasi & pengujian) | documentation | alamsyah | High | Sprint 5 | Todo |
| #90 | Buat video presentasi YouTube | documentation | semua | High | Sprint 5 | Todo |

---

## 📊 Kanban Board

| Backlog | Ready | In Progress | In Review | Done |
|---------|-------|-------------|-----------|------|
| #13 Validasi diagram | #27 Setup Flutter dart | #51 API petani & lahan | | ✅ #1 Upload SRS |
| #35 Model dart | #28 Konversi login dart | #57 Middleware JWT | | ✅ #2 README |
| #36 JWT auth Flutter | #29 Konversi dashboard dart | #58 Konfigurasi CORS | | ✅ #3 Component Diagram |
| #37 Integrasi API auth | #48 DatabaseSeeder | | | ✅ #4 Sequence Diagram |
| #38 Integrasi API petani | | | | ✅ #5 Hapus .DS_Store |
| #39 Integrasi API panen | | | | ✅ #6 Gabung Diagram |
| #40 Integrasi API alert | | | | ✅ #7 .gitignore |
| #41 Handling error | | | | ✅ #8 Class Diagram |
| #52 API panen | | | | ✅ #9 ERD |
| #53 API stok | | | | ✅ #10 BPD |
| #54 API harga | | | | ✅ #11 Use Case |
| #55 API alert | | | | ✅ #12 Activity Diagram |
| #56 API distribusi | | | | ✅ #14-#26 UI Web & Mobile |
| #59 Docker compose | | | | ✅ #42-#47 Migration & Model |
| #60 Dockerfile | | | | ✅ #49 Setup Laravel |
| #61 Redis | | | | ✅ #50 JWT Auth |
| #64-#79 QA | | | | ✅ #63 BACKEND.md |
| #80-#90 Docs | | | | |

---

## 📅 Sprint Detail

### Sprint 1 — 3 Mei s/d 17 Mei 2026 ✅ SELESAI
**Fokus:** Setup repo, diagram, UI web & mobile HTML

| Issue | Judul | PIC |
|-------|-------|-----|
| #1-#7 | Setup, README, Diagram dzikri | dzikri15 |
| #8 | Class Diagram | difa |
| #9 | ERD | devina |
| #10-#12 | BPD, Use Case, Activity | alamsyah |
| #14-#22 | UI Web lengkap | fahri |
| #23-#26 | UI Mobile HTML | fahri |

---

### Sprint 2 — 18 Mei s/d 24 Mei 2026 🔄 BERJALAN
**Fokus:** Backend database + auth + konversi Flutter HTML → Dart

| Issue | Judul | PIC |
|-------|-------|-----|
| #42-#48 | Migration, Model, Seeder | dzikri15 |
| #49-#51 | Setup Laravel, JWT, API petani | dzikri15 |
| #57-#58 | Middleware JWT, CORS | dzikri15 |
| #27-#34 | Setup Flutter dart + konversi semua screen | fahri |
| #13 | Validasi diagram | difa |

---

### Sprint 3 — 25 Mei s/d 31 Mei 2026
**Fokus:** Backend API lengkap + integrasi Flutter

| Issue | Judul | PIC |
|-------|-------|-----|
| #52-#56 | API panen, stok, harga, alert, distribusi | dzikri15 |
| #59-#61 | Docker, Redis | dzikri15 |
| #35-#41 | Model dart, JWT Flutter, integrasi API | fahri |

---

### Sprint 4 — 1 Jun s/d 7 Jun 2026
**Fokus:** QA & testing web + mobile (digabung)

| Issue | Judul | PIC |
|-------|-------|-----|
| #64-#69 | Test case semua fitur web | alamsyah, difa |
| #70-#71 | Bug fixing & verifikasi web | dzikri15, alamsyah |
| #72-#77 | Test case semua fitur mobile | devina, agusta |
| #78-#79 | Bug fixing & verifikasi mobile | fahri, devina |

---

### Sprint 5 — 8 Jun s/d 14 Jun 2026
**Fokus:** Manual book, laporan akhir, video presentasi

| Issue | Judul | PIC |
|-------|-------|-----|
| #80-#83 | Manual book web | alamsyah, difa |
| #84-#87 | Manual book mobile | devina, agusta |
| #88-#89 | Laporan akhir | devina, alamsyah |
| #62 | Update README final | dzikri15 |
| #90 | Video presentasi YouTube | semua |

---

## 📈 Ringkasan Issue per Anggota

| Anggota | Jumlah Issue | Sprint |
|---------|-------------|--------|
| dzikri15 | 33 issue | 1-6 |
| fahri | 28 issue | 1-3, 5 |
| alamsyah | 10 issue | 1, 4, 6 |
| difa | 8 issue | 1, 4, 6 |
| devina | 8 issue | 1, 5, 6 |
| agusta | 7 issue | 5-6 |
| **Total** | **94 issue** | |

---

*SIMHPSB — Kelompok 4 | Rekayasa Sistem Informasi A1 | UKRI 2026*
