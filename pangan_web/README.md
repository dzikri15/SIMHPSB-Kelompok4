# Playwright E2E Test Suite — SIMHP (SIMHPSB)

Suite pengujian otomatis (End-to-End) berbasis **Playwright + TypeScript**
untuk project **SIMHP** (Sistem Informasi Monitoring Hasil Panen), dibuat
berdasarkan analisis menyeluruh terhadap:

1. Kode sumber project (`pangan_web.zip`)
2. Dokumentasi hasil pengujian manual (`testing.zip`) — 8 file, mencakup
   332 test case manual di 7 modul: Login, Data Petani & Lahan, Pencatatan
   Panen, Stok Gudang, Manajemen Harga & HPP, Alert Stok & Distribusi, dan
   API (Postman).

> **Baca bagian ["Temuan Perbedaan"](#temuan-perbedaan-dokumentasi-vs-kode-sumber)
> di bawah SEBELUM menjalankan test.** Ini adalah bagian terpenting dari
> dokumen ini secara akademik: kode sumber saat ini **tidak 100% sama**
> dengan skenario yang didokumentasikan di file `.xlsx` Anda.

---

## 1. Struktur File

```
playwright.config.ts          # Konfigurasi utama (baseURL, browser, dsb.)
playwright/
├── assets/
│   └── bukti-test.jpg        # Gambar dummy untuk upload foto bukti
├── fixtures/
│   ├── auth.ts                # Fixture login otomatis per role (admin/petugas/petani)
│   └── test-data.ts           # Kredensial & data uji terpusat
├── pages/                     # Page Object Model (1 class per modul)
│   ├── LoginPage.ts
│   ├── PetaniPage.ts
│   ├── PanenPage.ts
│   ├── StokGudangPage.ts
│   ├── HargaPage.ts
│   └── AlertPage.ts
└── tests/                     # 110 test, 7 file, 1 file per modul
    ├── 01-login.spec.ts
    ├── 02-petani-lahan.spec.ts
    ├── 03-panen.spec.ts
    ├── 04-stok-gudang.spec.ts
    ├── 05-harga-hpp.spec.ts
    ├── 06-alert-distribusi.spec.ts
    └── 07-api.spec.ts
```

**Cara pasang ke project Laravel Anda:** salin `playwright.config.ts` dan
folder `playwright/` ke root project `pangan_web/` (timpa file
`playwright/example.spec.ts` bawaan Playwright init — sudah tidak
diperlukan). Project Anda **sudah memiliki** `@playwright/test` di
`package.json`, jadi tidak perlu instalasi tambahan selain:

```bash
npm install
npx playwright install        # download browser Chromium
```

## 2. Menjalankan Test

```bash
# 1. Siapkan database (WAJIB — banyak test bergantung pada akun & data seed)
php artisan migrate:fresh --seed

# 2. Nyalakan server Laravel di terminal terpisah
php artisan serve

# 3. Jalankan seluruh test
npx playwright test

# Jalankan 1 modul saja, mis. Login:
npx playwright test tests/01-login.spec.ts

# Mode UI interaktif (sangat direkomendasikan untuk belajar/debug):
npx playwright test --ui

# Lihat laporan HTML setelah run:
npx playwright show-report
```

Jika Laravel Anda tidak berjalan di `http://localhost:8000`, override lewat:
```bash
BASE_URL=http://127.0.0.1:8001 npx playwright test
```

### Kenapa `workers: 1` (sekuensial, bukan paralel)?

Modul Stok Gudang & Alert berbagi **state global** di database (saldo stok
berjalan, satu baris `alert_configurations`). Menjalankan test yang saling
memengaruhi state ini secara paralel berisiko flaky. Konfigurasi default
suite ini sengaja sekuensial demi hasil yang stabil untuk kebutuhan
akademik/demo — detail ada di komentar `playwright.config.ts`.

## 3. Kredensial yang Dipakai

Diambil dari `database/seeders/DatabaseSeeder.php` — pastikan sudah
menjalankan `php artisan migrate:fresh --seed`:

| Role     | Email                  | Password   |
|----------|-------------------------|-----------|
| Admin    | admin@simhpsb.com       | password  |
| Petugas  | petugas@simhpsb.com     | password  |
| Petani   | petani@simhpsb.com      | password  |

Petani seed tambahan dengan data lahan lengkap: **Pak Budi**
(petani1@simhpsb.com) dan **Bu Sari** (petani2@simhpsb.com) — dipakai di
test Panen & Stok Gudang.

## 4. Pemetaan Test Case ke File

| Dokumen Manual (.xlsx)              | File Playwright                     | Jml Test |
|--------------------------------------|--------------------------------------|:--------:|
| Test Case Login Page.xlsx            | `tests/01-login.spec.ts`             | 38 |
| TC_Petani_Lahan.xlsx                 | `tests/02-petani-lahan.spec.ts`      | 12 |
| Test Case Input Data Panen.xlsx      | `tests/03-panen.spec.ts`             | 10 |
| Test Case Stok Gudang.xlsx           | `tests/04-stok-gudang.spec.ts`       | 15 |
| TC_Harga_HPP.xlsx                    | `tests/05-harga-hpp.spec.ts`         | 10 |
| TC_Alert_Stok_Distribusi.xlsx        | `tests/06-alert-distribusi.spec.ts`  | 10 |
| Test Case Postman.xlsx (TC-API)      | `tests/07-api.spec.ts`               | 15 |
| **Total** | | **110** |

Setiap test diberi komentar ID yang merujuk ke ID asli di dokumen `.xlsx`
Anda (mis. `TC-FP-004`, `TC-SG-FN-001`), ditambah label **"(disesuaikan)"**
atau **"(tambahan)"** bila skenario perlu diubah mengikuti kode sumber
nyata, atau ditambahkan sebagai temuan baru dari saya di luar dokumentasi
awal Anda.

Catatan jujur soal cakupan: 110 test ini adalah **subset representatif
berkualitas tinggi** dari 332 baris test case manual Anda — mencakup
semua kategori (UI, Positive, Negative, Edge Case, Security, Nav,
role-based access) di tiap modul, memakai selector yang diverifikasi
langsung dari kode sumber. ​Ini BUKAN transkripsi 1:1 dari 332 baris,
karena sebagian besar variasi di dokumen asli (terutama di modul Panen,
Harga, dan Petani) mengacu pada field yang **sudah tidak ada** di kode
saat ini (lihat bagian 5).

## 5. Temuan Perbedaan: Dokumentasi vs. Kode Sumber

Ini adalah bagian paling penting secara akademik. Saya membandingkan
setiap baris dokumentasi `.xlsx` terhadap `resources/views/**/*.blade.php`
dan `app/Http/Controllers/**/*.php` yang sesungguhnya, dan menemukan
project Anda **sudah berevolusi** sejak dokumentasi manual testing
ditulis. Ini WAJAR dalam siklus pengembangan software — dokumentasi dan
kode sering "diverge" jika tidak disinkronkan setiap ada perubahan fitur.
Ini adalah temuan riil dari analisis, sehingga bisa langsung dicantumkan
di laporan pengujian atau revisi dokumentasi Anda:

### 5.1 Modul Manajemen Harga & HPP — perbedaan PALING SIGNIFIKAN
- Field **"Ongkos Giling"** dan **"Rasio Konversi Gabah → Beras"** yang
  menjadi inti `TC_Harga_HPP.xlsx` **sudah tidak ada** di form maupun
  tabel. Form sekarang hanya: `harga_beli_gabah`, `harga_jual_beras`,
  `berlaku_mulai`, `is_active`.
- Sebagai gantinya ada **"Kalkulator Penghasilan"** sisi klien: Total =
  Harga × Berat (perkalian sederhana, bukan konversi gabah→beras).
- Ditemukan route mati `PATCH harga/{harga}/rasio` → `updateRasio()`
  yang **tidak punya method** di `HargaController` (akan fatal error bila
  pernah dipanggil) — jejak sisa dari fitur rasio konversi yang dulu
  pernah ada lalu dihapus sebagian.
- **Rekomendasi:** diskusikan dengan dosen pembimbing/tim apakah
  `TC_Harga_HPP.xlsx` perlu direvisi total mengikuti field yang ada
  sekarang, atau sebaliknya fitur rasio konversi perlu dikembalikan ke
  kode karena memang menjadi kebutuhan bisnis inti sistem informasi hasil
  panen (harga gabah tidak serta-merta sama dengan harga beras tanpa
  memperhitungkan rendemen/susut giling).

### 5.2 Modul Pencatatan Panen
- **Tidak ada** field "Rasio Konversi (%)". Kolom `konversi_beras` di
  database di-hardcode `0` saat insert.
- Field **"Foto Bukti Panen" kini WAJIB** (`required|image|mimes:jpg,jpeg,png|max:5120`),
  tidak disebut sama sekali di dokumentasi awal.
- Mencatat panen kini **otomatis membuat entri "Gabah Masuk"** di modul
  Stok Gudang (integrasi lintas modul) — perilaku baru yang belum
  terdokumentasi.
- Kolom tabel riwayat: *Petani, Hasil Gabah, Penghasilan (Rp), Foto,
  Musim, Tanggal, Aksi* — bukan "Beras Hasil" seperti di dokumen.
- Dropdown Petani adalah komponen pencarian custom (klik → cari → pilih),
  bukan `<select>` HTML biasa.

### 5.3 Modul Data Petani & Lahan
- Form "Tambah Petani" **tidak memiliki field NIK**. Kolom `nik` masih
  ada di skema database, tapi sudah tidak diekspos di form CRUD manapun
  yang saya temukan.
- Sebagai gantinya, form membutuhkan **Email + Password + Konfirmasi
  Password** — karena menambah petani = sekaligus membuat akun login
  (`PetaniController@store` membuat `Petani` **dan** `User` terkait
  dalam satu transaksi).
- Form dikirim lewat **AJAX (`fetch`)**, bukan POST form biasa. Kegagalan
  validasi server memunculkan `window.alert()` generik ("Gagal
  menyimpan data..."), bukan pesan validasi per-field inline seperti di
  modul lain.
- **Temuan tambahan di luar dugaan saya sendiri:** berdasarkan
  `routes/web.php`, middleware `role:admin,petugas` diterapkan di level
  GRUP TERLUAR `/admin/*`. Modul Petani, Panen, Stok Gudang, dan Alert
  **tidak** mendapat pembatasan tambahan yang lebih ketat — artinya role
  **petugas ternyata BISA mengakses & mengelola Data Petani**, bukan
  "khusus admin" seperti asumsi umum. Hanya modul Harga, Laporan,
  Pengguna, dan Pengaturan yang benar-benar dibatasi `role:admin` saja.

### 5.4 Halaman Login
- `<title>` sesungguhnya: **`Login – SIMHP`** (en-dash, "SIMHP"), bukan
  `Login - SIMHPSB` seperti disebut di `TC-API-002`/`TC-UI-002`.
- Placeholder field identifier: *"Masukkan email, nama pengguna, atau
  nama petani"* — bukan `admin@medinfo.com`.
- **Tidak ada** link "Lupa password?" yang disebut di `TC-ACC-001`.

### 5.5 Modul Stok Gudang & Alert — PALING SELARAS dengan dokumentasi
Dua modul ini terbukti paling konsisten dengan dokumentasi manual Anda
(struktur 8 kartu ringkasan, kolom tabel, alur status alert). Beberapa
catatan teknis kecil:
- Field "Tujuan Distribusi" diberi tanda bintang merah (wajib) secara
  visual, tapi **tidak** benar-benar `required` baik di HTML maupun
  validasi server (`nullable`) — kemungkinan bug UI kecil.
- Transaksi "keluar" **tidak diblokir** meski melebihi saldo saat ini;
  sistem hanya menampilkan peringatan visual, bukan validasi keras.
- Alert dibuat **otomatis oleh sistem** (bukan input manual) tiap kali
  halaman dimuat & stok di bawah batas minimum. Rute `AlertController@store`
  untuk membuat alert manual ada di controller tapi **tidak pernah
  didaftarkan** di `routes/web.php` (tidak bisa diakses dari UI).
- Transisi status "Selesai" **diblokir di server** jika stok saat ini
  masih di bawah `batas_minimum` yang tersimpan pada alert tsb (bukan
  dibaca ulang dari konfigurasi terbaru).

## 6. Metodologi & Referensi

Beberapa keputusan desain test di atas didasarkan pada sumber berikut,
bukan asumsi pribadi:

1. **Page Object Model (POM).** Struktur `pages/*.ts` terpisah dari
   `tests/*.ts` mengikuti pola resmi yang direkomendasikan dokumentasi
   Playwright sendiri, untuk memisahkan "cara berinteraksi dengan
   halaman" dari "apa yang diverifikasi test" — Playwright, *"Page
   Object Models"*, <https://playwright.dev/docs/pom>.
2. **Constraint validation HTML5 pada elemen `hidden`.** Klaim di
   `03-panen.spec.ts` bahwa `<input type="hidden">` dikecualikan dari
   validasi `required` bawaan browser (berbeda dari `<input type="file">`
   atau `type="number"` yang tetap divalidasi meski disembunyikan lewat
   CSS `display:none`) merujuk pada spesifikasi resmi: *"If an input
   element's type attribute is in the Hidden state, it is barred from
   constraint validation"* — WHATWG, *HTML Living Standard*, §4.10.5 The
   input element, <https://html.spec.whatwg.org/multipage/input.html>.
3. **Struktur dokumen test case.** Pemetaan ID (TC-XX-001, dst.) mengikuti
   pola dokumen `Test Plan` ISO/IEC/IEEE 29119-3:2021 yang sudah Anda
   pakai sebelumnya untuk `Test Plan SIMHPSB`, sehingga hasil Playwright
   ini bisa langsung disandingkan sebagai bukti otomasi di dokumen yang
   sama.

## 7. Keterbatasan yang Perlu Diketahui

Sebagai bagian dari komitmen menghindari misinformasi, berikut hal-hal
yang TIDAK bisa saya verifikasi 100% tanpa menjalankan aplikasi secara
langsung (saya tidak memiliki akses ke server Laravel yang hidup +
database MySQL Anda dalam sesi ini):

- **Collation database** (case-insensitive vs case-sensitive email) —
  memengaruhi `TC-FP-006` (login email ALL CAPS). Sudah diberi komentar
  di kode.
- **Nilai awal saldo Stok Gudang** setelah `migrate:fresh --seed` — data
  seed lama tampaknya tidak mengisi kolom `komoditas`/`jenis_transaksi`
  yang dipakai kode saat ini, sehingga saldo awal kemungkinan besar 0.
  Test yang bergantung pada saldo (mis. "Beras masuk butuh saldo Gabah
  > 0") sengaja saya desain untuk **membuat sendiri** data prasyaratnya
  (mencatat panen dulu) agar tidak bergantung pada state awal yang tidak
  pasti.
- Saya **sangat menyarankan** menjalankan `npx playwright test --ui`
  sekali secara manual untuk memverifikasi seluruh asumsi di atas
  terhadap environment Anda yang sesungguhnya, lalu melaporkan balik
  jika ada selector yang meleset — kemungkinan besar karena versi kode
  yang saya baca berbeda dari yang berjalan di server Anda saat ini.
