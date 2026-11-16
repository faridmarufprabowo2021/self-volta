import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Token warna MODERN CLEAN / EDITORIAL (terang).
///
/// Prinsip (supaya tidak jadi "AI slop"):
///  * Kanvas dingin hampir putih, kartu putih murni, garis rambut slate.
///    Kedalaman datang dari border tipis + satu bayangan sangat lembut —
///    bukan neumorphism gelap, bukan gradien dekoratif.
///  * Tinta utama deep teal; teks sekunder abu slate. Satu aksen netral
///    (teal) untuk navigasi & CTA, lalu aksen semantik per pilar:
///    workout amber, air cyan, keuangan emerald.
///  * Radius 16 untuk kartu, 12–14 untuk kontrol. Tanpa ungu, tanpa glow.
class Star {
  // --- Permukaan ---------------------------------------------------------
  static const bg = Color(0xFFF8FAFC);
  static const canvas = bg;
  static const deepSpace = Color(0xFF0B2A31);
  static const sunken = Color(0xFFF1F5F9);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF1F5F9);
  static const overlay = Color(0xFFCBD5E1);

  // --- Aksen & semantik --------------------------------------------------
  /// Aksen netral aplikasi (teal). Dipakai untuk navigasi, tautan, CTA.
  static const nebula = Color(0xFF0D9488);
  static const star = Color(0xFF0F766E);

  /// Teks / ikon di ATAS permukaan aksen.
  static const onAccent = Color(0xFFFFFFFF);
  static const onAccent70 = Color(0xB3FFFFFF);
  static const onAccent54 = Color(0x8AFFFFFF);
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF0284C7);

  // --- Aksen semantik pilar ----------------------------------------------
  /// Workout — amber.
  static const workout = Color(0xFFD97706);
  static const workoutBright = Color(0xFFF59E0B);
  static const workoutSoft = Color(0xFFFEF3C7);

  /// Air minum — cyan.
  static const water = Color(0xFF0891B2);
  static const waterBright = Color(0xFF06B6D4);
  static const waterSoft = Color(0xFFECFEFF);

  /// Keuangan — emerald.
  static const finance = Color(0xFF059669);
  static const financeBright = Color(0xFF10B981);
  static const financeSoft = Color(0xFFECFDF5);

  /// Study & fokus — teal.
  static const study = Color(0xFF0D9488);
  static const studySoft = Color(0xFFF0FDFA);

  // --- Teks (kontras di atas putih: ink 11:1, mut 4.8:1, faint 3.1:1) ----
  static const ink = Color(0xFF143E48);
  static const mut = Color(0xFF6B7280);
  static const faint = Color(0xFF8A94A6);

  /// Garis rambut & isian.
  static const line = Color(0xFFE2E8F0);
  static const lineSoft = Color(0xFFEDF1F5);
  static const fill = Color(0xFFF8FAFC);
  static const fillStrong = Color(0xFFF1F5F9);
  static const cardBorder = line;
  static const track = Color(0xFFE2E8F0);

  /// Bayangan lembut pengganti glow. Dibiarkan berwarna aksen agar
  /// call-site lama tetap valid, tetapi opacity-nya sangat rendah.
  static BoxShadow glowNebulaSm({double opacity = .3}) => BoxShadow(
    color: nebula.withValues(alpha: opacity * .10),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );
  static BoxShadow glowStarSm({double opacity = .35}) => BoxShadow(
    color: star.withValues(alpha: opacity * .10),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );
  static BoxShadow glowStarMd({double opacity = .5}) => BoxShadow(
    color: star.withValues(alpha: opacity * .12),
    blurRadius: 24,
    offset: const Offset(0, 10),
  );

  static const rSm = 8.0;
  static const rMd = 12.0;
  static const rLg = 16.0;
}

/// Palet area jurnal (Beranda, To-Do, Jadwal, Study). Nilai disamakan dengan
/// [Star] supaya seluruh aplikasi satu bahasa visual.
///
/// Konvensi "Ink": varian `*Ink` = warna TEKS di atas `*Soft` (tint terang).
class Paper {
  static const canvas = Star.bg;
  static const card = Star.surface;

  /// Jangkar teks / tombol utama (deep teal), bukan aksen amber lagi.
  static const header = Star.ink;
  static const mint = Star.finance;
  static const mintDeep = Color(0xFF047857);
  static const mintSoft = Star.financeSoft;
  static const amber = Star.workout;
  static const amberInk = Color(0xFFB45309);
  static const amberSoft = Star.workoutSoft;
  static const coral = Star.error;
  static const coralInk = Color(0xFFB91C1C);
  static const coralSoft = Color(0xFFFEF2F2);
  static const ink = Star.ink;
  static const sec = Star.mut;
  static const ter = Star.faint;
  static const hair = Star.line;
  static const field = Star.sunken;
}

class Cat {
  final Color acc, accBg, accTx, head1, head2;
  const Cat(this.acc, this.accBg, this.accTx, this.head1, this.head2);
}

/// Aksen per halaman. Netral teal untuk halaman umum; tiga pilar utama
/// memakai warna semantiknya sendiri agar badge & progres langsung terbaca.
class Themes {
  static const _base = Cat(
    Star.star,
    Star.studySoft,
    Color(0xFF115E59),
    Star.star,
    Color(0xFF14B8A6),
  );
  static const _workout = Cat(
    Star.workout,
    Star.workoutSoft,
    Color(0xFF92400E),
    Star.workout,
    Star.workoutBright,
  );
  static const _air = Cat(
    Star.water,
    Star.waterSoft,
    Color(0xFF155E75),
    Star.water,
    Star.waterBright,
  );
  static const _finance = Cat(
    Star.finance,
    Star.financeSoft,
    Color(0xFF065F46),
    Star.finance,
    Star.financeBright,
  );

  static const planning = _base;
  static const workout = _workout;
  static const keuangan = _finance;
  static const ingin = _base;
  static const minggu1 = _base;
  static const minggu2 = _finance;
  static const booster = _finance;
  static const tips = _workout;
  static const air = _air;
  static const buat = _base;
  static const kombinasi = _workout;
  static const todo = _base;
}

/// Aksen halaman berdasarkan id yang dipakai [SecHead]/[HRow].
Color accOf(String page) => switch (page) {
  'workout' => Themes.workout.acc,
  'air' => Themes.air.acc,
  'keuangan' => Themes.keuangan.acc,
  'study' => Star.study,
  'tips' => Themes.tips.acc,
  'booster' => Themes.booster.acc,
  'kombinasi' => Themes.kombinasi.acc,
  _ => Star.star,
};

/// Alias kompatibilitas ke token lama.
class CustomColors {
  static const navy = Star.deepSpace;
  static const primaryBlue = Star.star;
  static const bgWhite = Star.surface;
  static const bgGrey = Star.sunken;
  static const textPrimary = Star.ink;
  static const textSecondary = Star.mut;
  static const success = Star.success;
  static const ink = Star.ink;
  static const mut = Star.mut;
  static const hair = Star.line;
}

/// Bahasa bentuk "kartu bersih": permukaan putih, border slate tipis, dan
/// bayangan yang nyaris tak terlihat. `raised` tetap dipakai luas oleh
/// halaman lama, jadi API-nya dipertahankan.
class Neu {
  static const shadowDark = Color(0xFF94A3B8);
  static const shadowLight = Color(0xFFFFFFFF);

  /// Bayangan kartu: satu lapis sangat lembut, bukan glow.
  static List<BoxShadow> shadows({double d = 6}) => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: .045),
      offset: Offset(0, (d * .45).clamp(1, 8)),
      blurRadius: d * 2.4,
      spreadRadius: -2,
    ),
  ];

  /// Dekorasi kartu utama: putih, border #E2E8F0, radius 16–22.
  static BoxDecoration raised({
    double r = 20,
    double d = 6,
    Color? color,
    bool gradient = true,
  }) {
    final base = color ?? Star.surface;
    return BoxDecoration(
      // Warna bertint (mis. amber-50) dibuat opak agar tidak menimpa
      // kanvas di belakangnya secara aneh.
      color: Color.alphaBlend(base, Star.surface),
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: Star.line),
      boxShadow: shadows(d: d),
    );
  }

  /// Dekorasi cekung: isian slate muda + border tipis. Untuk input, jalur
  /// progres, dan toggle terpilih.
  static BoxDecoration well({double r = 14, Color? color}) => BoxDecoration(
    color: color ?? Star.sunken,
    borderRadius: BorderRadius.circular(r),
    border: Border.all(color: Star.line),
  );

  /// Datar: hanya hairline. Untuk baris di dalam kartu.
  static BoxDecoration flat({double r = 14}) => BoxDecoration(
    borderRadius: BorderRadius.circular(r),
    border: Border.all(color: Star.lineSoft),
  );
}

/// Permukaan cekung sederhana (isian slate + border). Dulu memakai bayangan
/// dalam ala neumorphism; pada tema terang efek itu terlihat kotor, jadi
/// diganti bidang datar yang bersih. API dipertahankan.
class NeuWell extends StatelessWidget {
  final Widget? child;
  final double radius;
  final double depth;
  final EdgeInsetsGeometry? padding;
  final double? width, height;
  final Color? color;
  const NeuWell({
    super.key,
    this.child,
    this.radius = 14,
    this.depth = 3,
    this.padding,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? Star.sunken,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Star.lineSoft),
      ),
      child: child,
    );
  }
}

/// Skala tipografi aplikasi — satu keluarga (Manrope). Judul 700-800 rapat,
/// isi 400-500, angka tabular. Area sentuh min 48dp.
class AppText {
  static const _tab = [FontFeature.tabularFigures()];
  static const largeTitle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w800,
    fontSize: 30,
    height: 1.12,
    letterSpacing: -1.0,
    color: Star.ink,
  );
  static const pageTitle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w800,
    fontSize: 21,
    height: 1.22,
    letterSpacing: -0.6,
    color: Star.ink,
  );
  static const sectionTitle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w700,
    fontSize: 17,
    height: 1.3,
    letterSpacing: -0.3,
    color: Star.ink,
  );
  static const cardTitle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w700,
    fontSize: 15,
    height: 1.3,
    letterSpacing: -0.2,
    color: Star.ink,
  );
  static const statNum = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w800,
    fontSize: 22,
    height: 1.15,
    letterSpacing: -0.6,
    color: Star.ink,
    fontFeatures: _tab,
  );
  static const statLabel = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 0.1,
    color: Star.mut,
  );
  static const body = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: Star.ink,
  );
  static const secondary = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Star.mut,
  );
  static const footnote = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: Star.faint,
  );
  static const button = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );
  static const input = TextStyle(fontFamily: 'Manrope', fontSize: 16);
  static const minTouch = 48.0;
}

const _sysOverlay = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Star.bg,
  systemNavigationBarDividerColor: Star.bg,
  systemNavigationBarIconBrightness: Brightness.dark,
);

/// Dipanggil sekali saat start agar ikon status bar gelap di atas kanvas terang.
void applySystemOverlay() => SystemChrome.setSystemUIOverlayStyle(_sysOverlay);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    platform: TargetPlatform.iOS,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    colorScheme: const ColorScheme.light(
      primary: Star.star,
      onPrimary: Star.onAccent,
      primaryContainer: Star.studySoft,
      onPrimaryContainer: Star.ink,
      secondary: Star.workout,
      onSecondary: Star.onAccent,
      secondaryContainer: Star.workoutSoft,
      onSecondaryContainer: Star.ink,
      tertiary: Star.finance,
      onTertiary: Star.onAccent,
      tertiaryContainer: Star.financeSoft,
      onTertiaryContainer: Star.ink,
      surface: Star.surface,
      onSurface: Star.ink,
      error: Star.error,
      onError: Star.onAccent,
      outline: Star.line,
      outlineVariant: Star.lineSoft,
    ),
    scaffoldBackgroundColor: Star.bg,
    canvasColor: Star.bg,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Star.ink,
        fontFamily: 'Manrope',
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Star.ink,
        fontFamily: 'Manrope',
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: Star.mut,
        fontFamily: 'Manrope',
        fontSize: 12,
      ),
      titleLarge: TextStyle(
        color: Star.ink,
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleMedium: TextStyle(
        color: Star.ink,
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(color: Star.mut, fontFamily: 'Manrope'),
      labelLarge: TextStyle(color: Star.ink, fontFamily: 'Manrope'),
      labelMedium: TextStyle(color: Star.mut, fontFamily: 'Manrope'),
      labelSmall: TextStyle(color: Star.mut, fontFamily: 'Manrope'),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Star.bg,
      foregroundColor: Star.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      systemOverlayStyle: _sysOverlay,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        fontSize: 17,
        letterSpacing: -0.4,
        color: Star.ink,
      ),
      iconTheme: IconThemeData(color: Star.ink, size: 22),
      actionsIconTheme: IconThemeData(color: Star.ink, size: 22),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      // Teal tua: teks putih selalu terbaca, termasuk saat halaman
      // menimpanya dengan warna aksen/error.
      backgroundColor: Star.ink,
      contentTextStyle: const TextStyle(
        color: Star.onAccent,
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
      actionTextColor: Star.workoutBright,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Star.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Star.line),
      ),
      shadowColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(color: Star.lineSoft, thickness: 1),
    splashFactory: InkRipple.splashFactory,
    splashColor: const Color(0x140F766E),
    highlightColor: Colors.transparent,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 50),
        backgroundColor: Star.star,
        foregroundColor: Star.onAccent,
        textStyle: AppText.button,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 50),
        foregroundColor: Star.ink,
        backgroundColor: Star.fill,
        side: const BorderSide(color: Star.line, width: 1),
        textStyle: AppText.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 44),
        foregroundColor: Star.star,
        textStyle: AppText.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    // Input: isian slate muda + border tipis; fokus teal.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Star.fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      labelStyle: const TextStyle(
        color: Star.mut,
        fontFamily: 'Manrope',
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        color: Star.faint,
        fontFamily: 'Manrope',
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Star.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Star.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Star.star, width: 1.4),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: const BorderSide(color: Star.overlay, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? Star.star : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(Star.onAccent),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Star.onAccent : Star.surface,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Star.star : Star.overlay,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Star.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w800,
        fontSize: 18,
        letterSpacing: -0.4,
        color: Star.ink,
      ),
      contentTextStyle: const TextStyle(
        color: Star.ink,
        fontFamily: 'Manrope',
        fontSize: 14,
        height: 1.45,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Star.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: Star.surface,
      showDragHandle: false,
      dragHandleColor: Star.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: Star.surface,
      surfaceTintColor: Colors.transparent,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: Star.surface,
      dialBackgroundColor: Star.sunken,
      hourMinuteColor: Star.sunken,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Star.surface,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Star.star,
      linearTrackColor: Star.track,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Star.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Star.onAccent, fontSize: 12),
    ),
    listTileTheme: ListTileThemeData(
      textColor: Star.ink,
      iconColor: Star.mut,
      titleTextStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Star.ink,
      ),
      subtitleTextStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 12.5,
        color: Star.mut,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Star.surface,
      indicatorColor: Colors.transparent,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: 'Manrope',
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: s.contains(WidgetState.selected) ? Star.star : Star.faint,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          size: 23,
          color: s.contains(WidgetState.selected) ? Star.star : Star.faint,
        ),
      ),
    ),
  );
  return base;
}
