# 📍 Prerequisites
Untuk menjalankan proyek ini harus menginstal: 
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)  
- Docker Compose
- [PHP Versi 8.3.17](https://www.php.net/downloads.php#v8.3.17)
- [Postman](https://www.postman.com/downloads/) untuk API
  
# 📂 Clone Repository
```
git clone https://github.com/AmandaNurAtika/SI-Penilaian-Mahasiswa.git cd Sinilai
```
# 📂 Clone Backend
```
git clone https://github.com/Arfilal/backend_sinilai.git backend
```
# 📂 Clone Frontend
```
git clone  https://github.com/GalihFitria/FrontEnd-SiNilai.git frontend
```

# 🦜 Buat Struktur Proyek
Buat struktur berikut di dalam project utama:
## 📝 Hasil:
```text
Sinilai/
│── backend/   # CodeIgniter Project
│── frontend/  # Laravel Project
│── docker/
│   ├── mysql
        ├── my.cnf
│   ├── nginx
        ├── conf.d
            ├── app.conf
            ├── backend.conf
            ├── frontend.conf
│   ├── php
        ├── local.ini
        ├── www.conf
│── Dockerfile
│── docker-compose.yml
```
Deskripsi:
- backend/ berisi API backend berbasis CodeIgniter.
- frontend/ berisi tampilan antarmuka pengguna berbasis Laravel.
- docker/ berisi konfigurasi untuk layanan Docker: MySQL, Nginx, PHP-FPM.
- Dockerfile untuk membangun image PHP custom.
- docker-compose.yml untuk mengelola dan menghubungkan semua container.

## 🍄 Setup Docker untuk Backend dan Frontend
### 1. Membuat file Dockerfile
Mendefinisikan langkah-langkah untuk membangun image PHP 8.3-FPM yang dilengkapi berbagai dependensi dan ekstensi (seperti pdo_mysql, gd, mbstring, dll.), serta menginstal Composer dan menyetel permission agar aplikasi Laravel dan CodeIgniter dapat berjalan optimal dalam container.
```
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd intl

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory
COPY . /var/www

# Install dependencies
RUN composer install

# Change ownership of our applications
RUN chown -R www-data:www-data /var/www

# Expose port 9000 for PHP-FPM
EXPOSE 9000 
```
### 2. Membuat file my.cnf di folder mysql
Digunakan untuk mengaktifkan logging dan memastikan MySQL menggunakan plugin autentikasi mysql_native_password, sehingga kompatibel dengan berbagai framework.
```
[mysqld]
general_log = 1
general_log_file = /var/lib/mysql/general.log
default-authentication-plugin=mysql_native_password
```
### 3. Membuat file app.conf didalam folder nginx
Mengatur server Nginx untuk menjalankan aplikasi berbasis PHP (baik backend maupun frontend) dengan konfigurasi FastCGI, path root public, dan mendukung routing Laravel/CodeIgniter.
Setiap file .conf diatur untuk:
1. Menentukan folder root /var/www/public
2. Menangani request .php dengan fastcgi_pass ke container PHP-FPM sesuai konteks:
3. app.conf: digunakan saat PHP backend dan frontend disatukan
4. backend.conf: mengarah ke service app
5. frontend.conf: mengarah ke service frontend-app
```
server {
    listen 80;
    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/public;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }
}
```
### 4. Membuat backend.conf didalam folder nginx
Konfigurasi khusus server backend (CodeIgniter) dengan pengaturan Nginx yang mengarahkan permintaan ke backend melalui port 80 dan PHP-FPM.

```
server {
    listen 80;
    index index.php index.html;
    root /var/www/public;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
}

```

### 5. Membuat file frontend.conf didalam folder nginx
Pengaturan server Nginx untuk Laravel frontend, agar aplikasi bisa diakses lewat browser, termasuk support untuk routing Laravel dan eksekusi file PHP via PHP-FPM.
```
server {
    listen 80;
    index index.php index.html;
    root /var/www/public;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass frontend-app:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
}

```

### 6. Membuat file local.ini didalam folder php
File konfigurasi tambahan untuk PHP dalam container yang meningkatkan batas upload, memori, dan waktu eksekusi agar sesuai kebutuhan aplikasi
```
upload_max_filesize=40M
post_max_size=40M
memory_limit=512M
max_execution_time=600
max_input_time=600 
```

### 7. Membuat file www.conf didalam folder php
Pengaturan PHP-FPM yang menentukan user/group proses, port komunikasi antar container, dan jumlah proses yang digunakan untuk menangani request secara efisien.


```
[www]
user = www-data
group = www-data

listen = 0.0.0.0:9000

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

```

## 🍁 Membuat Docker-compose.yml
File utama yang mengatur seluruh container (PHP, Nginx, MySQL, phpMyAdmin) termasuk build image, konfigurasi volume, port mapping, environment database, dan jaringan agar semua komponen saling terhubung dan dapat berjalan otomatis.
File ini menjalankan seluruh aplikasi menggunakan multi-container:
- app: Container PHP-FPM untuk backend CodeIgniter.
- webserver: Nginx untuk melayani backend, mengarahkan ke app.
- frontend-app: Container PHP-FPM untuk frontend Laravel.
- frontend-web: Nginx untuk frontend Laravel, mengarahkan ke frontend-app.
- db: Database MySQL 8, dengan database awal sinilai2.
- phpmyadmin: Antarmuka visual untuk manajemen database MySQL.
- Semua service berada dalam jaringan virtual sinilai-network.
```
version: '3.8'

services:
  # Backend PHP
  app:
    build:
      context: ./backend
      dockerfile: ../Dockerfile
    image: sinilai-backend
    container_name: sinilai-app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./backend:/var/www
      - ./docker/php/local.ini:/usr/local/etc/php/conf.d/local.ini
    networks:
      - sinilai-network

  # Backend Nginx
  webserver:
    image: nginx:alpine
    container_name: sinilai-nginx
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./backend:/var/www
      - ./docker/nginx/conf.d/backend.conf:/etc/nginx/conf.d/default.conf
    networks:
      - sinilai-network

  # Frontend PHP (pakai container PHP yang sama)
  frontend-app:
    build:
      context: ./frontend
      dockerfile: ../Dockerfile
    image: sinilai-frontend
    container_name: sinilai-fe-app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./frontend:/var/www
      - ./docker/php/local.ini:/usr/local/etc/php/conf.d/local.ini
      - ./docker/php/www.conf:/usr/local/etc/php-fpm.d/www.conf
    networks:
      - sinilai-network

  # Frontend Nginx
  frontend-web:
    image: nginx:alpine
    container_name: sinilai-fe-nginx
    restart: unless-stopped
    ports:
      - "8082:80"
    volumes:
      - ./frontend:/var/www
      - ./docker/nginx/conf.d/frontend.conf:/etc/nginx/conf.d/default.conf
    networks:
      - sinilai-network

  # MySQL
  db:
    image: mysql:8.0
    container_name: sinilai-db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: sinilai2
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    ports:
      - "3307:3306"
    volumes:
      - dbdata:/var/lib/mysql
      - ./docker/mysql/my.cnf:/etc/mysql/my.cnf
    networks:
      - sinilai-network

  # phpMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: sinilai-phpmyadmin
    restart: unless-stopped
    environment:
      PMA_HOST: db
      PMA_PORT: 3306
    ports:
      - "8081:80"
    networks:
      - sinilai-network

networks:
  sinilai-network:
    driver: bridge

volumes:
  dbdata:
    driver: local
```

## 🍟 Install Dependency
1. Untuk backend
   - cd backend
   - composer install
   - cp env .env
Masuk ke direktori backend, menginstal seluruh dependensi PHP melalui Composer berdasarkan file composer.json, dan menyalin file konfigurasi environment untuk CodeIgniter agar bisa membaca variabel sistem yang dibutuhkan.
2. Untuk Frontend
   - cd frontend
   - php artisan key:generate
   - cp .env.example .env
Masuk ke direktori frontend, menghasilkan application key Laravel yang bersifat unik dan aman, serta menyalin file .env.example menjadi .env sebagai file konfigurasi utama environment Laravel.

## 🛠️ Setup & Jalankan dengan Docker Compose

1. Pastikan Docker Desktop sudah terinstal
2. Pastikan Docker Desktop berjalan
3. Jalankan perintah berikut untuk membuat sebuah container:
```
docker-compose up -d --build
```
4. Pastikan container berjalan dengan baik
![Screenshot (242)](https://github.com/user-attachments/assets/6267cd99-911a-467b-ad16-e0f6c68c4f39)

5. Pastikan Frontend berjalan
![Screenshot (335)](https://github.com/user-attachments/assets/03f3c8a8-a66d-4544-9af7-24fbf77ab27c)
![Screenshot (336)](https://github.com/user-attachments/assets/2b900720-bdd3-4120-b1af-c89ffb86e924)

Untuk tampilan frontend masih menampilkan halaman login dan dashboard. Untuk fitur yang lainnya seperti Data dosen, Data Mahasiswa, Data matkul, Daata prodi, Data kelass, dan penilaian belum dapat diakses. 
## 🦩 Akses Aplikasi
- Backend (CodeIgniter): http://localhost:8080/
- Frontend (Laravel): http://localhost:8082/
- PhpMyAdmin: http://localhost:8081/

## 🐧 Konfigurasi Database
- Host: localhost
- User: root
- Password:
- Database name: sinilai2

## 🔁 Update dan rebuild 
Apabila ada perubahan kode, maka jalankan
```
git pull origin main
docker-compose up -d --build
```

## 🚫 Remove Container
```
docker-compose down
```
