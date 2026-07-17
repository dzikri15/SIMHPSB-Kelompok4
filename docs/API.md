# 📋 Dokumentasi API SIMHP

API ini dikembangkan menggunakan Laravel 12.x dan diamankan dengan JWT Authentication (`tymon/jwt-auth`).

**Base URL API:** `http://localhost/api` (Lokal) atau `https://simhp.my.id/api` (Production)

> **Catatan:** Sebagian besar endpoint dilindungi oleh `auth:api`. Anda harus menyertakan header `Authorization: Bearer {token}` pada setiap request kecuali pada endpoint `login` dan `register`.

---

## 🔐 1. Authentication (Otentikasi)

Endpoint untuk autentikasi pengguna dan manajemen sesi JWT.

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `POST` | `/api/auth/login` | Login (mendapatkan JWT token). Menerima kredensial email/username/petani. |
| `POST` | `/api/auth/register` | Mendaftarkan user baru (Admin/Petugas). |
| `POST` | `/api/auth/register-petani` | Mendaftarkan akun untuk petani. |
| `POST` | `/api/auth/logout` | Logout (invalidate token aktif). Membutuhkan token. |
| `GET`  | `/api/auth/me` | Mengambil data profile user yang sedang login. |
| `POST` | `/api/auth/refresh` | Memperbarui (refresh) JWT token yang akan kedaluwarsa. |

---

## 👨‍🌾 2. Petani & Lahan

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/petani` | List semua petani (Paginated). |
| `POST` | `/api/petani` | Tambah data petani baru. |
| `GET` | `/api/petani/{id}` | Detail data petani tertentu. |
| `PUT` | `/api/petani/{id}` | Update data petani. |
| `DELETE` | `/api/petani/{id}` | Hapus data petani. |
| `PATCH` | `/api/petani/{id}/toggle-status` | Aktifkan/non-aktifkan akun petani. |
| `GET` | `/api/petani/export-pdf` | Ekspor data petani ke format PDF. |
| `GET` | `/api/lahan` | List semua lahan. |
| `POST` | `/api/lahan` | Tambah data lahan baru. |
| `GET` | `/api/lahan/{id}` | Detail lahan tertentu. |
| `PUT` | `/api/lahan/{id}` | Update data lahan. |
| `DELETE` | `/api/lahan/{id}` | Hapus data lahan. |

---

## 🌾 3. Panen (Pencatatan Hasil Panen)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/panen` | List seluruh data rekaman panen. |
| `POST` | `/api/panen` | Catat panen baru (Wajib melampirkan foto bukti). |
| `GET` | `/api/panen/{id}` | Lihat detail catatan panen tertentu. |
| `PUT` | `/api/panen/{id}` | Edit data panen. |
| `DELETE` | `/api/panen/{id}` | Hapus catatan panen. |

---

## 📦 4. Stok Gudang

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/stok/summary` | Ringkasan dashboard stok (saldo beras, gabah, dan alert aktif). |
| `GET` | `/api/stok/monitoring` | Monitoring detail stok per komoditas. |
| `GET` | `/api/stok/current` | Mendapatkan saldo stok berjalan. |
| `GET` | `/api/stok/transaksi` | List semua riwayat transaksi masuk/keluar gudang. |
| `POST` | `/api/stok/catat` | Catat transaksi stok manual (Wajib melampirkan foto bukti). |
| `PATCH` | `/api/stok/{id}/toggle-status` | Setujui atau batalkan transaksi stok tertentu. |

*(Terdapat juga endpoint standar `apiResource` untuk entitas stok).*

---

## 💰 5. Manajemen Harga

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/harga/aktif` | Mendapatkan data harga gabah dan beras yang aktif saat ini. |
| `POST` | `/api/harga/calculate` | Kalkulator/prediksi harga berdasarkan quantity. |
| `GET` | `/api/harga` | List riwayat perubahan konfigurasi harga. |
| `POST` | `/api/harga` | Simpan konfigurasi harga baru (Harga gabah & harga beras). |
| `PUT` | `/api/harga/{id}` | Update konfigurasi harga historis. |

---

## 🔔 6. Alerts & Peringatan Dini

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/alert/minimum` | Cek alert untuk stok komoditas yang berada di bawah batas minimum. |
| `GET` | `/api/alert/konfigurasi` | Lihat pengaturan batas minimum saat ini untuk setiap komoditas. |
| `PUT` | `/api/alert/konfigurasi` | Simpan/ubah batas minimum stok. |
| `GET` | `/api/alert` | List semua record alert historis. |
| `POST` | `/api/alert/{id}/handle` | Tandai alert stok (yang menipis) sebagai sudah ditangani (Handled). |

---

## 📋 7. Laporan Eksekutif

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/laporan/panen` | Generate laporan rekapitulasi panen (Bisa difilter per tanggal). |
| `GET` | `/api/laporan/stok` | Generate laporan keluar/masuk stok gudang. |
| `GET` | `/api/laporan/margin` | Generate laporan analisis keuntungan (margin penjualan vs pembelian). |

---

## 📱 8. Dashboard Petani (Khusus Role Petani)

Endpoint khusus untuk aplikasi mobile yang diakses dengan role `petani`.

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/petani-profile/` | Mendapatkan profil dari petani yang sedang login. |
| `GET` | `/api/petani-profile/panen` | Mendapatkan riwayat panen milik petani yang sedang login. |
| `GET` | `/api/petani-profile/panen/{id}` | Detail panen tertentu milik petani. |
| `GET` | `/api/petani-profile/ringkasan` | Mendapatkan ringkasan total hasil panen petani bersangkutan. |

---

## 🚚 9. Distribusi & Tujuan Distribusi

Diperuntukkan khusus manajemen pengiriman ke pelanggan (Khusus Admin & Petugas).

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/tujuan-distribusi` | List semua pelanggan tetap (toko/mitra). |
| `GET` | `/api/tujuan-distribusi/{id}/histori` | Riwayat transaksi pengiriman ke tujuan tertentu. |
| `GET` | `/api/tujuan-distribusi/{id}` | Detail informasi tujuan distribusi. |
| `POST` | `/api/tujuan-distribusi` | Tambah lokasi/pelanggan baru. |
| `PUT` | `/api/tujuan-distribusi/{id}` | Edit profil/alamat tujuan distribusi. |
| `DELETE` | `/api/tujuan-distribusi/{id}` | Hapus tujuan distribusi. |
| `GET/POST` | `/api/distribusi` | Manajemen data pencatatan pengiriman *(API Resource)*. |

---

## 🤖 10. Chatbot HPSBBot

Integrasi Groq API dengan Llama-3.3-70b-versatile (Biasanya di-handle melalui web routes, namun digunakan oleh API mobile juga).

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `POST` | *(via web/api depending on setup)* | Mengirimkan pertanyaan (prompt) ke Chatbot terkait data stok & harga real-time. |

---

> **Developer Note:**
> Untuk mengakses file/gambar storage (foto bukti) dari Flutter app / eksternal secara public, Anda dapat menggunakan endpoint proxy: `GET /api/file/{path}` yang melayani request gambar dengan aturan CORS terbuka (`Access-Control-Allow-Origin: *`).
