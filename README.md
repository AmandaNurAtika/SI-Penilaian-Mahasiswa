# 🚀 Setup & Deployment Guide  
## 📍 Prerequisites
Untuk menjalankan proyek ini, anda harus menginstal: 
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)  
- [Git](https://git-scm.com/downloads)
- [PHP Versi](https://www.php.net/downloads.php#v8.3.17)
  
## 📂 Clone Repository
```
git clone https://github.com/AmandaNurAtika/SI-Penilaian-Mahasiswa.git cd Sinilai
```
## 📂 Clone Backend
```
git clone https://github.com/Arfilal/backend_sinilai.git backend
```
## 📂 Clone Frontend
```
git clone  https://github.com/GalihFitria/FrontEnd-SiNilai.git frontend
```
## 🦜 Buat Struktur Proyek
Buat struktur berikut di dalam project utama:
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


## 🛠️ Setup & Jalankan dengan Docker Compose
1. Pastikan Docker Desktop sudah terinstal
2. Pastikan Docker Desktop berjalan
3. Jalankan perintah berikut untuk membuat sebuah container:
```
docker-compose up -d --build
```
4. Pastikan container berjalan dengan baik
```
docker ps
```
   
## 🦩 Akses Aplikasi
- Backend (CodeIgniter): http://localhost:8080
- Frontend (Laravel): http://localhost:5173

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
