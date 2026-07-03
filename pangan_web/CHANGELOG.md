# 📋 Changelog SIMHP – Kelompok 4

> Branch: `dzikri-backend`
> Tanggal: 2 Juli 2026
> Commit terbaru: `852d2d6`

---

## 🆕 Update Sesi 2 – 2 Juli 2026 (Malam)

### 👥 7. Halaman About – Tim Pengembang

- **Diperbarui:** Profil anggota tim Kelompok 4 disesuaikan dengan kontribusi nyata dari GitHub Issues masing-masing
- **Tag badge** `Docker` → `Docker Setup`, `Laporan` → `Final Report` agar lebih deskriptif
- **Agusta Firman Firdaus:** Role dipersingkat menjadi `QA Mobile · Testing`
- **Devina Ayuliani:** Tag `Laporan Akhir` → `Final Report`
- **Dzikri Sagara:** Tag `Docker` → `Docker Setup`

---

### 🌾 8. Dashboard Petani – Riwayat Panen

#### Fitur Baru
- **Kolom Tanggal** ditambahkan pada tabel Riwayat Panen Terbaru di Dashboard Petani
  - Format: `dd MMM YYYY` (contoh: `02 Jul 2026`)
- **Paginasi (Pagination):** Tabel menampilkan maksimal 5 baris per halaman dengan navigasi First / Prev / 1 2 3 / Next / Last — sama persis seperti di halaman Pencatatan Panen
- **Panel Rekap Harian:** Panel baru di kolom kanan, menampilkan total gabah & total penghasilan **per tanggal** (sampai 30 hari terakhir), lengkap dengan jumlah entri panen per hari
  - Panel ini bisa **di-scroll** jika data lebih dari yang tampil
  - Ukuran teks penghasilan diperbesar (`14px`, bold, hijau gelap)
  - Ukuran teks "X entri panen" diperbesar (`13px`)

#### Perubahan Controller
- `PetaniDashboardController` kini menjalankan **2 query terpisah**:
  1. `$panens` → list individual per entri, `paginate(5)`, urut tanggal panen terbaru
  2. `$rekapTanggal` → `GROUP BY tanggal_panen`, `SUM(jumlah_gabah)`, `COUNT(*)`, `SUM(jumlah_gabah * harga_gabah_per_kg)`, ambil 30 tanggal terakhir

---

### 📊 9. Laporan – Perbaikan PDF Export

#### Bug Fix
- **PDF Laporan Stok** sebelumnya menampilkan layout "Laporan Margin" akibat nilai default `$jenis = 'margin'` pada method `export()` di `LaporanController`
  - **Diperbaiki:** Default diubah menjadi `'stok'`
  - **Diperbaiki:** Semua string fallback `?? 'margin'` di `pdf.blade.php` diubah menjadi `?? 'stok'`
- **Kolom Lahan kosong** di PDF Laporan Panen karena memanggil relasi `$item->lahan->nama` (tidak ada field `nama` di model `Lahan`)
  - **Diperbaiki:** Diubah menjadi `$item->petani->luas_lahan` (menampilkan luas lahan dalam m²)
  - **Header kolom** diubah dari `Lahan` menjadi `Lahan (m²)` agar sesuai dengan versi web

---

## 📝 File yang Dimodifikasi pada Update Sesi 2

| File | Perubahan |
|------|-----------|
| `resources/views/auth/about.blade.php` | Update profil tim, tag badge |
| `resources/views/petani/dashboard.blade.php` | Kolom tanggal, pagination, panel Rekap Harian |
| `resources/views/admin/laporan/pdf.blade.php` | Fix kolom Lahan, fix default jenis laporan |
| `app/Http/Controllers/PetaniDashboardController.php` | Query pagination + group by rekap harian |
| `app/Http/Controllers/Admin/LaporanController.php` | Fix default `$jenis` dari `margin` ke `stok` |

---

---

## 🌾 1. Pencatatan Panen

### Fitur Baru
- **Foto Bukti Transaksi wajib** diupload saat mencatat panen (validasi image, max 5MB)
- **Preview foto** sebelum submit dengan tombol hapus/reset
- **Halaman Detail Panen** (`show.blade.php`) — klik baris di tabel langsung menuju halaman detail
- Foto bukti bisa dilihat fullscreen via **lightbox** di halaman detail
- Tombol **← Kembali** dan **Edit** di halaman detail

### Perubahan Logic
- **Snapshot harga gabah** (`harga_gabah_per_kg`) disimpan saat panen dicatat → perubahan harga di kemudian hari tidak mempengaruhi histori lama
- Setiap panen yang disimpan **otomatis membuat entri Gabah Masuk** di Stok Gudang (running balance dihitung otomatis)
- Semua baris di tabel riwayat panen menjadi **clickable** → menuju halaman detail; tombol Edit/Hapus tetap berfungsi normal

### Perubahan Tampilan
- Label "Estimasi Nilai" → diganti **"Penghasilan"** di seluruh tampilan
- Label "Tonase" → diganti **"Hasil"**

---

## 🏪 2. Stok Gudang

### Perubahan Form "Catat Transaksi Stok"
- **Opsi "Gabah Masuk" dihapus** dari dropdown Jenis Transaksi — karena sudah otomatis tercatat dari Pencatatan Panen
- **Beras Masuk tetap tersedia** seperti semula
- Jika Komoditas dipilih **Gabah** → opsi "Masuk" disembunyikan otomatis (JavaScript), muncul pesan info: *"Gabah Masuk otomatis tercatat dari menu Pencatatan Panen"*
- Jika Komoditas dipilih **Beras** → opsi "Masuk" kembali muncul normal
- **Validasi server-side**: `StokController` menolak permintaan Gabah Masuk manual dengan pesan error jelas

---

## 📊 3. Laporan

### Kolom yang Dihapus dari Tabel Detail Laporan Panen
- ~~Beras Dihasilkan~~
- ~~HPP/kg (Est.)~~
- ~~Total HPP (Est.)~~

### Card Summary yang Dihapus
- ~~Total Distribusi~~ (beras periode ini)

### Berlaku di Semua Format
- Tampilan web
- Export Excel
- Export PDF

---

## 💰 4. Konfigurasi Harga

### Perubahan Logic
- Harga beli gabah yang diubah **hanya berlaku untuk pencatatan panen baru**
- Data histori panen lama **tidak terpengaruh** (snapshot harga tersimpan per transaksi)

---

## 👥 5. Tujuan Distribusi

### Perubahan Akses Role
- Sebelumnya: hanya **Admin** yang bisa mengakses menu Tujuan Distribusi
- Sekarang: **Admin dan Petugas** sama-sama bisa mengakses menu Tujuan Distribusi
- Route dipindahkan dari grup `role:admin` ke grup `role:admin,petugas`
- Menu di sidebar ditampilkan untuk semua role (tidak lagi dibungkus `@role('admin')`)

---

## 🏷️ 6. Rebranding: SIMHPSB → SIMHP

### Kepanjangan Baru
> **SIMHP** — Sistem Informasi Monitoring Hasil Panen

### File yang Diubah
| File | Perubahan |
|------|-----------|
| `resources/views/auth/intro.blade.php` | Nama, subtitle, animasi huruf |
| `resources/views/auth/login.blade.php` | Nama brand, tagline, title |
| `resources/views/auth/about.blade.php` | Judul, deskripsi, navbar |
| `resources/views/admin.blade.php` | Logo sidebar, title, subtitle topbar |
| `resources/views/layout/admin.blade.php` | Logo sidebar, title, subtitle topbar |
| `resources/views/chat-widget.blade.php` | Nama asisten bot |
| `resources/views/admin/pengaturan/index.blade.php` | Input nama sistem |
| `routes/web.php` | Komentar header file |
| `.env` | `APP_NAME=SIMHP` |

---

## 📁 File Baru (Ditambahkan)

| File | Keterangan |
|------|-----------|
| `database/migrations/..._add_foto_bukti_to_panen_table.php` | Migrasi menambah kolom `foto_bukti` ke tabel `panen` |
| `database/migrations/..._remove_unused_columns_from_konfigurasi_harga_table.php` | Migrasi hapus kolom tidak terpakai dari tabel konfigurasi harga |
| `resources/views/admin/panen/show.blade.php` | Halaman detail panen (dengan lightbox foto) |

---

## 📝 Ringkasan File yang Dimodifikasi (25 file)

```
app/Http/Controllers/Admin/HargaController.php
app/Http/Controllers/Admin/LaporanController.php
app/Http/Controllers/Admin/PanenController.php
app/Http/Controllers/Admin/StokController.php
app/Http/Controllers/PetaniDashboardController.php
app/Models/Panen.php
resources/views/admin.blade.php
resources/views/admin/harga/form.blade.php
resources/views/admin/harga/index.blade.php
resources/views/admin/laporan/index.blade.php
resources/views/admin/laporan/pdf.blade.php
resources/views/admin/panen/edit.blade.php
resources/views/admin/panen/index.blade.php
resources/views/admin/pengaturan/index.blade.php
resources/views/admin/stok/index.blade.php
resources/views/auth/about.blade.php
resources/views/auth/intro.blade.php
resources/views/auth/login.blade.php
resources/views/chat-widget.blade.php
resources/views/layout/admin.blade.php
resources/views/petani/dashboard.blade.php
routes/web.php
.env
```

---

*Generated on 2 Juli 2026 — SIMHP Kelompok 4 UKRI*
