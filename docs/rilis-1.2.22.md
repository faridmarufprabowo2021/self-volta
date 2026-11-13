# Rilis 1.2.22+34 — To-Do baru, Study & Fokus, nada dering notifikasi

Tanggal build: 13 November 2026
Berkas: `releases/app-release-1.2.22+34-arm64.apk`

| Item | Nilai |
| --- | --- |
| versionName / versionCode | `1.2.22` / `34` |
| Ukuran | 25.359.350 byte (24,18 MiB) |
| SHA-256 | `57CA857F785BB6E4D718DCE9ECCB55EC1219602F541751A93F9967F28CFE91B7` |
| Sertifikat | `CN=SELF VOLTA` (alias `selfvolta`), SHA-256 `56:59:A4:F5:…:5F:66` |
| ABI | arm64-v8a (lib inti: `libflutter.so` 11,7 MB + `libapp.so` 9,0 MB); 2 lib kecil lain hanya `libdatastore_shared_counter.so` 4–7 KB |
| Izin | POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, RECEIVE_BOOT_COMPLETED, VIBRATE (sama seperti 1.2.21) |
| Nada dering | `res/raw/notif_{ding,chime,lembut}.wav` **terverifikasi ada** di ZIP APK (33/46/42 KB) |

## Apa yang berubah

### 1. To-Do baru — bergaya planner [DART]

- Header teal tua dengan judul hari, jumlah tugas, dan tombol **Tambah**.
- **Strip tanggal** seminggu (Sen–Min) dengan titik penanda hari yang punya tugas;
  ketuk tanggal untuk melihat hari itu (judul & tanggal di header ikut berubah).
- **Kartu target** hari ini + kalimat penyemangat sesuai progres.
- **Chip kategori** (Semua / Pekerjaan / Pribadi / Belajar / Kesehatan) dengan
  jumlah tugas.
- **Daftar tugas berjam** dikelompokkan Pagi / Siang / Sore / Malam / Tanpa jam /
  Selesai, masing-masing dengan jam, kategori, prioritas, XP, ikon pengingat,
  dan penanda "Telat".
- Urutkan dengan satu ketukan: **Jam → Prioritas → Judul**.
- Swipe kiri untuk hapus, dengan **Urungkan** di snackbar.
- Editor baru: pilih tanggal cepat, **Pilih aktivitas** (grid 2 kolom),
  prioritas, jam + pengingat (otomatis ON begitu jam diisi), bonus XP
  (di-clamp 0–10.000, pemisah ribuan).
- CTA **Sesi fokus** di bawah daftar → membuka halaman Study.

### 2. Study & Fokus [DART]

- Tambah mata pelajaran/aktivitas belajar + **target menit per minggu**
  (2/3/5/10 jam).
- **Timer fokus** 15/25/50 menit dengan lingkaran progres; sesi otomatis
  tercatat saat timer selesai.
- Tombol **+15 menit** untuk mencatat sesi manual.
- **Grafik 7 hari** dan progres mingguan per mapel.
- Hapus mapel akan menghapus riwayat sesinya (dengan konfirmasi).
- Bisa dibuka dari drawer **Study & Fokus** atau CTA di halaman To-Do.

### 3. Nada dering notifikasi [DART + RES]

- Sheet **Notifikasi** (dari ikon lonceng di header To-Do, tile di Profil, atau
  ikon di kartu tugas): status izin, **nada dering**, getar, tes nada, dan
  jadwal pengingat latihan.
- Pilihan nada: **Nada sistem** (default, sebelum diubah), **Ding**, **Chime**,
  **Lembut**. Ketuk untuk mendengar contoh; tombol "Tes nada sekarang" untuk
  memutar ulang.
- Aset `res/raw/notif_ding.wav`, `notif_chime.wav`, `notif_lembut.wav`
  ([NATIVE/RES], dibundel ke APK) + `res/raw/keep.xml` agar resource shrinker
  R8 tidak menghapusnya (referensinya hanya dari Dart, jadi tak terlihat
  shrinker).
- Android mengunci **suara dan getar** sebuah kanal setelah kanal dibuat, jadi id
  kanal memuat keduanya (`todo_<nada>_<getar|senyap>_v2`,
  `latihan_<nada>_<getar|senyap>_v2`) dan semua pengingat dijadwalkan ulang
  otomatis saat pilihan berubah.

### 4. Perbaikan

- Kartu tugas tidak lagi memicu `BoxConstraints forces an infinite height`
  (baris kartu kini memakai `IntrinsicHeight`), yang sebelumnya membuat kartu
  gagal dirender di layar sempit.
- Batang grafik Study tidak lagi meluber 1 px saat ukuran teks sistem 1,3×
  (tinggi batang kini mengikuti ruang tersisa).
- Audit layout sekarang menangkap **semua** exception Flutter, bukan hanya
  pesan "overflowed" — bug di atas sebelumnya lolos dari audit.
- Versi di drawer & Profil diambil dari `APP_VERSION` sehingga tidak bisa
  berbeda lagi.
- APK 1.2.22 dicek isinya: `res/raw/notif_*.wav` **ada** di dalam ZIP
  (sebelum `keep.xml` ditambahkan, ketiganya hilang dari APK release).

## Kompatibilitas data

Skema `sv_v1` hanya **menambah** key opsional: `notifSound`, `notifVibrate`,
`studySubjects`, `studySessions`. Data lama tanpa key tersebut tetap terbaca
dengan nilai default (`sistem`, getar ON, daftar study kosong). Tidak ada
migrasi yang menghapus data.

## Verifikasi

| Uji | Hasil |
| --- | --- |
| `flutter analyze` | 0 error, 0 warning (56 info) |
| `flutter test` | **120 test lulus** |
| `flutter test test/layout_audit_test.dart` | **72 test lulus** (15 halaman + 3 sheet × ukuran/font) |
| Notifikasi asli di HP | **BELUM DIUJI DI HP** |
| Bunyi nada dering di HP | **BELUM DIUJI DI HP** |

## Cara pasang

- Dari **1.2.21+33** (sudah bertanda tangan `selfvolta`): install langsung di
  atasnya, data tetap.
- Dari **1.2.20+32 atau lebih lama** (bertanda tangan Android Debug): wajib
  ekspor JSON → uninstall → install APK ini → impor JSON → buka ulang app.
- Setelah impor, buka ulang app sekali agar semua pengingat dijadwalkan ulang.

## Uji di HP (checklist)

1. Buka app pertama kali → dialog izin notifikasi muncul **sekali**. Izinkan.
2. To-Do → ikon lonceng → pilih **Ding** → contoh nada terdengar.
   Ganti ke **Nada sistem** → contoh memakai nada bawaan HP.
3. Buat tugas dengan jam 2 menit ke depan → notifikasi muncul walau app
   ditutup/layar mati; bunyinya sesuai nada yang dipilih.
4. Latihan → pil jam di header, atau sheet Notifikasi → ubah hari & jam →
   notifikasi "Waktunya latihan" muncul sesuai jadwal.
5. Reboot HP → pengingat tetap terjadwal.
6. To-Do: buat tugas, selesaikan, swipe untuk hapus lalu **Urungkan** — tugas
   kembali di posisi semula.
7. Study: tambah mapel, mulai sesi 15 menit, pastikan grafik & progres mingguan
   bertambah.
