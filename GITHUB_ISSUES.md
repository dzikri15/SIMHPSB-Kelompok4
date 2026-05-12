# 📋 GitHub Issues — SIMHPSB Kelompok 4

Daftar 15+ issue yang sesuai dengan repo dan roadmap pengembangan proyek.

---

## ✅ Cleanup & Setup

| No | Judul Issue | Label | PIC | Status |
|---|---|---|---|---|
| #1 | **Gabungkan folder Diagram-2 ke folder Diagram** | cleanup | dzikri15 | Backlog |
| #2 | **Hapus file `.DS_Store` dan perbaiki `.gitignore`** | cleanup | dzikri15 | Backlog |
| #3 | **Update README — sesuaikan struktur repo dan path** | documentation | dzikri15 | Backlog |

---

## 🗄️ Database & Migration

| No | Judul Issue | Label | PIC | Status |
|---|---|---|---|---|
| #4 | **Buat migrasi tabel `petani` dan `lahan` di `pangan_web`** | backend | dzikri15 | Backlog |
| #5 | **Buat migrasi tabel `panen` di `pangan_web`** | backend | dzikri15 | Backlog |
| #6 | **Buat migrasi tabel `stok_beras` dan `gudang` di `pangan_web`** | backend | dzikri15 | Backlog |
| #7 | **Buat migrasi tabel `harga`, `alert`, dan `distribusi` di `pangan_web`** | backend | dzikri15 | Backlog |

---

## 🔐 Backend — Authentication & API

| No | Judul Issue | Label | PIC | Status |
|---|---|---|---|---|
| #8 | **Implementasi JWT Auth API (login, register, logout)** | backend | dzikri15 | Backlog |
| #9 | **Buat Model `Petani`, `Lahan`, `Panen`, `Stok`, `Harga`, `Alert`** | backend | dzikri15 | Backlog |
| #10 | **Buat REST API endpoint untuk data petani dan lahan** | backend | dzikri15 | Backlog |
| #11 | **Buat REST API endpoint untuk pencatatan panen + konversi gabah→beras** | backend | dzikri15 | Backlog |
| #12 | **Buat REST API endpoint untuk monitoring stok gudang** | backend | dzikri15 | Backlog |
| #13 | **Buat REST API endpoint untuk manajemen harga dan kalkulasi HPP/margin** | backend | dzikri15 | Backlog |

---

## 📱 Mobile App

| No | Judul Issue | Label | PIC | Status |
|---|---|---|---|---|
| #14 | **Setup project Flutter di `pangan_mobile` dan integrasi Dio + JWT** | mobile | fakhry | Backlog |
| #15 | **Buat UI login & register Flutter** | mobile | fakhry | Backlog |
| #16 | **Buat UI dashboard dan monitoring stok di Flutter** | mobile | fakhry | Backlog |
| #17 | **Buat UI form pencatatan panen di Flutter** | mobile | fakhry | Backlog |
| #18 | **Integrasi Flutter ke API auth, petani, panen, dan stok** | mobile | fakhry | Backlog |
| #18a | **Testing UI/UX mobile dan kompatibilitas device** | testing | agusta | Backlog |

---

## 🖥️ Frontend Web (pangan_web)

| No | Judul Issue | Label | PIC | Status |
|---|---|---|---|---|
| #19 | **Buat halaman admin dashboard** | frontend | fakhry | Backlog |
| #20 | **Buat halaman manajemen petani dan lahan** | frontend | fakhry | Backlog |
| #21 | **Buat halaman pencatatan dan riwayat panen** | frontend | fakhry | Backlog |
| #22 | **Buat halaman monitoring stok gudang** | frontend | fakhry | Backlog |
| #23 | **Buat halaman manajemen harga dan konfigurasi HPP** | frontend | fakhry | Backlog |
| #24 | **Buat halaman alert stok dan konfigurasi batas minimum** | frontend | fakhry | Backlog |
| #25 | **Buat halaman laporan panen, stok, dan margin (export PDF/Excel)** | frontend | fakhry | Backlog |

---

## 🔧 DevOps & Infrastructure

| No | Judul Issue | Label | PIC | Status |
|---|---|---|---|---|
| #26 | **Buat `docker-compose.yml` untuk Laravel + MySQL + Redis + Nginx** | devops | dzikri15 | Backlog |
| #27 | **Buat `Dockerfile` untuk aplikasi Laravel** | devops | dzikri15 | Backlog |
| #28 | **Konfigurasi Redis cache dan queue** | devops | dzikri15 | Backlog |

---

## 📚 Documentation & Testing

| No | Judul Issue | Label | PIC | Status |
|---|---|---|---|---|
| #29 | **Lengkapi dokumentasi API dengan request/response contoh** | documentation | paiton | Backlog |
| #30 | **Buat dokumentasi setup lokal dan deployment** | documentation | paiton | Backlog |
| #30a | **Buat dokumentasi user guide untuk admin (manual penggunaan)** | documentation | paiton | Backlog |
| #30b | **Buat dokumentasi user guide untuk mobile app** | documentation | paiton | Backlog |
| #31 | **Tambahkan unit test untuk Model (User, Petani, Panen, Stok)** | testing | agusta | Backlog |
| #31a | **Tambahkan feature test untuk API endpoint backend** | testing | agusta | Backlog |
| #31b | **Tambahkan integration test untuk workflow lengkap (auth → panen → stok)** | testing | agusta | Backlog |
| #32 | **Tambahkan screenshot dan demo video ke README** | documentation | difa | Backlog |

---

## 📊 Diagram & UML

| No | Judul Issue | Label | PIC | Status |
|---|---|---|---|---|
| #33 | **Validasi dan finalisasi Class Diagram** | diagram | difa | Backlog |
| #34 | **Validasi dan finalisasi ERD** | diagram | devina | Backlog |
| #35 | **Validasi dan finalisasi Sequence Diagram (Login & Stok Alert)** | diagram | alamsyah | Backlog |
| #36 | **Validasi dan finalisasi Use Case, Activity, Deployment Diagram** | diagram | alamsyah | Backlog |

---

## 🏆 Final QA & Release

| No | Judul Issue | Label | PIC | Status |
|---|---|---|---|---|
| #37 | **Code review dan refactoring backend API** | review | agusta | Backlog |
| #37a | **Code review dan testing frontend web** | review | agusta | Backlog |
| #37b | **Code review dan testing mobile app** | review | agusta | Backlog |
| #38 | **Testing integrasi end-to-end (web + mobile)** | testing | agusta | Backlog |
| #38a | **Performance testing dan optimization** | testing | agusta | Backlog |
| #39 | **Persiapan dokumentasi final dan deployment staging** | documentation | paiton | Backlog |
| #39a | **Buat checklist pre-deployment dan release notes** | documentation | paiton | Backlog |
| #39b | **Buat SOP (Standard Operating Procedure) untuk admin dan petugas** | documentation | paiton | Backlog |

---

## 📊 Breakdown Issue Terrevisi

| Kategori | Jumlah | Detail |
|---|---|---|
| Cleanup & Setup | 3 | Merge diagram, hapus `.DS_Store`, update README |
| Database & Migration | 4 | Migrasi petani, lahan, panen, stok, harga, alert |
| Backend Auth & API | 6 | JWT, model, endpoint petani, panen, stok, harga |
| Mobile App | 6 | Setup Flutter, UI login, dashboard, form panen, integrasi API, testing |
| Frontend Web | 7 | Dashboard, petani, panen, stok, harga, alert, laporan |
| DevOps & Infrastructure | 3 | Docker Compose, Dockerfile, Redis |
| Documentation & Testing | 8 | API doc, setup guide, unit test, screenshot, user guide (paiton & agusta) |
| Diagram & UML | 4 | Validasi Class, ERD, Sequence, Use Case |
| Final QA & Release | 8 | Code review, end-to-end testing, deployment, SOP (agusta & paiton) |
| **Total** | **49** | **Roadmap lengkap dengan distribusi tim seimbang** |

---

## 🎯 Label yang digunakan

- `backend` — Pengembangan API, Model, Migration, Logic
- `frontend` — UI Web Blade, CSS, JavaScript
- `mobile` — Pengembangan Flutter, UI Mobile
- `documentation` — README, API Doc, Setup Guide
- `diagram` — UML, ERD, Design
- `devops` — Docker, Infrastructure
- `testing` — Unit/Feature Test, QA
- `cleanup` — Organisasi repo, .gitignore
- `review` — Code review, Validation

---

## 🔍 PIC (Person In Charge) — Distribusi Tugas

- **dzikri15** — Muhammad Dzikri Sagara 
  - Tugas: Backend API, Migration, DevOps (Docker/Redis), Project Management
  - Issue: #1, #3, #4, #5, #6, #7, #8, #9, #10, #11, #12, #13, #26, #27, #28
  - **Total: 15 issue**

- **fakhry** — Fakhry Ahmad Fauzan 
  - Tugas: Frontend Web, Mobile UI Design
  - Issue: #14, #15, #16, #17, #18, #19, #20, #21, #22, #23, #24, #25
  - **Total: 12 issue**

- **agusta** — Agusta Firman Firdaus 
  - Tugas: QA, Testing, Code Review, Performance
  - Issue: #18a, #31, #31a, #31b, #37, #37a, #37b, #38, #38a
  - **Total: 9 issue**

- **paiton** — Paiton Wenda 
  - Tugas: Documentation, User Guide, SOP, Release Management
  - Issue: #29, #30, #30a, #30b, #39, #39a, #39b
  - **Total: 7 issue**

- **difa** — Difa Nisa Lutfiah 
  - Tugas: Diagram validation, screenshot, analisis
  - Issue: #32, #33
  - **Total: 2 issue**

- **devina** — Devina Ayuliani 
  - Tugas: ERD dan database design validation
  - Issue: #34
  - **Total: 1 issue**

- **alamsyah** — Muhammad Alamsyah 
  - Tugas: UML Diagram (Use Case, Activity, Sequence, Deployment)
  - Issue: #35, #36
  - **Total: 2 issue**

---

**Catatan:** 
- Issue ini bisa langsung di-input ke GitHub Projects
- Status awal semua issue adalah `Backlog` dan akan dipindahkan ke `To Do` sesuai prioritas sprint
- Setiap issue bisa memiliki sub-task atau linked PR
