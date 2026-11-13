# Rilis 1.2.23+35 — Perbaikan notifikasi To-Do tidak muncul

Tanggal build: 13 November 2026
Berkas: `releases/app-release-1.2.23+35-arm64.apk`

| Item | Nilai |
| --- | --- |
| versionName / versionCode | `1.2.23` / `35` |
| Ukuran | 25.359.738 byte (24,18 MiB) |
| SHA-256 | `35192E31EB2524457D6CCF8D8EBC5B822D2CC04E9E2FBC7EAB4D2075483786D3` |
| Sertifikat | `CN=SELF VOLTA` (alias `selfvolta`), SHA-256 `56:59:A4:F5:…:5F:66` |

## Bug yang diperbaiki (penting)

**Pengingat To-Do terjadwal tidak pernah muncul dan tidak berbunyi.**

Penyebab: `flutter_local_notifications` versi 16 ke atas **tidak lagi**
mendeklarasikan receiver-nya sendiri di manifest plugin. Sejak itu, setiap app
wajib menambahkan sendiri:

- `com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver`
- `com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver`

Manifest app SELF VOLTA belum punya keduanya. Akibatnya `AlarmManager` tetap
menyala pada jam yang diatur, tapi broadcast-nya tidak ada yang menerima —
tidak ada notifikasi, tidak ada bunyi, tanpa pesan error sama sekali.

Kenapa terasa membingungkan saat diuji:

- Tombol **"Tes nada sekarang"** memakai `show()` yang berjalan di dalam proses
  app, tidak lewat `AlarmManager` → **selalu berhasil**, sehingga fitur terlihat
  normal.
- Yang gagal hanya jalur **terjadwal**, yaitu justru jalur yang dipakai
  pengingat tugas & pengingat latihan.

Perbaikan: kedua receiver ditambahkan ke `android/app/src/main/AndroidManifest.xml`
beserta intent-filter `BOOT_COMPLETED` dan `MY_PACKAGE_REPLACED`, supaya
pengingat juga dijadwalkan ulang setelah HP di-reboot atau app di-update.

## Tambahan

- Tombol **"Tes alarm 10 detik"** di sheet Notifikasi. Ini menguji jalur
  terjadwal yang sebenarnya (lewat `AlarmManager`), jadi bisa dipakai memastikan
  pengingat bekerja tanpa menunggu jam tugas.
- `test/android_manifest_test.dart`: penjaga regresi yang gagal bila receiver
  atau izin di atas hilang lagi dari manifest, dan bila `res/raw/keep.xml` /
  ketiga WAV nada dering hilang.

## Catatan untuk pengguna

- Nada dering: 1.2.22 sudah membundel `res/raw/notif_*.wav`; sejak 1.2.23
  keberadaannya dijaga otomatis oleh `keep.xml` + test.
- Versi lama (1.2.21 dan 1.2.22) **tidak bisa** mengirim pengingat terjadwal
  sama sekali. Wajib pasang 1.2.23.
- Setelah update, buka app sekali supaya semua pengingat dijadwalkan ulang.
- Android 12+ meminta izin **"Alarm & pengingat"**. Bila ditolak, app memakai
  alarm tidak presisi: notifikasi tetap muncul tapi bisa telat beberapa menit.
- Beberapa merek (Xiaomi/HyperOS, Oppo, Vivo, Realme, Samsung) mematikan alarm
  app latar belakang secara agresif. Bila masih tidak muncul: Setelan →
  Aplikasi → SELF VOLTA → Baterai → **Tanpa batasan / Tidak dibatasi**, dan
  izinkan **Autostart**.

## Verifikasi

| Uji | Hasil |
| --- | --- |
| `flutter analyze` | 0 error, 0 warning (56 info) |
| `flutter test` | **123 test lulus** (+3 test penjaga manifest) |
| Receiver di APK | **terverifikasi ada** (`ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`, `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`) |
| Nada dering di APK | **terverifikasi ada** (3 WAV: 33/46/42 KB) |
| versionCode / versionName | `35` / `1.2.23` |
| Notifikasi asli di HP | **BELUM DIUJI DI HP** |
