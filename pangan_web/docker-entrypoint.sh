#!/bin/bash
set -e

echo "========================================="
echo "  Starting SIMHPSB Application"
echo "========================================="

# Wait for MySQL
echo "Waiting for MySQL..."
until nc -z db 3306; do
    echo "MySQL not ready, retrying in 3s..."
    sleep 3
done
echo "MySQL is ready!"

# Wait for Redis
echo "Waiting for Redis..."
until nc -z redis 6379; do
    echo "Redis not ready, retrying in 3s..."
    sleep 3
done
echo "Redis is ready!"

# Clear semua cache
echo "Clearing cache..."
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan view:clear 2>/dev/null || true
php artisan route:clear 2>/dev/null || true

# Generate app key kalau belum ada
if grep -q "APP_KEY=base64:" /app/.env 2>/dev/null; then
    echo "APP_KEY already set"
else
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Create storage symlink untuk akses public files
echo "Creating storage symlink..."
php artisan storage:link 2>/dev/null || true

# Cek apakah tabel sudah ada (dari init.sql)
TABLE_EXISTS=$(php artisan tinker --execute="echo Schema::hasTable('users') ? 'yes' : 'no';" 2>/dev/null | tail -1)

if [ "$TABLE_EXISTS" = "yes" ]; then
    echo "Tables already exist from init.sql, running migrations for new tables only..."
    php artisan migrate --force 2>/dev/null || true
else
    echo "Running fresh migrations..."
    php artisan migrate --force
fi

echo "========================================="
echo "  SIMHPSB is ready at http://localhost"
echo "========================================="

exec "$@"