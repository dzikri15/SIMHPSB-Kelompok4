# Multi-stage build untuk aplikasi Laravel SIMHPSB

# Stage 1: Build dependencies
FROM php:8.2-fpm as builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    postgresql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql pcntl \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /var/lib/apt/lists/*

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files so artisan exists for composer post-install scripts
COPY composer.json composer.lock ./
COPY . ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Stage 2: Production image
FROM php:8.2-fpm

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    netcat-openbsd \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql pcntl \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /var/lib/apt/lists/*

# Create application user
RUN useradd -m -u 1000 laravel && \
    mkdir -p /app/storage/logs && \
    chown -R laravel:laravel /app

# Copy composer from builder stage
COPY --from=builder --chown=laravel:laravel /app/vendor ./vendor

# Copy application files
COPY --chown=laravel:laravel . .

# Copy entrypoint script
COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set proper permissions
RUN chown -R laravel:laravel /app

USER laravel

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
