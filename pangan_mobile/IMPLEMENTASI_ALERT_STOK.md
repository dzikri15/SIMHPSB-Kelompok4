# Implementasi Alert Stok Screen - Flutter

Dokumentasi lengkap implementasi fitur "Alert Stok" di aplikasi Flutter Android Pangan.

## 📋 Fitur yang Diimplementasikan

### 1. **Alert Stok Screen**
   - Menampilkan ringkasan status alert (Aktif, Dalam Penanganan, Sudah Ditangani)
   - Daftar riwayat alert dengan informasi lengkap
   - Pull-to-refresh functionality
   - Tombol aksi untuk mengubah status alert

### 2. **Konfigurasi Batas Minimum**
   - Screen untuk melihat dan mengubah batas minimum stok per gudang
   - Menampilkan status stok real-time
   - Dialog untuk edit batas minimum

### 3. **Notification Bell di AppTopBar**
   - Bell icon yang bisa diklik untuk membuka Alert Screen
   - Badge dengan jumlah alert aktif
   - FutureBuilder untuk fetch data alert

## 📁 File yang Dibuat

### File Baru:
1. **`lib/screens/alert_screen.dart`**
   - Main screen untuk menampilkan alert stok
   - Ringkasan status alert dengan 3 kategori
   - Daftar riwayat alert dengan aksi

2. **`lib/screens/konfigurasi_alert_screen.dart`**
   - Screen untuk konfigurasi batas minimum stok
   - Edit dialog untuk mengubah batas
   - Display stok saat ini, batas minimum, dan kapasitas

### File Yang Diupdate:
1. **`lib/widgets/app_top_bar.dart`**
   - Ubah dari `StatelessWidget` → `StatefulWidget`
   - Tambah notification bell dengan badge
   - Integrasi dengan `AlertService` untuk fetch alert count
   - Tambah onTap handler untuk navigate ke Alert Screen

## 🔧 Integrasi dengan API Backend

### Endpoints yang Digunakan:

```
GET    /api/alert                  (Daftar alert)
GET    /api/alert/:id              (Detail alert)
POST   /api/alert                  (Buat alert)
PUT    /api/alert/:id              (Update status alert)
DELETE /api/alert/:id              (Hapus alert)
GET    /api/stok/monitoring        (Monitor stok)
PUT    /api/stok/:id               (Update batas minimum)
```

### Response Format Alert:
```json
{
  "id": 1,
  "komoditas": "Beras",
  "stok_saat_ini": 400,
  "batas_minimum": 500,
  "status": "aktif",
  "ditangani_oleh": 2,
  "handler": {
    "id": 2,
    "nama": "Bambang S.",
    "email": "bambang@simhpsb.id"
  },
  "created_at": "2025-05-25T14:20:00+00:00"
}
```

### Status Values:
- `aktif` - Alert baru yang belum ditangani
- `proses` - Alert sedang ditangani (Dalam Penanganan)
- `selesai` - Alert sudah ditangani (Sudah Ditangani)

## 📱 Cara Penggunaan

### 1. Di Halaman Manapun:
- Klik **notification bell icon** di atas kanan
- Akan membuka Alert Screen
- Badge merah menunjukkan jumlah alert aktif

### 2. Di Alert Screen:
- Lihat **Ringkasan Status Alert** (atas)
- Lihat **Riwayat Alert** (bawah) dengan semua alert
- Klik **Tandai Ditangani** untuk mengubah status dari Aktif → Proses
- Klik **Tandai Selesai** untuk mengubah status dari Proses → Selesai

### 3. Konfigurasi Batas Minimum:
- Dari Alert Screen, navigasi ke Konfigurasi (via menu/button)
- Lihat stok saat ini dan batas minimum per gudang
- Klik **Ubah Batas Minimum** untuk edit
- Masukkan nilai baru dan simpan

## 🎨 UI Components

### Status Card (Alert Summary)
- Alert Aktif (merah) - `AppColors.error`
- Dalam Penanganan (orange) - `Color(0xFFF57C00)`
- Sudah Ditangani (hijau) - `AppColors.primary`

### Alert Item
- Icon sesuai status
- Info komoditas, stok, batas minimum
- Tanggal alert dibuat
- Status badge
- Nama petugas yang menangani
- Button aksi untuk update status

### Notification Badge
- Merah dengan white text
- Posisi: top-right di notification icon
- Menampilkan jumlah alert aktif

## 🔌 Dependencies

Pastikan sudah install package berikut di `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http:
  intl:
  shared_preferences:
```

## 🚀 Setup & Routing

### 1. Update `main.dart` untuk menambahkan routes:
```dart
// Di main.dart, tambahkan ke MaterialApp routes:
routes: {
  '/alert': (context) => const AlertScreen(),
  '/konfigurasi-alert': (context) => const KonfigurasiAlertScreen(),
},
```

### 2. Update navigation di app untuk include Alert Screen:
```dart
// Di bottom navigation atau drawer:
ListTile(
  leading: Icon(Icons.warning_rounded),
  title: Text('Alert Stok'),
  onTap: () => Navigator.pushNamed(context, '/alert'),
),
```

## 📊 Data Flow

```
AppTopBar
  ↓
  FutureBuilder (fetch alerts)
  ↓
  Notification Badge dengan count
  ↓
  Klik bell icon
  ↓
  Navigate to AlertScreen
  ↓
  AlertScreen
  ├─ Fetch alerts via AlertService
  ├─ Display summary (Aktif/Proses/Selesai)
  ├─ Display history dengan aksi buttons
  └─ Aksi: Update status, Refresh data
```

## 🐛 Error Handling

- Network errors: Menampilkan error message dengan retry button
- Invalid data: Validasi sebelum update status
- Loading state: Circular progress indicator saat fetch data
- Empty state: Icon dan text "Belum ada alert"

## 🔐 Permissions & Security

- JWT token dihandle otomatis di ApiService
- Authorization header ditambahkan ke setiap request
- Status update hanya bisa dilakukan oleh authorized user
- Error 401 ditangani dengan token refresh

## 📝 Testing Checklist

- [ ] Notification bell muncul di AppTopBar
- [ ] Badge menampilkan count alert aktif dengan benar
- [ ] Klik bell navigate ke AlertScreen
- [ ] Alert Screen menampilkan data dengan benar
- [ ] Ringkasan status menampilkan count yang tepat
- [ ] Riwayat alert ter-sort dengan benar (terbaru di atas)
- [ ] Status update buttons berfungsi
- [ ] Pull-to-refresh berfungsi
- [ ] Konfigurasi screen membuka saat button di-klik
- [ ] Edit batas minimum berhasil menyimpan ke database

## 📞 Integration dengan Backend Laravel

### Backend Requirements:

1. **Alert Model & Migration:**
```php
Schema::create('alerts', function (Blueprint $table) {
    $table->id();
    $table->string('komoditas');
    $table->double('stok_saat_ini');
    $table->double('batas_minimum');
    $table->enum('status', ['aktif', 'proses', 'selesai'])->default('aktif');
    $table->foreignId('ditangani_oleh')->nullable()->constrained('users');
    $table->timestamps();
});
```

2. **Alert Controller dengan CRUD:**
```php
// app/Http/Controllers/AlertController.php
Route::apiResource('alert', AlertController::class);
```

3. **Relationship di User Model:**
```php
public function handledAlerts()
{
    return $this->hasMany(Alert::class, 'ditangani_oleh');
}
```

4. **Auto-trigger alert saat stok di bawah minimum:**
```php
// Bisa menggunakan scheduled task atau event listener
```

## 🎯 Future Improvements

- [ ] Push notification saat ada alert baru
- [ ] Email notification ke admin
- [ ] Export alert history sebagai PDF/CSV
- [ ] Filter alert berdasarkan status/komoditas
- [ ] Search functionality
- [ ] Alert priority levels
- [ ] Assign alert ke petugas spesifik
- [ ] Notes/comments pada alert

---

**Last Updated**: 25 Mei 2025
**Version**: 1.0.0
