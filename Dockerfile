FROM php:8.3-fpm

# pada docker-file untuk Menyiapkan container PHP-FPM yang dibutuhkan

# Mengupdate package list dan menginstal dependensi sistem yang dibutuhkan oleh PHP dan Composer
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip


# Membersihkan cache agar ukuran image lebih kecil
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd intl

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Mengatur direktori kerja di dalam container
WORKDIR /var/www

# Menyalin semua file dari direktori proyek ke dalam container
COPY . /var/www

# Install dependencies
RUN composer install

# Mengubah kepemilikan file agar dapat diakses oleh user www-data (default user PHP-FPM)
RUN chown -R www-data:www-data /var/www

# Mengekspos port 9000, yang digunakan oleh PHP-FPM untuk menerima request dari Nginx
EXPOSE 9000 

