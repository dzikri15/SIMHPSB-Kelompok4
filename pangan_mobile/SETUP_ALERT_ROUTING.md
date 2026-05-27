# Setup Routing untuk Alert Screen

## 📋 Update main.dart

Tambahkan route untuk Alert Screen dan Konfigurasi Alert Screen di file `lib/main.dart`:

### Langkah 1: Import Screen
```dart
import 'screens/alert_screen.dart';
import 'screens/konfigurasi_alert_screen.dart';
```

### Langkah 2: Tambah Routes di MaterialApp

Cari bagian `MaterialApp` dan tambahkan `routes` property:

```dart
MaterialApp(
  title: 'Android Pangan',
  theme: ThemeData(
    useMaterial3: true,
  ),
  home: const BerandaScreen(),
  routes: {
    '/alert': (context) => const AlertScreen(),
    '/konfigurasi-alert': (context) => const KonfigurasiAlertScreen(),
    '/gudang': (context) => const GudangScreen(),
    '/transaksi': (context) => const TransaksiScreen(),
    '/petani': (context) => const PetaniScreen(),
    '/panen': (context) => const PanenScreen(),
  },
)
```

## 🔧 Backend Laravel Setup

### 1. Update Routes di `routes/api.php`

```php
Route::middleware('auth:sanctum')->group(function () {
    // Alert endpoints
    Route::apiResource('alert', AlertController::class);
    
    // Stok endpoints
    Route::apiResource('stok', StokController::class);
    Route::get('stok/monitoring', [StokController::class, 'monitoring']);
    
    // Transaksi endpoints
    Route::apiResource('transaksi-stok', TransaksiStokController::class);
});
```

### 2. Create Alert Model & Controller

```bash
php artisan make:model Alert -mcr
php artisan make:model Stok -mcr
```

### 3. Alert Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('alerts', function (Blueprint $table) {
            $table->id();
            $table->string('komoditas');
            $table->double('stok_saat_ini');
            $table->double('batas_minimum');
            $table->enum('status', ['aktif', 'proses', 'selesai'])->default('aktif');
            $table->foreignId('ditangani_oleh')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('alerts');
    }
};
```

### 4. Alert Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Alert extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'komoditas',
        'stok_saat_ini',
        'batas_minimum',
        'status',
        'ditangani_oleh',
    ];

    protected $casts = [
        'stok_saat_ini' => 'float',
        'batas_minimum' => 'float',
    ];

    public function handler(): BelongsTo
    {
        return $this->belongsTo(User::class, 'ditangani_oleh');
    }
}
```

### 5. Alert Controller

```php
<?php

namespace App\Http\Controllers;

use App\Models\Alert;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AlertController extends Controller
{
    public function index(Request $request)
    {
        $query = Alert::with('handler')->latest();

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        return $query->paginate(20);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'komoditas' => 'required|string',
            'stok_saat_ini' => 'required|numeric',
            'batas_minimum' => 'required|numeric',
            'status' => 'sometimes|in:aktif,proses,selesai',
        ]);

        return Alert::create($validated);
    }

    public function show(Alert $alert)
    {
        return $alert->load('handler');
    }

    public function update(Request $request, Alert $alert)
    {
        $validated = $request->validate([
            'status' => 'sometimes|in:aktif,proses,selesai',
            'ditangani_oleh' => 'sometimes|exists:users,id',
        ]);

        if ($validated) {
            if (isset($validated['ditangani_oleh'])) {
                $validated['ditangani_oleh'] = $request->user()->id;
            }
        }

        $alert->update($validated);
        return $alert->load('handler');
    }

    public function destroy(Alert $alert)
    {
        $alert->delete();
        return response()->noContent();
    }
}
```

### 6. Create Notification Event (Optional)

```bash
php artisan make:event StockAlert
php artisan make:listener NotifyAdminOfAlert --event=StockAlert
```

```php
// app/Events/StockAlert.php
public function __construct(public Alert $alert) {}

// app/Listeners/NotifyAdminOfAlert.php
public function handle(StockAlert $event): void
{
    // Send notification or email
}
```

## 🔄 Integration Checklist

- [ ] Routes ditambahkan ke main.dart
- [ ] Alert Screen dapat diakses via notification bell
- [ ] Konfigurasi Alert Screen dapat diakses via button/menu
- [ ] Laravel endpoints sudah siap
- [ ] Alert Model dan Migration sudah di-run
- [ ] Controller API sudah berfungsi
- [ ] Test API endpoints dengan Postman
- [ ] Flutter app terkoneksi dengan API
- [ ] Data alert muncul di Alert Screen
- [ ] Status update berfungsi
- [ ] Pull-to-refresh berfungsi

## 🧪 Testing dengan Postman

### Create Alert
```
POST http://localhost:8000/api/alert
Authorization: Bearer {token}
Content-Type: application/json

{
  "komoditas": "Beras",
  "stok_saat_ini": 400,
  "batas_minimum": 500,
  "status": "aktif"
}
```

### Get All Alerts
```
GET http://localhost:8000/api/alert
Authorization: Bearer {token}
```

### Update Alert Status
```
PUT http://localhost:8000/api/alert/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "proses",
  "ditangani_oleh": 1
}
```

## 📱 Testing di Flutter

1. Run app: `flutter run`
2. Buka halaman manapun
3. Klik notification bell di atas kanan
4. Verifikasi Alert Screen membuka
5. Test update status dengan button
6. Test pull-to-refresh

## 🔐 Security Notes

- JWT token otomatis refresh di ApiService
- Authorization header ditambahkan di setiap request
- Hanya authenticated users yang bisa access
- Status update hanya bisa dilakukan oleh authorized user

---

**Setup Complete!** 🎉

Alert Screen sudah siap digunakan dan terintegrasi dengan backend Laravel.
