# 🤖 DevOps & N8N Automation Guide - SIMHPSB

Panduan lengkap untuk setup dan konfigurasi N8N workflows automation untuk sistem monitoring stok dan AI Agent.

---

## 📋 Overview Workflows

| # | Workflow | Fungsi | Schedule | Status |
|---|----------|--------|----------|--------|
| 1️⃣ | **Stok Alert** | Monitoring otomatis tiap jam, trigger alert jika stok rendah | Tiap jam | Todo |
| 2️⃣ | **AI Agent Chat** | Chat tanya jawab stok pakai LLM (Google Gemini) | On-Demand | Todo |

---

## 🐳 Prerequisites Setup

### **1. Docker Desktop Sudah Running**

Cek status:
```cmd
docker compose ps
```

Semua services harus **Up**:
- ✅ simhpsb_app
- ✅ simhpsb_db
- ✅ simhpsb_redis
- ✅ simhpsb_n8n
- ✅ simhpsb_phpmyadmin
- ✅ simhpsb_nginx

### **2. N8N Sudah Accessible**

Buka browser:
```
http://localhost:5678
```

Setup initial login (first time):
- Email: `admin@simhpsb.com`
- Password: `simhpsb123`

---

## 🚀 Setup Workflows

### **Workflow 1️⃣: Stok Alert (Monitoring Tiap Jam)**

**Tujuan:** Monitoring stok setiap jam, trigger alert jika stok di bawah batas minimum.

**Steps di N8N:**

#### **1. Buat Workflow Baru**
- Klik **"New Workflow"**
- Nama: `Stok Alert - Hourly Monitoring`

#### **2. Add Trigger: Cron Schedule**
1. Add Node → Search **"Cron"** → Pilih **"Cron"**
2. Config:
   - **Time Zone:** `Asia/Jakarta`
   - **Frequency:** `Every Hour`
   - **Hour:** `*` (setiap jam)
   - **Minute:** `0` (tepat di menit 0)

#### **3. Add Node: Database Query**
1. Add Node → Search **"MySQL"** → Pilih **"MySQL"**
2. Config:
   - **Connection:** Buat baru → 
     - Host: `db`
     - Port: `3306`
     - Database: `simhpsb_db`
     - User: `root`
     - Password: `root`
   - **Operation:** `Execute Query`
   - **Query:**
   ```sql
   SELECT s.id, s.komoditas, s.jumlah_stok, s.batas_minimum, g.nama_gudang
   FROM stok s
   JOIN gudang g ON s.gudang_id = g.id
   WHERE s.jumlah_stok < s.batas_minimum
   ORDER BY s.jumlah_stok ASC
   ```

#### **4. Add Condition: Filter Alert**
1. Add Node → Search **"If"** → Pilih **"If"**
2. Condition: `Data from previous node > 0` (ada stok rendah)

#### **5. Add Node: Create Alert (True Path)**
1. Add Node → Search **"HTTP Request"** → Pilih **"HTTP Request"**
2. Config:
   - **Method:** `POST`
   - **URL:** `http://app:8000/api/alert`
   - **Authentication:** `Bearer Token`
   - **Token:** (gunakan JWT token dari Laravel)
   - **Body (JSON):**
   ```json
   {
     "komoditas": "{{ $json.komoditas }}",
     "stok_saat_ini": "{{ $json.jumlah_stok }}",
     "batas_minimum": "{{ $json.batas_minimum }}",
     "catatan": "Stok {{ $json.komoditas }} di gudang {{ $json.nama_gudang }} di bawah batas minimum"
   }
   ```

#### **6. Add Node: Send Email Notification (Optional)**
1. Add Node → Search **"Email"** → Pilih **"Send Email"**
2. Config:
   - **From:** `admin@simhpsb.com`
   - **To:** `admin@simhpsb.com`
   - **Subject:** `🚨 ALERT: Stok {{ $json.komoditas }} Rendah`
   - **Body:**
   ```
   Gudang: {{ $json.nama_gudang }}
   Komoditas: {{ $json.komoditas }}
   Stok Saat Ini: {{ $json.jumlah_stok }} kg
   Batas Minimum: {{ $json.batas_minimum }} kg
   
   Mohon segera lakukan pengisian stok!
   ```

#### **7. Save & Activate**
- Klik **"Save"**
- Klik **"Activate"** (toggle ke ON)

✅ Workflow akan berjalan otomatis setiap jam!

---

### **Workflow 2️⃣: AI Agent Chat (LLM untuk Tanya Jawab Stok)**

**Tujuan:** Chat bot AI yang bisa jawab pertanyaan tentang stok, panen, margin, dll.

**Steps di N8N:**

#### **1. Buat Workflow Baru**
- Nama: `AI Agent - Stok Q&A Chatbot`

#### **2. Add Trigger: Webhook (Chat Interface)**
1. Add Node → **"Webhook"**
2. Config:
   - **HTTP Method:** `POST`
   - **Path:** `/webhook/ai-chat`

#### **3. Add Node: Get Chat Context**
1. Add Node → **"MySQL"**
2. Query untuk ambil context (contoh: total stok, panen hari ini, etc):
   ```sql
   SELECT 
     (SELECT COUNT(*) FROM petani) as total_petani,
     (SELECT SUM(jumlah_stok) FROM stok) as total_stok,
     (SELECT COUNT(*) FROM panen WHERE DATE(tanggal_panen)=CURDATE()) as panen_hari_ini,
     (SELECT SUM(jumlah_panen) FROM panen WHERE DATE(tanggal_panen)=CURDATE()) as kg_panen_hari_ini
   ```

#### **4. Add Node: Google Gemini / OpenAI LLM**
1. Add Node → Search **"OpenAI"** atau **"Google Gemini"** (jika tersedia)
2. Config:
   - **API Key:** Dapatkan dari provider LLM
   - **Model:** `gpt-4` / `gemini` / `gemini-pro`
   - **System Prompt:**
   ```
   Anda adalah AI Assistant untuk sistem SIMHPSB (Sistem Informasi Manajemen Hasil Pertanian dan Stok Beras).
   
   Data sistem saat ini:
   - Total Petani: {{ $json.total_petani }}
   - Total Stok: {{ $json.total_stok }} kg
   - Panen Hari Ini: {{ $json.panen_hari_ini }} kali ({{ $json.kg_panen_hari_ini }} kg)
   
   Jawab pertanyaan user tentang stok, panen, dan sistem dengan singkat dan jelas.
   Gunakan bahasa Indonesia.
   ```
   - **User Message:** `{{ $json.question }}`

#### **5. Add Node: Save Chat History (Optional)**
1. Add Node → **"MySQL"**
2. Simpan history chat untuk analisis

#### **6. Add Node: Return Response**
1. Add Node → **"Respond to Webhook"**
2. Response format:
   ```json
   {
     "status": "success",
     "answer": "{{ $json.response }}",
     "timestamp": "{{ $now }}"
   }
   ```

#### **7. Save & Activate**

**Gunakan di Frontend:**

```javascript
// Contoh: Gunakan di chat interface
async function askAI(question) {
  const response = await fetch('http://localhost:5678/webhook/ai-chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ question: question })
  });
  
  const data = await response.json();
  console.log('AI Answer:', data.answer);
}

// Contoh pertanyaan:
// "Berapa total stok beras kami?"
// "Panen hari ini berapa kg?"
// "Petani mana yang paling produktif?"
```

✅ Chat bot AI siap menjawab pertanyaan stok!

---

## 🔗 Koneksi Database N8N

**Semua workflow terhubung ke database:**

```
N8N Container → MySQL Container (db:3306)
  ├─ Database: simhpsb_db
  ├─ User: root
  ├─ Password: root
  └─ Auto-retry connection: enabled
```

**Konfigurasi koneksi MySQL di N8N:**

1. Buka N8N → Add Node → MySQL
2. Klik **"Create New MySQL Connection"**
3. Isi:
   - **Host:** `db`
   - **Port:** `3306`
   - **Database:** `simhpsb_db`
   - **User:** `root`
   - **Password:** `root`
4. Klik **"Test Connection"** → Harus berhasil ✅
5. Klik **"Create"**

---

## 🧪 Testing Workflows

### **Test Stok Alert Workflow**

```powershell
# Jalankan query untuk insert stok di bawah minimum
docker compose exec db mysql -u root -proot simhpsb_db -e "
INSERT INTO stok (gudang_id, komoditas, jumlah_stok, batas_minimum, tanggal_update)
VALUES (1, 'Beras', 100, 500, NOW())
"

# Trigger workflow manual di N8N atau tunggu next hourly schedule
# Cek email atau alert table untuk verifikasi
docker compose exec db mysql -u root -proot simhpsb_db -e "SELECT * FROM alerts ORDER BY id DESC LIMIT 5"
```

### **Test AI Chat**

```powershell
# Test POST ke AI webhook
curl -X POST http://localhost:5678/webhook/ai-chat ^
  -H "Content-Type: application/json" ^
  -d "{\"question\":\"Berapa total stok beras kami?\"}"

# Response: AI answer tentang stok
```

---

## 📊 Monitoring & Logs

### **View N8N Workflow Logs**

```powershell
# Real-time logs dari N8N container
docker compose logs -f n8n

# View app (Laravel) logs
docker compose logs -f app

# View database logs
docker compose logs -f db
```

### **Check N8N Webhook History**

1. Buka N8N → Klik workflow
2. Tab **"Executions"** → lihat history run
3. Klik execution untuk lihat detail & logs

### **Database Monitoring**

```powershell
# Akses phpMyAdmin
# http://localhost:8080
# User: root, Password: root
```

---

## 📌 Deployment Checklist

- [ ] Docker Desktop running, semua services Up
- [ ] N8N accessible di http://localhost:5678
- [ ] MySQL connection test passed di semua workflows
- [ ] Stok Alert workflow activated & tested
- [ ] AI Chat workflow activated & LLM API key set
- [ ] All email configurations working (if using email)
- [ ] Webhook URLs updated di production
- [ ] Database backups automated (optional)

---

## 🔐 Security Best Practices

1. **API Keys**
   - Store LLM provider keys di environment variables
   - Jangan commit API keys ke Git

2. **Database Credentials**
   - Use `.env` untuk sensitive data
   - Ganti default password di production

3. **Webhook URLs**
   - Change webhook paths untuk production
   - Add authentication layer (Bearer token)

4. **N8N Login**
   - Change default password
   - Enable 2FA jika tersedia

---

## 📞 Troubleshooting

### **N8N tidak bisa connect ke database**

```powershell
# Cek status MySQL container
docker compose ps db

# Cek logs MySQL
docker compose logs db

# Restart MySQL
docker compose restart db
```

### **Workflow execution failed**

1. Buka N8N → Executions tab
2. Klik execution yang failed
3. Lihat error message & debug
4. Cek database query syntax
5. Cek API responses dari HTTP nodes

### **Email tidak terkirim**

1. Setup SMTP credentials di N8N
2. Atau gunakan service: Mailtrap / SendGrid / AWS SES
3. Test kirim email manual

---

## 📚 Resources

- **N8N Documentation:** https://docs.n8n.io
- **N8N Community:** https://community.n8n.io
- **OpenAI API:** https://platform.openai.com/docs
- **Google Gemini / OpenAI:** https://platform.openai.com/docs
- **Laravel API Docs:** `http://localhost:8000/api/docs` (jika ada)

---

## ✅ Next Steps

1. **Sprint 3 (Current):**
   - ✅ Setup n8n di Docker (#111)
   - ✅ Buat koneksi n8n ke database simhpsb_db (#112)
   - 🔄 Implement Stok Alert workflow (#113)
   - 🔄 Implement AI Agent workflow (#114)
   - 🔄 Testing workflow n8n (#115)

2. **Sprint 4:**
   - Testing all workflows
   - Complete documentation
   - Production deployment
   - Performance optimization

---

**Created:** May 30, 2026  
**Last Updated:** May 30, 2026  
**Team:** DevOps - Alamsyah  
**Status:** In Progress 🚀
