import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Token warna TERANG dari palet SVG user (Allports / Picton Blue /
/// Thistle / Black Haze / China Ivory / Cyan-Aqua).
/// Scaffold Black Haze, kartu putih, primer Allports, CTA sea.
class Star {
  static const bg = Color(0xffF6F8F7);
  static const deepSpace = Color(0xff004E71);
  static const sunken = Color(0xffE4E8E8);
  static const surface = Color(0xffffffff);
  static const surface2 = Color(0xffF6F8F7);
  static const overlay = Color(0xffCDD1CF);
  static const nebula = Color(0xff0781D1);
  static const star = Color(0xff006C95);
  static const success = Color(0xff009E8F);
  static const warning = Color(0xffA67C00);
  static const error = Color(0xffD64545);
  static const info = Color(0xff3EA9E8);
  static const ink = Color(0xff14323F);
  static const mut = Color(0xff4E6E7C);
  static const faint = Color(0xff7FA0AD);

  /// Hairline & permukaan gaya iOS (turunan palet, bukan warna baru).
  static const line = Color(0x1F14323F);
  static const lineSoft = Color(0x1214323F);
  static const fill = Color(0xFFEFF3F4);
  static const fillStrong = Color(0xFFE6ECEE);

  /// Glow lembut (interaktif / fokus) — satu glow per elemen.
  static BoxShadow glowNebulaSm({double opacity = .3}) =>
      BoxShadow(color: nebula.withValues(alpha: opacity), blurRadius: 8);

  /// Glow CTA / badge aktif.
  static BoxShadow glowStarSm({double opacity = .35}) =>
      BoxShadow(color: star.withValues(alpha: opacity), blurRadius: 8);

  /// Glow medium (kartu achievement).
  static BoxShadow glowStarMd({double opacity = .5}) =>
      BoxShadow(color: star.withValues(alpha: opacity), blurRadius: 16);

  /// Radius StarChart.
  static const rSm = 8.0;
  static const rMd = 12.0;
  static const rLg = 16.0;
}

/// Palet "kertas" untuk area jurnal (Beranda, To-Do, Study).
///
/// Kanvas krem, kartu putih bergaris rambut hangat, hijau tua sebagai jangkar,
/// mint untuk progres, amber hanya untuk target/uang, coral hanya untuk
/// keterlambatan. Nilainya sengaja sama dengan `TodoPal` di `todo_page.dart`
/// supaya Beranda dan To-Do terasa satu produk, bukan dua tema.
class Paper {
  static const canvas = Color(0xffFBF9F5);
  static const card = Color(0xffffffff);
  static const header = Color(0xff16594C);
  static const mint = Color(0xff2E8B70);
  static const mintDeep = Color(0xff1F6B55);
  static const mintSoft = Color(0xffDFF3EC);
  static const amber = Color(0xffA67C00);
  static const amberInk = Color(0xff7A5A00);
  static const amberSoft = Color(0xffF4ECCF);
  static const coral = Color(0xffC96F5C);
  static const coralInk = Color(0xff9E4B39);
  static const coralSoft = Color(0xffF5E1DA);
  static const ink = Color(0xff1D1B16);
  static const sec = Color(0xff6F6A61);
  static const ter = Color(0xff817B70);
  static const hair = Color(0xffE7E2DA);
  static const field = Color(0xffF6F4EE);
}

class Cat {
  final Color acc, accBg, accTx, head1, head2;
  const Cat(this.acc, this.accBg, this.accTx, this.head1, this.head2);
}

/// Aksen per halaman — varian TERANG (acc pekat, accBg tint pastel,
/// accTx gelap) agar terbaca di atas Black Haze / putih.
class Themes {
  static const planning = Cat(
    Color(0xff006C95),
    Color(0xffDFEFF5),
    Color(0xff004E71),
    Color(0xff006C95),
    Color(0xff238BAE),
  );
  static const workout = Cat(
    Color(0xff0781D1),
    Color(0xffE0F0FA),
    Color(0xff056AB2),
    Color(0xff0781D1),
    Color(0xff3EA9E8),
  );
  static const keuangan = Cat(
    Color(0xff8A63B0),
    Color(0xffEEE6F6),
    Color(0xff5E3F86),
    Color(0xff8A63B0),
    Color(0xffBFA8C8),
  );
  static const ingin = Cat(
    Color(0xffA67C00),
    Color(0xffF7F0D9),
    Color(0xff6E5600),
    Color(0xffA67C00),
    Color(0xffC5CB96),
  );
  static const minggu1 = Cat(
    Color(0xff3EA9E8),
    Color(0xffE2F2FC),
    Color(0xff056AB2),
    Color(0xff3EA9E8),
    Color(0xff0781D1),
  );
  static const minggu2 = Cat(
    Color(0xff9E83A9),
    Color(0xffF1E9F6),
    Color(0xff6E4F7E),
    Color(0xff9E83A9),
    Color(0xffBFA8C8),
  );
  static const booster = Cat(
    Color(0xff009E8F),
    Color(0xffD9F5F1),
    Color(0xff00685F),
    Color(0xff009E8F),
    Color(0xff01BEAF),
  );
  static const tips = Cat(
    Color(0xff238BAE),
    Color(0xffDFF0F6),
    Color(0xff005C83),
    Color(0xff238BAE),
    Color(0xff006C95),
  );
  static const air = Cat(
    Color(0xff00B3A6),
    Color(0xffD8F5F2),
    Color(0xff00685F),
    Color(0xff00B3A6),
    Color(0xff22DED0),
  );
  static const buat = Cat(
    Color(0xffC2185B),
    Color(0xffFBE7EF),
    Color(0xff7E1040),
    Color(0xffC2185B),
    Color(0xffF06292),
  );
  static const kombinasi = Cat(
    Color(0xff01BEAF),
    Color(0xffD9F6F3),
    Color(0xff00685F),
    Color(0xff01BEAF),
    Color(0xff22DED0),
  );

  /// Halaman To-Do — aksen mint "Hari" (pulau desain cream + mint).
  static const todo = Cat(
    Color(0xff2E8B70),
    Color(0xffDFF3EC),
    Color(0xff1F6B55),
    Color(0xff2E8B70),
    Color(0xff5FA98F),
  );
}

Color accOf(String page) {
  switch (page) {
    case 'workout':
      return Themes.workout.acc;
    case 'booster':
      return Themes.booster.acc;
    case 'minggu1':
      return Themes.minggu1.acc;
    case 'minggu2':
      return Themes.minggu2.acc;
    case 'tips':
      return Themes.tips.acc;
    case 'air':
      return Themes.air.acc;
    case 'buat':
      return Themes.buat.acc;
    case 'kombinasi':
      return Themes.kombinasi.acc;
    case 'ingin':
      return Themes.ingin.acc;
    case 'keuangan':
      return Themes.keuangan.acc;
    case 'todo':
      return Themes.todo.acc;
    default:
      return Themes.planning.acc;
  }
}

/// Alias kompatibilitas ke token palet terang.
/// Pakai [Star] untuk kode baru; alias ini menjaga call-site lama tetap jalan.
class CustomColors {
  static const navy = Star.deepSpace;
  static const primaryBlue = Star.nebula;
  static const bgWhite = Star.surface;
  static const bgGrey = Star.sunken;
  static const textPrimary = Star.ink;
  static const textSecondary = Star.mut;
  static const success = Star.success;
  static const ink = Star.ink;
  static const mut = Star.mut;
  static const hair = Star.overlay;
}

/// Skala tipografi aplikasi — satu keluarga (Inter, mendekati SF Pro).
/// Judul memakai weight 600-700, isi 400; area sentuh min 48dp.
class AppText {
  static const largeTitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 30,
    height: 1.15,
    letterSpacing: -0.8,
    color: Star.ink,
  );
  static const pageTitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.25,
    letterSpacing: -0.4,
    color: Star.ink,
  );
  static const sectionTitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 17,
    height: 1.3,
    letterSpacing: -0.2,
    color: Star.ink,
  );
  static const cardTitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.3,
    letterSpacing: -0.2,
    color: Star.ink,
  );
  static const statNum = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 1.15,
    letterSpacing: -0.4,
    color: Star.ink,
  );
  static const statLabel = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.3,
    color: Star.mut,
  );
  static const body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: Star.ink,
  );
  static const secondary = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.5,
    height: 1.4,
    color: Star.mut,
  );
  static const footnote = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11.5,
    height: 1.35,
    color: Star.faint,
  );
  static const button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );
  static const input = TextStyle(fontFamily: 'Inter', fontSize: 16);
  static const minTouch = 48.0;
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // Rasa iOS: fisika scroll memantul, transisi geser Cupertino,
    // adaptif widget mengikuti gaya iOS — di semua HP termasuk Android.
    platform: TargetPlatform.iOS,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    colorScheme: const ColorScheme.light(
      primary: Star.star,
      onPrimary: Colors.white,
      secondary: Star.nebula,
      onSecondary: Colors.white,
      surface: Star.surface,
      onSurface: Star.ink,
      error: Star.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Star.bg,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Star.ink, fontFamily: 'Inter', fontSize: 16),
      bodyMedium: TextStyle(color: Star.ink, fontFamily: 'Inter', fontSize: 14),
      bodySmall: TextStyle(color: Star.mut, fontFamily: 'Inter', fontSize: 12),
      titleLarge: TextStyle(
        color: Star.ink,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(
        color: Star.ink,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(color: Star.mut, fontFamily: 'Inter'),
      labelLarge: TextStyle(color: Star.ink, fontFamily: 'Inter'),
      labelMedium: TextStyle(color: Star.mut, fontFamily: 'Inter'),
      labelSmall: TextStyle(color: Star.mut, fontFamily: 'Inter'),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Star.bg,
      foregroundColor: Star.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 17,
        letterSpacing: -0.3,
        color: Star.ink,
      ),
      iconTheme: const IconThemeData(color: Star.star, size: 22),
      actionsIconTheme: const IconThemeData(color: Star.star, size: 22),
      shape: const Border(bottom: BorderSide(color: Star.lineSoft, width: 1)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Star.ink,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontFamily: 'Inter',
        fontSize: 13.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Star.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Star.lineSoft, width: 1),
      ),
      shadowColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(color: Star.lineSoft, thickness: 1),
    splashFactory: InkRipple.splashFactory,
    // Tombol gaya iOS: sudut 14, tinggi 50, tanpa pill penuh.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 50),
        backgroundColor: Star.star,
        foregroundColor: Colors.white,
        textStyle: AppText.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 50),
        foregroundColor: Star.star,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    // Input gaya iOS: isian lembut, hairline, fokus satu aksen.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Star.fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      labelStyle: const TextStyle(
        color: Star.mut,
        fontFamily: 'Inter',
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        color: Star.faint,
        fontFamily: 'Inter',
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Star.line, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Star.line, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Star.star, width: 1.5),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: const BorderSide(color: Star.line, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? Star.star : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(Colors.white),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Star.surface,
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 17,
        letterSpacing: -0.3,
        color: Star.ink,
      ),
      contentTextStyle: const TextStyle(
        color: Star.ink,
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.45,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Star.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      dragHandleColor: Star.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Star.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
    ),
    listTileTheme: ListTileThemeData(
      textColor: Star.ink,
      iconColor: Star.mut,
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Star.ink,
      ),
      subtitleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.5,
        color: Star.mut,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Star.surface,
      indicatorColor: Colors.transparent,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: 'Inter',
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
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
