# Stage 1: Build dependencies
FROM php:8.2-fpm AS builder

WORKDIR /app

# Install system dependencies tanpa gd (lebih ringan)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libzip-dev \
    unzip \
    && docker-php-ext-install zip pdo pdo_mysql pcntl bcmath \
    && rm -rf /var/lib/apt/lists/*

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy semua file
COPY . ./

# Install dependencies
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Stage 2: Production image
FROM php:8.2-fpm

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    netcat-openbsd \
    unzip \
    curl \
    && docker-php-ext-install zip pdo pdo_mysql pcntl bcmath \
    && rm -rf /var/lib/apt/lists/*

# Create application user
RUN useradd -m -u 1000 laravel

# Copy vendor dari builder
COPY --from=builder --chown=laravel:laravel /app/vendor ./vendor

# Copy semua file aplikasi
COPY --chown=laravel:laravel . .

# Set storage permissions
RUN mkdir -p \
    /app/storage/logs \
    /app/storage/framework/sessions \
    /app/storage/framework/views \
    /app/storage/framework/cache \
    /app/bootstrap/cache \
    && chown -R laravel:laravel /app/storage \
    && chown -R laravel:laravel /app/bootstrap/cache \
    && chmod -R 775 /app/storage \
    && chmod -R 775 /app/bootstrap/cache

# Copy entrypoint
COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -snf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Konfigurasi PHP-FPM agar listen di semua interface port 9000
# dan jalan sebagai user 'laravel' (bukan default www-data)
RUN sed -i \
    -e 's/^listen = .*/listen = 0.0.0.0:9000/' \
    -e 's/^user = .*/user = laravel/' \
    -e 's/^group = .*/group = laravel/' \
    /usr/local/etc/php-fpm.d/www.conf

USER laravel

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]