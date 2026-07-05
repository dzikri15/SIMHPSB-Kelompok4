# Test Suite Playwright — SIMHPSB

Test case frontend end-to-end untuk aplikasi SIMHPSB (Sistem Informasi
Monitoring Hasil Panen & Stok Beras), memakai pola **Page Object Model
(POM)** dan ditulis dalam TypeScript.

## Struktur folder

```
playwright/
├── auth.setup.ts          # Login 3 role & simpan session (dijalankan sekali di awal)
├── fixtures/
│   ├── test-data.ts        # Kredensial & data dummy terpusat
│   ├── auth.fixtures.ts    # Custom fixture: adminPage, petugasPage, petaniPage
│   └── dummy-bukti.png     # File gambar dummy untuk test upload
├── pages/                  # Page Object — satu class per halaman/komponen
│   ├── LoginPage.ts
│   ├── BaseAdminPage.ts    # Dipakai/di-extend semua halaman admin (sidebar, modal, dark mode)
│   ├── DashboardPage.ts
│   ├── DataPetaniPage.ts
│   ├── PanenPage.ts
│   ├── StokPage.ts
│   ├── HargaPage.ts
│   ├── AlertPage.ts
│   ├── PenggunaPage.ts
│   ├── LaporanPage.ts
│   ├── PengaturanPage.ts
│   ├── TujuanDistribusiPage.ts
│   └── PetaniDashboardPage.ts
├── tests/                  # File spec, satu per modul/halaman
│   ├── 01-auth.spec.ts
│   ├── 02-rbac.spec.ts
│   ├── 03-dashboard.spec.ts
│   ├── 04-data-petani.spec.ts
│   ├── 05-panen.spec.ts
│   ├── 06-stok.spec.ts
│   ├── 07-harga.spec.ts
│   ├── 08-alert.spec.ts
│   ├── 09-pengguna.spec.ts
│   ├── 10-laporan.spec.ts
│   ├── 11-pengaturan.spec.ts
│   ├── 12-tujuan-distribusi.spec.ts
│   └── 13-petani-dashboard.spec.ts
└── .auth/                  # storageState hasil login (dibuat otomatis, jangan di-commit)
```

## Cara menjalankan

1. **Jalankan server Laravel-nya dulu**, di terminal terpisah:
   ```bash
   php artisan serve
   ```
   (default `http://localhost:8000`; kalau beda, set `BASE_URL` — lihat langkah 3)

2. **Pastikan database dalam kondisi bersih & ter-seed**, supaya kredensial
   akun bawaan (admin/petugas/petani) tersedia:
   ```bash
   php artisan migrate:fresh --seed
   ```
   Ini PENTING — sebagian besar test bergantung pada 3 akun bawaan dari
   `DatabaseSeeder` dan data `petani`/`tujuan_distribusi` dari seeder lain.

3. **Install browser Playwright** (sekali saja) lalu jalankan test:
   ```bash
   npx playwright install
   npx playwright test
   ```
   Kalau server Laravel-nya jalan di alamat lain:
   ```bash
   BASE_URL=http://127.0.0.1:8080 npx playwright test
   ```

4. **Lihat laporan hasil test** (setelah selesai jalan):
   ```bash
   npx playwright show-report
   ```

5. Untuk debug satu file test saja, dengan browser kelihatan:
   ```bash
   npx playwright test tests/04-data-petani.spec.ts --headed --project=chromium
   ```

## Hal-hal penting yang perlu diketahui

- **Bukan "record & playback".** Semua selector ditulis manual berdasar
  audit langsung ke source code Blade & Controller-nya, supaya tesnya
  mencerminkan perilaku ASLI aplikasi, bukan asumsi.
- **Beberapa test mendokumentasikan temuan QA nyata** (bukan sekadar
  memverifikasi fitur "harus lolos"), misalnya:
  - `13-petani-dashboard.spec.ts`: akun seed `petani@simhpsb.com` bikin
    dashboard-nya 404 karena `petani_id` tidak terhubung.
  - `02-rbac.spec.ts`: role **petugas** ternyata masih bisa membuka
    `/admin/petani` lewat URL langsung walau menu-nya disembunyikan di
    sidebar — middleware route-nya lebih longgar daripada tampilan UI.
  - `11-pengaturan.spec.ts`: form Pengaturan menampilkan pesan sukses,
    tapi `PengaturanController@update` tidak benar-benar menyimpan apa
    pun ke database (stub / belum diimplementasikan).
  - `06-stok.spec.ts` & `08-alert.spec.ts`: menguji logika kondisional
    JS yang cukup rumit (toggle field berdasar kombinasi jenis+komoditas)
    dan aturan bisnis "tidak bisa menandai alert selesai kalau stok
    masih di bawah batas minimum".

  Kalau ini dipakai untuk laporan QA, poin-poin di atas bisa langsung
  diangkat jadi temuan — cukup jalankan test-nya dan lampirkan hasilnya.

- **Test tidak melakukan reset database sendiri.** Setiap data yang
  dibuat (petani, pengguna, tujuan distribusi, dll.) memakai nama/email
  unik berbasis timestamp (lihat `fixtures/test-data.ts`) supaya aman
  dari bentrok `unique` constraint, tapi datanya akan terus menumpuk di
  database kalau dijalankan berulang-ulang. Disarankan `migrate:fresh
  --seed` secara berkala, terutama sebelum demo/laporan resmi.
- **Modal di aplikasi ini pakai `class="open"` + CSS opacity**, bukan
  `display:none`/`block`. Karena itu jangan pernah pakai
  `expect(modal).toBeVisible()` untuk memastikan modal tertutup — pakai
  `expectModalOpen()` / `expectModalClosed()` dari `BaseAdminPage`, yang
  sudah menangani ini dengan benar.
- **Beberapa konfirmasi memakai `window.confirm()` bawaan browser**
  (hapus riwayat panen, hapus konfigurasi harga, tandai alert), sebagian
  lain memakai modal kustom (hapus petani, hapus pengguna, hapus tujuan
  distribusi). Page Object masing-masing sudah menangani perbedaan ini.

## Menambah test baru

Ikuti pola yang sudah ada:
1. Kalau menyentuh halaman baru, buat dulu Page Object-nya di `pages/`
   dengan meng-extend `BaseAdminPage` (kecuali halaman login).
2. Pakai `import { test, expect } from '../fixtures/auth.fixtures'` dan
   fixture `adminPage`/`petugasPage`/`petaniPage` sesuai role yang
   dibutuhkan — jangan login manual lewat UI di tiap test (lambat).
3. Simpan file spec baru di `tests/` dengan prefix angka sesuai urutan
   modul di sidebar.
