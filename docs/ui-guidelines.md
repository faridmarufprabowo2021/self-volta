# SELF VOLTA — Mobile UI Guidelines (gabungan)

Sumber: Appeon *Mobile UI Design & Development Guide* (ch02: Best Practices,
Control, Font, Image & Icon, Window for iOS) + artikel 4-point spacing
(UX Planet) + StarChart `starchart-DESIGN.md`.

## 1. Jari, bukan mouse (Fingers vs Mouse)
- Target tap min **44×44pt (≈48dp)**; pengecualian kecil hanya bila berdampingan
  kontrol besar (aturan: makin rapat → makin besar).
- Status app: tombol min 48dp, `AppText.minTouch = 48` — pertahankan.
- Hover BUKAN interaksi utama (hover SecHead/glow hanya pemanis; semua aksi
  wajib bisa lewat tap). Tooltip/efek rollover ala desktop dilarang jadi
  satu-satunya jalan.

## 2. Ukuran kontrol & tinggi baris (Control Size, Row Height)
- Tombol min **37pt**, ideal 44pt; header/footer tabel 22pt, **baris data 44pt**.
- Baris centang (makan/latihan), item transaksi, item kombinasi: tinggi sentuh
  ≥44dp. Audit tiap menambah list interaktif baru.

## 3. Spacing 4-point (kelipatan 4px)
- Skala: `4 / 8 / 12 / 16 / 24`. Gap seksi besar 16, antar-kartu 12,
  elemen terkait 8, mikro 4. (StarChart base unit 8px — subset 4pt tetap valid.)
- Margin = ruang ANTAR elemen; padding = ruang DALAM elemen.
- Normalisasi yang disetujui: `3→4, 5→4, 6→8, 9→8, 10→8(gap)/12(margin),
  11→12, 18→16, 20→16`. Nilai kelipatan-4 yang ada tidak disentuh.

## 4. Font
- Body **14–17pt**, minimum terbaca **12pt** (app: body 13.5, sekunder 12 —
  dalam batas, jangan turunkan lagi).
- Satu family untuk semua teks: **Manrope** (sudah ter-bundle di
  `pubspec.yaml`). Jangan menambah family headline terpisah.
- Sisakan ruang ekstra untuk teks (beda platform beda lebar render) —
  jangan hardcode lebar pas-pasan untuk label.

## 5. Gambar & ikon
- Format: **PNG/JPG** (`assets/images/paket_a–g.png` ✓). Fallback Material Icon
  wajib untuk tiap `Image.asset` (tanpa crash bila file hilang).
- Ukuran acuan: ikon menu/toolbar/tab ≈20px, list ≈20–30px, app icon 48px
  baseline dengan rasio densitas Android **2:3:4:6:8**
  (mdpi 48, hdpi 72, xhdpi 96, xxhdpi 144, xxxhdpi 192).
- Launcher icon: **adaptive icon** (foreground + background `#1E1B4B`,
  `mipmap-anydpi-v26`), + PNG legacy per densitas. Label tampil: SELF VOLTA.
- Tiap ikon fitur wajib ada **label teks** pendamping.

## 6. Layar & orientasi (Screen Size, Orientation, Window for iOS)
- Fungsi primer di depan; sekunder di balik tap/expand (Planning ringan +
  detail di bottom-sheet — pola ini dipertahankan).
- Wajib tahan rotasi portrait↔landscape tanpa overflow (min: tidak crash;
  target: grid paket 2 kolom saat lebar >600dp — sudah ada di Planning).
- Responsif lebar (HP kecil–tablet); jangan asumsi satu ukuran layar.

## 7. Offline & data (Intermittent connectivity, Memory)
- Offline-first: data lokal (`shared_preferences` `sv_v1`) + sinkron saat
  online (`syncData()` placeholder URL Vercel). Jangan cache melebihi kebutuhan.
- Satu window aktif (pola SDI); tanpa jendela ganda; state via `AppState.I`.

## 8. Tombol Back Android — GAP per 2026-10-10
- Saat ini Back langsung keluar app. Rencana: Back di halaman drawer →
  kembali ke Planning; Back di Planning → konfirmasi keluar (`PopScope`).

## 9. Keyboard virtual — GAP per 2026-10-10
- Utamakan pilih/centang/picker di atas ketikan. Rencana: dismiss keyboard
  saat tap di luar field; input angka pakai keyboard numerik (sudah) +
  pertahankan dropdown kategori.

## 10. Warna & kontras (Modern Clean / Editorial)
- Kanvas `Star.bg #F8FAFC`, kartu `Star.surface #FFFFFF`, garis rambut
  `Star.line #E2E8F0`, isian tenang `Star.sunken #F1F5F9`.
- Teks: `Star.ink #143E48` (utama), `Star.mut #6B7280` (sekunder),
  `Star.faint #8A94A6` (ikon/chevron). Jangan memakai hitam murni.
- Radius: kartu **16** (blok besar maks 22), kontrol 12–14, chip pil 999.
  Sheet bawah radius 24.
- Kedalaman hanya dari border tipis + satu bayangan sangat lembut
  (`Neu.shadows`). Bukan neumorphism, bukan glow, bukan gradien dekoratif.
- Warna semantik:
  - Workout — amber `#D97706` / `#F59E0B`, badge `#FEF3C7`.
  - Air — cyan `#0891B2` / `#06B6D4`, badge `#ECFEFF`.
  - Keuangan — emerald `#059669` / `#10B981`, badge `#ECFDF5`.
  - Study — teal `#0D9488`, badge `#F0FDFA`.
  - Navigasi, tautan, dan CTA memakai teal netral `Star.star #0F766E`.
- Teks di atas bidang aksen memakai `Star.onAccent` (putih). Untuk teks kecil
  di atas tint terang gunakan varian `*Ink` (mis. `Paper.mintDeep`), bukan
  aksen mentah, agar kontras ≥4.5:1.

## 11. Rilis & OTA (Shorebird)
- Release: `shorebird release android --artifact apk --target-platform
  android-arm64` (+ `android-x64` bila perlu emulator). Patch:
  `shorebird patch --platforms=android --release-version=<ver>
  --allow-asset-diffs`. Patch auto-apply saat app dibuka dengan internet
  (butuh 1–2x buka-tutup). Naik versi bila ganti tema/aset besar.

## 12. Area jurnal — palet `Paper`
- `Paper` kini alias ke token `Star`; tidak ada lagi kanvas krem/hijau tua.
  `Paper.header` = `Star.ink`, `Paper.mint` = `Star.finance`,
  `Paper.amber` = `Star.workout`, `Paper.hair` = `Star.line`.
- Angka memakai `FontFeature.tabularFigures()`. Teks sekunder `Paper.sec`,
  ikon/chevron `Paper.ter`.
- Dilarang: ungu, emoji di UI (pengecualian: chip streak `🔥` dan XP `⚡` di
  header Beranda), dan bayangan kartu ganda.

## 13. Komponen bersama (berlaku untuk seluruh aplikasi)
- **Helper di `theme.dart`**: `Neu.raised()` = kartu putih + border + bayangan
  lembut; `NeuWell` = bidang slate datar (input/jalur); `Neu.flat()` = hairline.
  Baris di dalam kartu tetap datar; jangan menimbulkan semua chip.
- **Progres**: pakai `SegmentTrack` (segmen tetap, mis. 4/10/12) untuk progres
  harian/mingguan. Jangan gradien atau bar polos tanpa alasan.
- **Tombol aksi sekunder**: latar `Star.fill`, border `Star.line`, teks tebal
  `Star.ink`; ikon panah memakai aksen pilar.
- **Header padat**: judul + badge + tautan memakai `Wrap` (bukan `Row` kaku)
  supaya turun baris di scale 2.0. Badge dalam kotak tetap wajib `FittedBox`.
- **Status terpilih** terlihat dari warna aksen + label, bukan hanya bayangan.
- Font Manrope untuk semua teks; halaman tidak boleh punya hex sendiri —
  gunakan `Star`/`Paper`/`Themes.*`.
- **Pengecualian gelap yang disengaja**: layar alarm penuh (`alarm_page.dart`)
  memakai latar OLED hitam karena muncul saat tidur/malam. Jangan dicerahkan.

## 14. Responsif & aksesibilitas teks
- Wajib bebas overflow di lebar **320 / 360 / 412 px**, text scale **1.3 / 2.0**,
  layar pendek, dan landscape. Uji lewat `test/layout_stress_test.dart`.
- Jangan mengunci tinggi kartu yang berisi teks; gunakan `IntrinsicHeight`,
  `Wrap`, `FittedBox`, atau tinggi minimum — bukan tinggi mati.
- Target sentuh ≥48dp; ikon saja tanpa label wajib punya `Tooltip`/Semantics.
