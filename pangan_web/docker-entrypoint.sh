#!/bin/bash
set -e

# Wait for database to be ready
while ! nc -z db 3306; do
  echo "Waiting for MySQL..."
  sleep 1
done

echo "MySQL is ready!"

# Run migrations if .env APP_ENV is local/development
if [ "$APP_ENV" != "production" ]; then
  echo "Running migrations..."
  php artisan migrate --force
  
  echo "Seeding database..."
  php artisan db:seed --force
  
  echo "Caching configuration..."
  php artisan config:cache
  php artisan route:cache
fi

# Clear and cache views
php artisan view:clear
php artisan view:cache

# Start PHP-FPM
exec "$@"
