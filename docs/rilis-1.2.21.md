# Rilis 1.2.21+33 — Notifikasi To-Do & Pengingat Latihan

Tanggal build: 10 November 2026
Berkas: `releases/app-release-1.2.21+33-arm64.apk`

| Item | Nilai |
| --- | --- |
| versionName / versionCode | `1.2.21` / `33` |
| Ukuran | 25.105.594 byte (23,94 MiB) |
| SHA-256 | `861DDDABEF2A46B0655896BFC70502FA8303389A4644CB68F845CA2851D4296D` |
| Sertifikat | `CN=SELF VOLTA` (alias `selfvolta`), SHA-256 `56:59:A4:F5:…:5F:66` |
| ABI | arm64-v8a (lib inti); 3 lib kecil lain hanya `libdatastore_shared_counter.so` ~18 KB |
| Izin baru | POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, RECEIVE_BOOT_COMPLETED, VIBRATE |

## PENTING: APK lama bertanda tangan kunci DEBUG

APK 1.2.20+32 yang terpasang di HP ditandatangani **Android Debug**
(`CN=Android Debug`), sedangkan rilis ini memakai keystore `selfvolta`.
Android **menolak** update dengan kunci berbeda ("App not installed"), jadi
urutan pemasangan WAJIB:

1. **Ekspor data dulu** di app lama: Profil → Ekspor data (simpan file JSON).
2. **Uninstall** SELF VOLTA (data di HP ikut terhapus).
3. Install `app-release-1.2.21+33-arm64.apk`.
4. Buka app → Profil → Impor data → pilih file JSON tadi (mode **Gabung** agar
   aman, atau **Timpa** bila ingin persis seperti cadangan).
5. **Restart app sekali** supaya `resyncNotifications()` menjadwalkan ulang
   semua pengingat dari data hasil impor.

## Yang baru

- Notifikasi sistem untuk To-Do (satu jadwal per tugas, alarm presisi dengan
  fallback inexact bila izin ditolak).
- Pengingat latihan mingguan yang **jadwalnya diatur user**: hari (bisa lebih
  dari satu) + jam, dari halaman **Latihan** (pil jam di header) atau
  **Planning → Menu Hari Ini** (strip "Pengingat latihan"). Tersimpan di
  `sv_v1` sebagai `workoutReminderOn/Days/Min`.
- Izin notifikasi diminta **sekali** saat app pertama dibuka; bila ditolak,
  tombol "Izinkan notifikasi" tetap tersedia di kedua sheet.
- Semua jadwal disinkronkan ulang tiap app dibuka; impor/gabung data juga
  menjadwalkan ulang (To-Do + latihan).
- To-Do baru: pengingat otomatis ON, dan otomatis ON lagi saat jam dipilih.
- Versi disamakan: drawer "SELF VOLTA v1.2.21", Profil "Versi 1.2.21".

## Uji di HP (belum bisa diuji otomatis)

1. Buka app pertama kali → dialog izin notifikasi muncul **sekali**. Izinkan.
2. To-Do: buat tugas dengan jam 2 menit ke depan → notifikasi muncul walau app
   ditutup (layar mati).
3. Latihan: ketuk pil jam di header → pilih hari & jam dekat → notifikasi
   "Waktunya latihan" muncul; buka app, pil menampilkan jam yang sama.
4. Matikan pengingat → notifikasi mendatang hilang; nyalakan lagi → kembali.
5. Reboot HP → notifikasi tetap terjadwal (RECEIVE_BOOT_COMPLETED).
6. Bila notifikasi tidak muncul: Setelan Android → Aplikasi → SELF VOLTA →
   Notifikasi (izinkan), dan Alarm & pengingat (izinkan alarm presisi).
