# Menjaga keystore rilis SELF VOLTA

Dokumen ini untuk **kamu sendiri**, bukan untuk pengguna aplikasi. Baca sekali
sekarang, lalu simpan salinan di tempat aman.

## Kenapa ini penting

APK/AAB Android harus ditandatangani kunci yang **sama** setiap kali update.
Kunci itu disimpan di berkas `.jks`. Kalau berkas atau password-nya hilang:

- Play Store menolak update dari kunci berbeda;
- pengguna tidak bisa "menimpa" aplikasi lama dengan versi baru;
- satu-satunya jalan adalah uninstall lalu install ulang — dan **data di HP
  ikut terhapus** (kecuali sudah diekspor).

Tidak ada cara memulihkan keystore. Tidak ada "lupa password" untuk keystore.

## Berkas yang terlibat

| Berkas | Isi | Ada di repo? |
| --- | --- | --- |
| `android/app/selfvolta-release.jks` | kunci privat + sertifikat | tidak (gitignored) |
| `android/key.properties` | password, alias, nama file keystore | tidak (gitignored) |
| `android/app/build.gradle.kts` | membaca `key.properties`, memakai `signingConfig "release"` | ya |

`android/key.properties` berisi 4 baris:

```
storePassword=...
keyPassword=...
keyAlias=selfvolta
storeFile=selfvolta-release.jks
```

Tanpa `key.properties`, build release **gagal** dengan pesan jelas. Ini
disengaja supaya tidak ada APK "release" yang diam-diam ditandatangani kunci
debug.

## Cara mencadangkan (lakukan sekarang, butuh 5 menit)

1. Siapkan satu **folder cadangan** di luar folder proyek, misalnya
   `C:\Users\Asus\selfvolta-keystore-backup\` (sudah dibuat saat Fase 1).
2. Salin ke folder itu:
   - `android/app/selfvolta-release.jks`
   - `android/key.properties`
   - dokumen ini.
3. Simpan folder itu di **dua tempat berbeda**, misalnya:
   - flashdisk / kartu SD, dan
   - Google Drive pribadi (folder privat, bukan "siapa saja yang punya link").
4. Simpan **password keystore** di password manager (Bitwarden, KeePass, atau
   Google Password Manager). Catat dengan nama entri:
   "SELF VOLTA — keystore release (alias: selfvolta)".
5. Uji cadangan tanpa merusak apa pun:

   ```powershell
   keytool -list -v -keystore "D:\cadangan\selfvolta-release.jks" -alias selfvolta
   ```

   Kalau sertifikat muncul, cadangan + password cocok.

**Jangan** menaruh password di file teks di dalam folder yang ikut di-upload
ke tempat publik, dan jangan pernah meng-commit `.jks`/`key.properties`.

## Memindahkan proyek ke komputer lain

1. Salin seluruh folder proyek.
2. Salin `selfvolta-release.jks` ke `android/app/`.
3. Buat ulang `android/key.properties` (4 baris di atas) dengan password dari
   password manager.
4. Jalankan `flutter build apk --release`, lalu cek sertifikatnya:

   ```powershell
   cd android
   .\gradlew signingReport
   ```

   Baris `Variant: release` harus menampilkan SHA-256 yang **sama** dengan
   hasil `keytool -list -v` di atas. Kalau berbeda, build akan ditolak toko
   atau tidak bisa menimpa aplikasi lama.

## Masa berlaku

Sertifikat dibuat dengan masa berlaku 10.000 hari (±27 tahun) dan RSA 2048.
Itu jauh melewati perkiraan umur aplikasi. Kalau suatu saat perlu kunci baru,
kunci lama tetap harus disimpan selama masih ada pengguna versi lama.

## Migrasi ke APK bertanda tangan baru

Rilis bertanda tangan pertama akan dipasang **menimpa** versi debug-signed
yang sekarang terpasang? **Tidak bisa.** Android menganggapnya aplikasi lain
(paket sama, tanda tangan beda), jadi instalasi akan gagal atau meminta
uninstall. Urutan yang benar:

1. Buka SELF VOLTA versi lama.
2. Profil → **Ekspor Data (JSON)**. Simpan file, misalnya
   `selfvolta-backup-20261110-2015.json`, ke Download atau Drive.
3. Buka file itu sekali (opsional) untuk memastikan ukurannya wajar (> 10 KB
   bila sudah banyak data).
4. **Uninstall** SELF VOLTA.
5. Install APK rilis baru (bertanda tangan keystore ini).
6. Buka aplikasi → Profil → **Impor Data (JSON)** → pilih file tadi →
   periksa ringkasan (jumlah transaksi/tugas) → **Impor & Timpa**.
7. Cek beberapa hal: total pengeluaran bulan ini, daftar tugas, XP/streak,
   dan satu jadwal pengingat.

Data lama otomatis dicadangkan ke `sv_v1_bak` sebelum impor, jadi kalau salah
memilih file masih ada jalan kembali (lihat `docs/` pada laporan Fase 1).

## Kalau terjadi hal buruk

- **HP hilang / aplikasi ter-uninstall:** install ulang dari APK rilis, lalu
  impor file JSON terakhir. Tanpa file ekspor, data tidak bisa dipulihkan.
- **`sv_v1` rusak:** aplikasi otomatis menyalin data rusak ke
  `sv_v1_corrupt_<tanggal>` dan mencoba `sv_v1_bak`, lalu menampilkan dialog.
  Segera lakukan Ekspor Data setelah dialog itu muncul.
- **Lupa password keystore:** keystore tidak bisa dipakai lagi. Simpan
  cadangan password di dua tempat sejak awal.
