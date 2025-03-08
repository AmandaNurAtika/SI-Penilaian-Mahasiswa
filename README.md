# 🚀 Setup & Deployment Guide  
## ☑️ Prerequisites
Untuk menjalankan proyek ini, anda harus menginstal: 
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)  
- [Git](https://git-scm.com/downloads)
  
## 📂 Clone Repository
```
git clone https://github.com/AmandaNurAtika/SI-Penilaian-Mahasiswa.git cd repository name
```
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
