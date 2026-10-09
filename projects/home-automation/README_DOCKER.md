# Panduan Deployment BARA-Sense dengan Docker

Panduan ini menjelaskan cara mendeploy aplikasi **BARA-Sense** (Go Backend + React Frontend + PostgreSQL) ke server VPS (Ubuntu, Debian, dsb.) dengan cepat dan mudah menggunakan Docker & Docker Compose.

---

## 1. Persiapan Server

Pastikan server Anda sudah terpasang **Docker** dan **Docker Compose (v2)**.

Jika belum terpasang (di Ubuntu/Debian):
```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
```

---

## 2. Clone Repository & Konfigurasi

Clone repositori ini ke server Anda:
```bash
git clone <URL_REPO_ANDA> bara-sense
cd bara-sense
```

Salin contoh file environment `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```

Buka file `.env` dan sesuaikan kredensial Anda:
```bash
nano .env
```

Contoh konfigurasi `.env`:
```env
TUYA_ACCESS_ID=xxxxxx
TUYA_ACCESS_KEY=xxxxxx
TUYA_ENDPOINT=https://openapi-sg.iotbing.com

PORT=3000
POSTGRES_URL=postgres://postgres:postgres@db:5432/home_automation?sslmode=disable

# Opsional: Jika menggunakan Cloudflare Tunnel
CUSTOM_DOMAIN=bara-sense.my.id
CLOUDFLARE_TUNNEL_TOKEN=eyJh...
```

---

## 3. Jalankan Aplikasi

Jalankan perintah berikut untuk meng-compile image dan menjalankan container di background:

```bash
docker compose up -d --build
```

Docker akan secara otomatis:
1. Menyiapkan database **PostgreSQL 16** dan menunggu sampai siap menerima koneksi.
2. Melakukan multi-stage build:
   - Build frontend React (Vite)
   - Compile binary Go backend secara statically-linked
   - Memasukkannya ke runner image Alpine yang sangat ringan (< 50MB)
3. Menjalankan aplikasi di port `3000`.

---

## 4. Memeriksa Status & Log

- **Cek status container:**
  ```bash
  docker compose ps
  ```

- **Melihat log aplikasi secara realtime:**
  ```bash
  docker compose logs -f app
  ```

- **Melihat log database:**
  ```bash
  docker compose logs -f db
  ```

---

## 5. Menghentikan atau Merestart Aplikasi

- **Restart aplikasi:**
  ```bash
  docker compose restart app
  ```

- **Matikan aplikasi sementara:**
  ```bash
  docker compose down
  ```

- **Update code terbaru dan deploy ulang:**
  ```bash
  git pull
  docker compose up -d --build
  ```
*(Data database aman tersimpan di volume Docker `pgdata`)*
