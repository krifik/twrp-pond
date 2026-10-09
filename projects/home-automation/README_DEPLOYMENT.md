# Panduan Deployment Background - Home Automation

Sistem deployment background ini memungkinkan aplikasi Home Automation (Backend Go + Frontend React) berjalan secara terus-menerus di latar belakang (*background service*) tanpa perlu membiarkan jendela terminal CMD atau PowerShell terbuka.

---

## 🚀 Perintah Cepat (Tinggal Klik / Jalankan)

Tersedia file `.bat` (bisa langsung di-double click di Windows Explorer) dan `.ps1`:

| Script (.bat) | Script (.ps1) | Fungsi |
| :--- | :--- | :--- |
| **`deploy.bat`** | `deploy.ps1` | **Full Deploy**: Build Frontend Vite + Kompilasi Go Binary + Jalankan di Background |
| **`start-background.bat`** | `start-background.ps1` | Menyalakan server di background (tanpa popup jendela) |
| **`status.bat`** | `status.ps1` | Memeriksa status (PID, RAM, CPU, Port 3000, Health HTTP, dan Log realtime) |
| **`stop-background.bat`** | `stop-background.ps1` | Mematikan server background dengan aman |
| **`restart-background.bat`** | `restart-background.ps1` | Me-restart server background |

---

## 🌐 Akses Aplikasi

Setelah dijalankan di background, Anda dapat mengakses:
- **Web App (Frontend Single Page App)**: [http://localhost:3000](http://localhost:3000)
- **Dokumentasi API Swagger**: [http://localhost:3000/docs](http://localhost:3000/docs)
- **WebSocket Telemetry Stream**: `ws://localhost:3000/ws`

---

## 📋 Monitoring & Log

Seluruh output console, status Fiber, request HTTP, dan aktivitas background worker dicatat secara otomatis ke file log:
- **Lokasi Log**: `backend/logs/server.log`

Untuk melihat log secara realtime (*live tail*):
```powershell
Get-Content -Path .\backend\logs\server.log -Wait -Tail 20
```

---

## ⚡ Opsi Alternatif: Process Manager PM2

Jika Anda lebih menyukai process manager seperti PM2 untuk pemantauan performa dan auto-restart saat crash:
```bash
# Menjalankan dengan PM2 (menggunakan npx tanpa instalasi global)
npx pm2 start ecosystem.config.cjs

# Memeriksa status PM2
npx pm2 status

# Melihat log PM2
npx pm2 logs

# Menghentikan PM2
npx pm2 stop home-automation
```

---

## 🔄 Otomatis Berjalan Saat Komputer Menyala (Windows Auto-Start)

Agar server Home Automation otomatis aktif setiap kali komputer Windows dinyalakan / login:

1. Tekan tombol `Win + R`, ketik `shell:startup`, lalu tekan **Enter**.
2. Klik kanan di dalam folder Startup > **New** > **Shortcut**.
3. Pada kolom lokasi, arahkan ke file:
   `c:\projects\home-automation\start-background.bat`
4. Beri nama shortcut misalnya `Home Automation Service`.
5. Klik **Finish**. Sekarang sistem akan otomatis berjalan di background setiap komputer booting.
