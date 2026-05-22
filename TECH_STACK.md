# SIMHPSB - Tech Stack Configuration

## Requirement vs Actual

| Component | Requirement | Actual | Status | Notes |
|-----------|-------------|--------|--------|-------|
| Backend API | Laravel 10.x | Laravel 12.59.0 | ✅ Better | Lebih baru & stabil, backward compatible |
| PHP | 8.2 | 8.2.12 | ✅ OK | Exact match |
| Database | MySQL 8.0 | MariaDB 10.4.32 | ⚠️ Compatible | Fork dari MySQL, fully compatible |

## Environment Details

```
PHP Version:     8.2.12
Laravel Version: 12.59.0
Database:        MariaDB 10.4.32 (MySQL compatible)
Node.js:         -
NPM:             -
```

## Configuration Files

- **.env**: File konfigurasi environment
  - Session: File-based (tidak perlu table database)
  - Cache: File-based (tidak perlu table database)
  - Queue: Sync (tidak perlu table database)

- **composer.json**: Dependencies Laravel dan packages
  - jwt-auth: ^2.3 (untuk authentication)

## Database Setup

Database sudah ter-import dengan schema lengkap:
- users
- petani
- lahan
- panen
- gudang
- stok_beras
- harga
- distribusi
- alerts

## Server Status

- Development Server: Berjalan di http://127.0.0.1:8000
- MySQL/MariaDB: Connection OK
- Session Storage: File-based ($APP_PATH/storage/framework/sessions)
- Cache Storage: File-based ($APP_PATH/storage/framework/cache)

## Catatan

### Upgrade dari Laravel 10 ke 12
- Laravel 12 adalah versi terbaru dengan support PHP 8.2+
- Lebih banyak features dan improvements
- Backward compatible dengan Laravel 10
- Downgrade ke 10 memerlukan refactoring file-file structure

### Database Compatibility
- MariaDB 10.4 fully compatible dengan MySQL 8.0
- Tidak perlu upgrade database untuk kompatibilitas
