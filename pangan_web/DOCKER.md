# 🐳 Docker Setup Guide - SIMHPSB

Panduan lengkap untuk menjalankan aplikasi SIMHPSB menggunakan Docker dan Docker Compose.

---

## 📋 Prerequisites (Yang Harus Diinstall Dulu)

Pastikan sudah install:
1. **Docker Desktop** → [Download](https://www.docker.com/products/docker-desktop)
2. **Git** → [Download](https://git-scm.com/download/win)

Verifikasi instalasi dengan membuka **Command Prompt (CMD) / PowerShell**:

```cmd
docker --version
docker compose version
git --version
```

Jika semua 3 command keluar versi → **Siap lanjut!** ✅

---

## 🚀 Setup Lengkap di CMD (Copy-Paste Langsung)

### **STEP 1: Clone Repository**

Buka **Command Prompt** atau **PowerShell**, kemudian jalankan:

```cmd
git clone https://github.com/dzikri15/SIMHPSB-Kelompok4.git
cd SIMHPSB-Kelompok4\pangan_web
```

### **STEP 2: Setup Environment**

Copy file config:

```cmd
copy .env.example .env
```

✅ `.env` sudah siap pakai (password: `root`, sudah default di `.env`)

### **STEP 3: Download & Jalankan Docker**

```cmd
docker compose down -v
docker compose up -d --build
```

⏳ **Tunggu 2-3 menit** sampai semua services ready (terutama MySQL)

Cek status services:

```cmd
docker compose ps
```

Semua harus status **"Up"** atau **"healthy"** ✅

### **STEP 4: Setup Laravel Cache & Config**

```cmd
docker compose exec app php artisan config:clear
docker compose exec app php artisan cache:clear
```

✅ Selesai! Laravel sudah ready.

---

## 🌐 Akses Aplikasi

| Service | URL | Akun Login |
|---------|-----|-----------|
| **Web App** | http://localhost | - |
| **API** | http://localhost:8000/api | - |
| **phpMyAdmin** | http://localhost:8080 | User: `root`, Pass: `root` |

**Login ke aplikasi:**
- Email: `petugas@simhpsb.com`
- Password: `password`

---

## 📱 Test API di CMD

Login & dapatkan token:

```cmd
curl -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"petugas@simhpsb.com\",\"password\":\"password\"}"
```

Cek dashboard data:

```cmd
curl -X GET http://localhost:8000/api/stok/summary ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 🛑 Stop & Clean Up

**Stop containers (data tetap):**

```cmd
docker compose stop
```

**Start ulang:**

```cmd
docker compose start
```

**Hapus semua (termasuk data database):**

```cmd
docker compose down -v
```

---

## 🔧 Troubleshooting

### **1. MySQL tidak healthy**

```cmd
docker compose logs db
docker compose restart db
```

### **2. Cache error**

```cmd
docker compose exec app php artisan cache:clear
docker compose exec app php artisan config:clear
```

### **3. Rebuild image (jika ada perubahan Dockerfile/composer.json)**

```cmd
docker compose up -d --build
```

### **4. Lihat error detail**

```cmd
docker compose logs app
docker compose logs db
docker compose logs
```

---

## 📂 File Penting

- `.env` - Configuration (DB password, JWT secret, Redis host)
- `docker-compose.yml` - Services configuration
- `simhpsb_db.sql` - Database dump (auto-import saat MySQL start)

**Jangan ubah kecuali ada instruksi khusus!**

---

## ✅ Checklist Sebelum Deploy

- [ ] Docker Desktop sudah running
- [ ] Semua 6 services status "Up" (`docker compose ps`)
- [ ] Bisa login ke http://localhost
- [ ] phpMyAdmin bisa diakses di http://localhost:8080
- [ ] API response 200 (bukan 500)

---

## 📞 Quick Command Reference

```cmd
# Lihat semua services
docker compose ps

# Lihat logs real-time
docker compose logs -f

# Lihat logs service tertentu
docker compose logs app
docker compose logs db

# Enter container terminal
docker compose exec app bash

# Restart semua services
docker compose restart

# Stop semua services (data tetap)
docker compose stop

# Start kembali
docker compose start

# Hapus semua (WARNING: data hilang!)
docker compose down -v
```

---

**Selesai! 🎉 Aplikasi SIMHPSB sudah berjalan di Docker.**
```

Output yang diharapkan:
```
NAME                COMMAND                  SERVICE      STATUS
simhpsb_app         "docker-entrypoint.sh"   app          Up
simhpsb_db          "docker-entrypoint.sh"   db           Up
simhpsb_redis       "redis-server..."        redis        Up
simhpsb_nginx       "nginx -g daemon off"    nginx        Up
simhpsb_queue       "php artisan queue..."   queue        Up
```

### 4️⃣ Generate Application Key
```bash
docker compose exec app php artisan key:generate
```

### 5️⃣ Jalankan Migrations & Seeding
```bash
# Migration
docker compose exec app php artisan migrate

# Seeding (opsional, untuk data dummy)
docker compose exec app php artisan db:seed
```

### 6️⃣ Akses Aplikasi
- **Web App**: http://localhost:80 atau http://localhost
- **MySQL**: localhost:3306 (user: `laravel`, password: `password`)
- **Redis**: localhost:6379

---

## 📁 Struktur Docker

```
pangan_web/
├── Dockerfile           # Image definition untuk Laravel app
├── docker-compose.yml   # Orchestration untuk semua services
├── docker/              # Docker configuration files
│   └── nginx/
│       └── conf.d/
│           └── default.conf  # Nginx configuration
├── docker-entrypoint.sh # Entry script untuk container startup
└── .dockerignore        # Files to exclude from build context
```

### Services yang Dijalankan:

| Service | Port | URL | Purpose |
|---------|------|-----|---------|
| **app** | 9000 | Internal (via Nginx) | PHP-FPM (Laravel App) |
| **nginx** | 80, 443 | http://localhost | Web Server |
| **db** | 3306 | localhost:3306 | MySQL 8.0 Database |
| **redis** | 6379 | localhost:6379 | Redis Cache & Queue |
| **queue** | - | Internal | Laravel Queue Worker |

---

## 🛠️ Common Commands

### Management

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Stop dan hapus volumes
docker compose down -v

# Lihat logs
docker compose logs -f app

# Lihat logs service tertentu
docker compose logs -f nginx
docker compose logs -f db
docker compose logs -f redis
```

### Laravel Commands

```bash
# Jalankan artisan command
docker compose exec app php artisan <command>

# Examples:
docker compose exec app php artisan migrate
docker compose exec app php artisan tinker
docker compose exec app php artisan cache:clear
docker compose exec app php artisan route:list
docker compose exec app php artisan make:model MyModel
```

### Database

```bash
# Login ke MySQL
docker compose exec db mysql -u laravel -p simhpsb

# Backup database
docker compose exec db mysqldump -u laravel -p simhpsb > backup.sql

# Restore database
docker compose exec -T db mysql -u laravel -p simhpsb < backup.sql
```

### Redis

```bash
# Access Redis CLI
docker compose exec redis redis-cli

# Check Redis info
docker compose exec redis redis-cli info

# Clear all cache
docker compose exec redis redis-cli FLUSHALL
```

---

## 🔍 Troubleshooting

### ❌ Containers gagal start

```bash
# Check error logs
docker compose logs

# Rebuild containers
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

### ❌ Database connection error

```bash
# Pastikan db service sudah running
docker compose ps db

# Check MySQL logs
docker compose logs db

# Verify environment variables
docker compose exec app php artisan env | grep DB_
```

### ❌ Redis connection failed

```bash
# Test Redis connection
docker compose exec redis redis-cli ping

# Should return: PONG
```

### ❌ Nginx 502 Bad Gateway

```bash
# Check PHP-FPM status
docker compose logs app

# Verify Nginx config
docker compose exec nginx nginx -t

# Restart services
docker compose restart app nginx
```

### ❌ Permission denied errors

```bash
# Fix permission (jika perlu)
docker compose exec app chown -R laravel:laravel /app/storage
docker compose exec app chmod -R 775 /app/storage
```

---

## 📦 Build & Push ke Registry (Optional)

### Untuk Production:

```bash
# Build image dengan tag
docker build -t dzikri15/simhpsb:latest .

# Login ke Docker Hub
docker login

# Push ke registry
docker push dzikri15/simhpsb:latest
```

---

## 🌐 Environment Setup untuk Production

Update `.env` untuk production:

```env
APP_ENV=production
APP_DEBUG=false

CACHE_DRIVER=redis
QUEUE_CONNECTION=redis

DB_HOST=db-prod
DB_USERNAME=prod_user
DB_PASSWORD=strong_password_here

REDIS_PASSWORD=redis_password_here
```

Jalankan production containers:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## 📚 Referensi

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Laravel Docker Guide](https://laravel.com/docs/11/deployment)
- [Nginx Official Image](https://hub.docker.com/_/nginx)
- [MySQL Official Image](https://hub.docker.com/_/mysql)
- [Redis Official Image](https://hub.docker.com/_/redis)

---

## 💡 Tips

1. **Untuk development**, gunakan `docker compose up` (tanpa `-d`) untuk melihat logs real-time
2. **Volume mounting** memungkinkan hot-reload untuk PHP files
3. **Queue worker** berjalan di container terpisah untuk async job processing
4. Pastikan **port 80, 3306, 6379** tidak digunakan aplikasi lain

---

**Last Updated**: May 22, 2026  
**Maintained by**: dzikri15 (Muhammad Dzikri Sagara)
