# 🚀 Panduan Deploy SIMHPSB ke VPS Production

Domain: **https://simhp.my.id** | SSL via **Cloudflare Flexible**

---

## Prasyarat

- ✅ VPS Ubuntu 22.04 LTS sudah beli
- ✅ Domain `simhp.my.id` sudah diarahkan ke IP VPS di Cloudflare
- ✅ Cloudflare SSL mode: **Flexible**
- ✅ Docker Hub account sudah ada
- ✅ Docker Desktop terinstall di komputer lokal

---

## BAGIAN A: Setup VPS (Hanya Sekali)

SSH ke VPS kamu, lalu jalankan perintah berikut:

### 1. Install Docker

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Install Docker Compose

```bash
sudo apt-get install -y docker-compose-plugin
docker compose version  # verifikasi
```

### 3. Setup Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status
```

> ⚠️ Port 3306 (MySQL), 6379 (Redis), dan 5678 (n8n) **TIDAK** dibuka ke publik.

### 4. Clone Repository

```bash
git clone https://github.com/USERNAME/REPO.git /var/www/simhpsb
cd /var/www/simhpsb/pangan_web
```

### 5. Setup Environment Production

```bash
cp .env.production .env
nano .env   # Edit semua placeholder GANTI_... dengan nilai asli
```

Yang **WAJIB** diisi:
- `DB_PASSWORD` — password MySQL yang kuat
- `REDIS_PASSWORD` — password Redis yang kuat
- `JWT_SECRET` — jalankan: `openssl rand -base64 48`
- `GEMINI_API_KEY` — dari Google AI Studio
- `N8N_AUTH_USER` & `N8N_AUTH_PASSWORD` — untuk login n8n
- `DOCKERHUB_USERNAME` — username Docker Hub kamu

---

## BAGIAN B: Deploy (Dari Komputer Lokal)

### 1. Edit deploy.sh

Buka [`deploy.sh`](./deploy.sh) dan ganti `GANTI_DENGAN_USERNAME_DOCKERHUB_KAMU` dengan username Docker Hub kamu.

### 2. Build & Push Image ke Docker Hub

Jalankan dari folder `pangan_web` di Git Bash / WSL:

```bash
chmod +x deploy.sh
./deploy.sh          # push tag :latest
# atau
./deploy.sh v1.0.0   # push dengan tag versi
```

### 3. Pull & Jalankan di VPS

SSH ke VPS, lalu:

```bash
cd /var/www/simhpsb/pangan_web

# Pull image terbaru dari Docker Hub
docker compose -f docker-compose.prod.yml pull

# Jalankan semua service
docker compose -f docker-compose.prod.yml up -d

# Cek status
docker compose -f docker-compose.prod.yml ps
```

---

## BAGIAN C: Verifikasi

```bash
# Cek semua container running
docker compose -f docker-compose.prod.yml ps

# Cek log Laravel (jika ada error)
docker logs simhpsb_app -f

# Cek log Nginx
docker logs simhpsb_nginx -f
```

Buka browser: **https://simhp.my.id** ✅

---

## BAGIAN D: Update Aplikasi (Deploy Ulang)

Setiap ada perubahan kode:

**Di komputer lokal:**
```bash
./deploy.sh          # build & push image baru
```

**Di VPS:**
```bash
cd /var/www/simhpsb/pangan_web
git pull             # ambil perubahan terbaru
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d --no-deps --build app
```

---

## Troubleshooting

| Masalah | Solusi |
|---|---|
| Container `app` exit/restart | `docker logs simhpsb_app` untuk cek error |
| Site tidak bisa diakses | Cek Cloudflare DNS sudah pointing ke IP VPS |
| SSL tidak aktif | Pastikan Cloudflare mode = **Flexible** dan proxy ☁️ aktif |
| Database tidak terhubung | `docker exec simhpsb_db mysql -uroot -p` |
| Redis error | `docker exec simhpsb_redis redis-cli -a PASSWORD ping` |

---

## Port yang Digunakan

| Service | Internal | Publik |
|---|---|---|
| Nginx (Web) | 80 | ✅ 80 (via Cloudflare → HTTPS) |
| MySQL | 3306 | ❌ Tidak expose |
| Redis | 6379 | ❌ Tidak expose |
| n8n | 5678 | ⚠️ 127.0.0.1 only (akses via SSH tunnel jika perlu) |
