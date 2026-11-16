# BRIEF REDESAIN BERANDA & SISTEM ALARM FULLSCREEN (SELF VOLTA)
**Tujuan:** 
1. Redesain antarmuka Beranda sesuai konsep "Kertas & Tinta" (Clean, Focused, Anti-Slop).
2. **FITUR KRUSIAL:** Layar Alarm Fullscreen Interaktif (Menyala saat layar mati / Lockscreen + Slide-to-Complete) terhubung langsung ke To-Do & Tracker Rutinitas Bulanan.

---

## 🚨 FITUR WAJIB: FULLSCREEN ALARM SCREEN (WAKE-UP / LOCKSCREEN)
Sesuai referensi visual user (`media_1794542093241_cb5b3274.png` dan `media_1794542127124_da363693.jpg`):

### 1. Perilaku Alarm (Saat Layar HP Mati / Terkunci):
- **TAMPIL SAAT LAYAR MATI:** Ketika jam tiba (misal `04:11`), alarm **MEMBANGUNKAN LAYAR HP YANG SEDANG MATI/TERKUNCI** (`turnScreenOn`, `showWhenLocked`, `fullScreenIntent`). Layar otomatis hidup dan langsung memunculkan tampilan alarm gelap ini persis jam alarm bawaan HP (Clock App).
- Jika user sedang membuka aplikasi, layar alarm ini muncul sebagai dialog/halaman fullscreen pop-up instan.

### 2. Desain Layar Alarm (Fullscreen Dark Minimalist):
- **Layar Gelap Pekat (OLED Black `#121212` / `#000000`).**
- **Kop Waktu:** Hari & Tanggal (contoh: `Jum, 13 Nov`) di atas jam digital raksasa `04:11` (putih bold).
- **Nama Rutinitas:** Titik aksen cyan + Nama tugas (contoh: `● Bangun (kalo bisa tahajjud)`).
- **Komponen Utama "SLIDE TO COMPLETE":**
  - Slider kapsul horizontal lebar: Tombol bulat merah-oranye (`#FF5722` / Amber-Coral) dengan ikon centang `✓`.
  - Label teks di sampingnya: `Selesaikan` (digeser/slide ke kanan oleh user untuk mematikan alarm dan menyelesaikan tugas).
- **Tombol Tambahan di Bawah:**
  - Tombol kiri: `+5 mnt` (Snooze 5 menit).
  - Tombol kanan: `Matikan` (Dismiss / mematikan suara tanpa menandai selesai).

### 3. Logika Koneksi Otomatis ke Tracker & To-Do:
- Saat user menggeser slider **"Selesaikan"**:
  1. Suara alarm berhenti seketika.
  2. Muncul dialog/layar sukses selebrasi (Ilustrasi High-Five 🙌 + Teks `● Bangun (kalo bisa tahajjud)` + `Rutinitas selesai!` + Tombol `OK`).
  3. **OTOMATIS MENCENTANG To-Do terkait** di `AppState.I.todos` (Status tugas jadi `done = true`).
  4. **OTOMATIS TERCATAT KE TRACKER RUTINITAS BULANAN** (Day-by-day streak tracker), sehingga user bisa melihat histori checklist harian & bulanan yang tuntas.

---

## ⚠️ PANDUAN NATIVE & TEKNIS
- Untuk izin membangunkan layar mati di Android, pastikan `AndroidManifest.xml` mendukung `USE_FULL_SCREEN_INTENT` & `WAKE_LOCK`.
- Seluruh kode Dart harus lolos `flutter analyze` (**No issues found**).

---

## 🎨 PALET WARNA BERANDA ("Kertas & Tinta")
- **Canvas / Background:** `#F8F9FA`
- **Kartu Konten:** `#FFFFFF`
- **Border / Garis Tipis:** `#E8ECEF`
- **Teks Utama / Jangkar Gelap:** `#143E48` (Deep Petrol Navy)
- **Teks Sekunder / Label Kicker:** `#6B7280` (Slate)
- **Aksen Progres / Checklist Selesai:** `#F5A623` (Amber)
- **Aksen Teks Jam & Terlewat (High-Contrast):** `#B45309` (Dark Amber)
- **Aksen Aktif / Terpilih:** `#0284C7` (Cyan), Background Pil `#EBF5F8`
- **Aturan Warna:** Maksimal 2 warna aksen terlihat per layar. Hapus semua ubin pastel warna-warni dan badge cuaca mencolok.

---

## 🏗️ STRUKTUR LAYOUT BERANDA DARI ATAS KE BAWAH

### 1. KOP / HEADER (Sapaan Bersih)
- **Label Tanggal:** Huruf kapital kecil (12sp, slate `#6B7280`, letterSpacing: 0.8), contoh: `JUMAT, 13 NOVEMBER 2026`.
- **Sapaan:** "Selamat Pagi" (26sp, bold, `#143E48`, **TANPA EMOJI**).
- **Badge XP:** Di kanan sapaan, chip border tipis: `Lv 1 · 240 XP`.
- ❌ **STREAK PALSU:** Sembunyikan chip streak (`🔥 7 hari`) sampai logika streak diperbaiki.

---

### 2. KARTU JANGKAR SHOLAT (Titik Fokus Utama Layar)
> ⚠️ Jangan pecah sholat jadi 3 kartu berbeda! Satukan SEMUA informasi sholat ke dalam **SATU KARTU JANGKAR GELAP**.
- **Warna Kartu:** Solid Deep Petrol Navy `#143E48` (Radius 16, tanpa gradien).
- **Baris Atas:** 
  - Kiri: Lokasi kota sholat (ikon pin + nama kota, misal: `📍 Surakarta`).
  - Kanan: Teks cuaca/lokasi ringkas: `Solo · 29° Cerah` (teks biasa putih 70%).
  - 🔔 **ALARM SHOLAT:** Ikon lonceng (`Icons.notifications_active_outlined`, warna putih 70%). Tap membuka sheet pengaturan notifikasi (`showNotifSettingsSheet(context)`).
- **Hero Sholat:** 
  - Nama & Jam sholat berikutnya dalam ukuran besar: `Dzuhur 11:23` (FontFeature.tabularFigures()).
  - Kanan: Hitung mundur dalam pil semi-transparan: `3 j 9 m lagi`.
- **Progress Bar:** Bar tipis warna amber `#F5A623`.
- **Baris 5 Sholat Wajib:**
  - Hanya tampilkan 5 sholat fardhu dalam **SATU BARIS SEJAJAR**: `Subuh`, `Dzuhur`, `Ashar`, `Maghrib`, `Isya`.
  - Sholat aktif: **pil putih dengan teks navy**.
- **Collapsible Non-Wajib (Imsak, Terbit, Dhuha):**
  - Toggle di bawah 5 sholat: `Imsak 03:37 · Terbit 05:07 · Dhuha 05:27 ▾`.

---

### 3. KARTU "HARI INI" (Gabungan Target & To-Do)
> ⚠️ Jangan pisahkan "Target hari ini" dan "To-Do hari ini". Gabungkan menjadi **SATU KARTU PUTIH TERPADU**.
- **Warna Kartu:** Putih `#FFFFFF`, border `#E8ECEF`, radius 16.
- **Header:** Label `HARI INI` di kiri, counter progres terpadu `2 / 6` di kanan, garis progres amber tipis di bawahnya.
- **Dua Sub-bagian (Dipisah Divider Tipis):**
  1. Bagian `KEBIASAAN` (Makan Teratur, Booster BB, Air Galon).
  2. Bagian `TUGAS & TO-DO` (Daftar to-do dari `AppState.I.todos`).
- **Gaya Baris Konsisten:**
  - **Checkbox:** Lingkaran 24dp garis Navy 1.5px. Saat selesai, terisi Amber `#F5A623` dengan centang Navy.
  - **Teks:** Judul 15sp navy, subteks 13sp slate.
  - ⏰ **ALARM / JAM TO-DO:**
    - Di kanan baris tugas, tampilkan jam pengingat (`04.15`, dll) + ikon alarm kecil (`Icons.alarm_rounded`).
    - Tugas terhubung dengan sistem Alarm Fullscreen Slide-to-Complete di atas!
  - **Tugas Terlewat:** Label teks `Terlewat` dengan warna `#B45309` (Amber gelap kontras tinggi).

---

### 4. AKSI CEPAT & SEKSI LAINNYA
- Sediakan tombol akses cepat / menu makanan di bagian bawah kartu "Hari ini" dengan gaya monokrom garis rapi.

---

## 📌 CONTOH KODE PREVIEW:
👉 `lib/pages/home_preview_kertas_tinta.dart`
