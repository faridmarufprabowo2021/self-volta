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
- Satu family headline + satu body (app: Poppins + Inter, pengganti
  Fredoka/DM Sans yang tak ter-bundle). Kalau TTF Fredoka/DM Sans tersedia,
  mapping ulang di `pubspec.yaml` + `theme.dart`.
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

## 10. [DIGANTIKAN oleh §13] Warna & kontras (tema terang lama)
- Primer Allports `#006C95`, aksen Picton `#0781D1`, highlight Cyan `#01BEAF`,
  ungu Thistle, krem China Ivory; scaffold Black Haze `#F6F8F7`, kartu putih.
- Teks di atas terang ≥4.5:1 (`ink #14323F`, `mut #4E6E7C`). Error tetap merah
  baku (`#D64545`) demi kejelasan semantik.
- Radius: kartu 16, box inset 12, chip/input 12, badge 8, tombol pill 9999,
  glow hemat (satu per elemen, hanya logo V + momen achievement).

## 11. Rilis & OTA (Shorebird)
- Release: `shorebird release android --artifact apk --target-platform
  android-arm64` (+ `android-x64` bila perlu emulator). Patch:
  `shorebird patch --platforms=android --release-version=<ver>
  --allow-asset-diffs`. Patch auto-apply saat app dibuka dengan internet
  (butuh 1–2x buka-tutup). Naik versi bila ganti tema/aset besar.

## 12. [DIGANTIKAN oleh §13] Area jurnal — palet `Paper` lama
- Kanvas krem `#FBF9F5`, kartu putih, hairline hangat `#E7E2DA`; tanpa bayangan.
- Jangkar hijau tua `#16594C`; progres mint `#2E8B70`; amber `#A67C00` hanya
  untuk target/uang; coral `#C96F5C` hanya untuk keterlambatan.
- Radius: blok/kartu **20**, tile kecil 12–14, chip pil 999.
- App bar halaman berkanvas krem ikut `Paper.canvas` (bukan `Star.bg`) agar
  tidak ada sambungan dua nada; hairline bawah `Paper.hair`.
- Teks sekunder `Paper.sec`; `Paper.ter` hanya untuk ikon/chevron. Angka
  memakai `FontFeature.tabularFigures()`.
- Dilarang: gradien dekoratif, ungu, emoji di UI, dan bayangan kartu.

## 13. Dark Neumorphism (berlaku untuk seluruh aplikasi)
- **Satu nada dasar** grafit dingin `Star.bg #22262B`. Kartu, kanvas, dan sheet
  SAMA warnanya; kedalaman hanya dari sepasang bayangan (gelap kanan-bawah,
  terang kiri-atas). Satu arah cahaya di seluruh app.
- **Helper di `theme.dart`**: `Neu.raised()` (blok utama, CTA), `Neu.well()` /
  `NeuWell` (input, jalur progres, item terpilih, panel info), `Neu.flat()`.
  Baris di dalam kartu tetap datar; jangan menimbulkan semua chip.
- **Satu aksen**: amber redup `Star.star #D9A55B`. Hijau sage (`Star.success`)
  hanya untuk "selesai", koral (`Star.error`) hanya untuk error/terlambat.
  Tanpa ungu, tanpa gradien dekoratif, tanpa emoji di UI.
- Teks di atas aksen memakai `Star.onAccent`. Varian `*Ink` pada `Paper` kini
  teks TERANG di atas tint gelap (`*Soft`).
- Kontras: `ink` 12:1, `mut` 6:1, `faint` 3.4:1 di atas `bg`. Status terpilih
  harus terlihat dari warna aksen, bukan hanya kedalaman bayangan.
- Font: Manrope (variabel) untuk semua teks; angka memakai tabular figures.
- Halaman per-fitur tidak lagi punya warna sendiri (`Themes.*` diseragamkan).
