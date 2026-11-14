import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Token warna DARK NEUMORPHISM.
///
/// Prinsip (supaya tidak jadi "plastik" / slop):
///  * Satu nada dasar grafit dingin. Kartu, kanvas, dan sheet SAMA warnanya —
///    kedalaman hanya datang dari sepasang bayangan (gelap kanan-bawah, terang
///    kiri-atas) dengan satu arah cahaya di seluruh aplikasi.
///  * Satu aksen: amber redup. Hijau sage hanya untuk "selesai", koral hanya
///    untuk error / keterlambatan. Tanpa ungu, tanpa gradien dekoratif.
///  * Timbul (raised) hanya untuk blok utama & CTA; cekung (well) untuk input,
///    jalur progres, dan toggle terpilih. Baris di dalam kartu tetap datar.
class Star {
  // --- Permukaan ---------------------------------------------------------
  static const bg = Color(0xff22262B);
  static const deepSpace = Color(0xff191C20);
  static const sunken = Color(0xff1C1F23);
  static const surface = Color(0xff22262B);
  static const surface2 = Color(0xff272C32);
  static const overlay = Color(0xff3A4048);

  // --- Aksen & semantik --------------------------------------------------
  /// Aksen utama (amber redup, saturasi < 60%).
  static const nebula = Color(0xffD9A55B);
  static const star = Color(0xffD9A55B);

  /// Teks / ikon di ATAS permukaan aksen.
  static const onAccent = Color(0xff1B1D21);
  static const onAccent70 = Color(0xB31B1D21);
  static const onAccent54 = Color(0x8A1B1D21);
  static const success = Color(0xff7DB894);
  static const warning = Color(0xffD9A55B);
  static const error = Color(0xffE27B6C);
  static const info = Color(0xff8D9AA8);

  // --- Teks (kontras di atas bg: ink 12:1, mut 6:1, faint 3.4:1) ---------
  static const ink = Color(0xffE8EAED);
  static const mut = Color(0xff9BA3AD);
  static const faint = Color(0xff727A85);

  /// Garis rambut & isian (dipakai sangat hemat).
  static const line = Color(0x24FFFFFF);
  static const lineSoft = Color(0x12FFFFFF);
  static const fill = Color(0xFF1E2125);
  static const fillStrong = Color(0xFF181B1E);

  /// Glow tidak lagi dipakai di neumorphism; dibiarkan sebagai bayangan
  /// halus berwarna aksen agar call-site lama tetap valid.
  static BoxShadow glowNebulaSm({double opacity = .3}) =>
      BoxShadow(color: nebula.withValues(alpha: opacity * .5), blurRadius: 10);
  static BoxShadow glowStarSm({double opacity = .35}) =>
      BoxShadow(color: star.withValues(alpha: opacity * .5), blurRadius: 10);
  static BoxShadow glowStarMd({double opacity = .5}) =>
      BoxShadow(color: star.withValues(alpha: opacity * .5), blurRadius: 18);

  static const rSm = 8.0;
  static const rMd = 12.0;
  static const rLg = 16.0;
}

/// Palet area jurnal (Beranda, To-Do, Study). Nilai disamakan dengan [Star]
/// supaya seluruh aplikasi satu bahasa visual.
///
/// Konvensi "Ink": varian `*Ink` = warna TEKS terang di atas `*Soft`
/// (tint gelap), bukan lagi teks gelap di atas pastel.
class Paper {
  static const canvas = Star.bg;
  static const card = Star.surface;

  /// Dulunya hijau tua jangkar; kini = aksen (isian terpilih / jangkar).
  static const header = Star.star;
  static const mint = Color(0xff7DB894);
  static const mintDeep = Color(0xff9ACDAF);
  static const mintSoft = Color(0xff29352F);
  static const amber = Star.star;
  static const amberInk = Color(0xffE9C48A);
  static const amberSoft = Color(0xff342F27);
  static const coral = Color(0xffE27B6C);
  static const coralInk = Color(0xffF0A296);
  static const coralSoft = Color(0xff3A2C2C);
  static const ink = Star.ink;
  static const sec = Star.mut;
  static const ter = Star.faint;
  static const hair = Color(0xff30353B);
  static const field = Star.sunken;
}

class Cat {
  final Color acc, accBg, accTx, head1, head2;
  const Cat(this.acc, this.accBg, this.accTx, this.head1, this.head2);
}

/// Aksen per halaman — sengaja DISERAGAMKAN ke satu aksen. Pembeda antar
/// halaman datang dari ikon & judul, bukan dari pelangi warna.
class Themes {
  static const _c = Cat(
    Star.star,
    Color(0xff332F28),
    Color(0xffE9C48A),
    Star.star,
    Star.star,
  );
  static const planning = _c;
  static const workout = _c;
  static const keuangan = _c;
  static const ingin = _c;
  static const minggu1 = _c;
  static const minggu2 = _c;
  static const booster = _c;
  static const tips = _c;
  static const air = _c;
  static const buat = _c;
  static const kombinasi = _c;
  static const todo = _c;
}

Color accOf(String page) => Star.star;

/// Alias kompatibilitas ke token lama.
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

/// Bahasa bentuk neumorphism. Satu sumber cahaya: kiri-atas.
class Neu {
  static const shadowDark = Color(0xff14161A);
  static const shadowLight = Color(0xff30363D);

  /// Bayangan timbul. [d] = jarak offset (6 kartu, 3 chip kecil).
  static List<BoxShadow> shadows({double d = 6}) => [
    BoxShadow(
      color: shadowDark.withValues(alpha: .85),
      offset: Offset(d, d),
      blurRadius: d * 2.2,
    ),
    BoxShadow(
      color: shadowLight.withValues(alpha: .75),
      offset: Offset(-d * .8, -d * .8),
      blurRadius: d * 2,
    ),
  ];

  /// Dekorasi TIMBUL: blok utama, CTA, kartu hero.
  static BoxDecoration raised({
    double r = 20,
    double d = 6,
    Color? color,
    bool gradient = true,
  }) {
    final base = color ?? Star.surface;
    return BoxDecoration(
      color: base,
      borderRadius: BorderRadius.circular(r),
      gradient: (gradient && color == null)
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff262B31), Color(0xff1F2327)],
            )
          : null,
      boxShadow: shadows(d: d),
    );
  }

  /// Dekorasi CEKUNG sederhana (tanpa bayangan dalam sejati) — untuk elemen
  /// kecil / di dalam list. Untuk cekung sejati pakai [NeuWell].
  static BoxDecoration well({double r = 14, Color? color}) => BoxDecoration(
    color: color ?? Star.sunken,
    borderRadius: BorderRadius.circular(r),
    border: Border.all(color: const Color(0x0DFFFFFF)),
  );

  /// Datar: hanya hairline. Untuk baris di dalam kartu.
  static BoxDecoration flat({double r = 14}) => BoxDecoration(
    borderRadius: BorderRadius.circular(r),
    border: Border.all(color: Star.lineSoft),
  );
}

/// Permukaan CEKUNG sejati: bayangan dalam gelap di tepi kiri-atas dan
/// sorot terang di tepi kanan-bawah. Untuk jalur progres, input, toggle.
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        foregroundPainter: _InsetPainter(radius, depth),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          color: color ?? Star.sunken,
          child: child,
        ),
      ),
    );
  }
}

class _InsetPainter extends CustomPainter {
  final double radius, depth;
  const _InsetPainter(this.radius, this.depth);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.save();
    canvas.clipRRect(rr);
    final outer = Path()..addRect(rect.inflate(depth * 6));
    void shade(Offset shift, Color c) {
      final hole = Path()..addRRect(rr.shift(shift));
      final ring = Path.combine(PathOperation.difference, outer, hole);
      canvas.drawPath(
        ring,
        Paint()
          ..color = c
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, depth * 1.2),
      );
    }

    shade(Offset(depth, depth), Neu.shadowDark.withValues(alpha: .95));
    shade(
      Offset(-depth * .8, -depth * .8),
      Neu.shadowLight.withValues(alpha: .55),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InsetPainter old) =>
      old.radius != radius || old.depth != depth;
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
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Star.bg,
  systemNavigationBarIconBrightness: Brightness.light,
);

/// Dipanggil sekali saat start agar ikon status bar terang di atas gelap.
void applySystemOverlay() => SystemChrome.setSystemUIOverlayStyle(_sysOverlay);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    platform: TargetPlatform.iOS,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    colorScheme: const ColorScheme.dark(
      primary: Star.star,
      onPrimary: Star.onAccent,
      secondary: Star.nebula,
      onSecondary: Star.onAccent,
      surface: Star.surface,
      onSurface: Star.ink,
      error: Star.error,
      onError: Star.onAccent,
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
      iconTheme: IconThemeData(color: Star.star, size: 22),
      actionsIconTheme: IconThemeData(color: Star.star, size: 22),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Star.surface2,
      contentTextStyle: const TextStyle(
        color: Star.ink,
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
      actionTextColor: Star.star,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Star.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(color: Star.lineSoft, thickness: 1),
    splashFactory: InkRipple.splashFactory,
    splashColor: const Color(0x1AD9A55B),
    highlightColor: Colors.transparent,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 50),
        backgroundColor: Star.star,
        foregroundColor: Star.onAccent,
        textStyle: AppText.button,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 50),
        foregroundColor: Star.ink,
        backgroundColor: Star.surface,
        side: const BorderSide(color: Star.line, width: 1),
        textStyle: AppText.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    // Input = sumur cekung: isian lebih gelap dari kanvas, tanpa outline.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Star.sunken,
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
        borderSide: const BorderSide(color: Color(0x0DFFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x0DFFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Star.star, width: 1.2),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: const BorderSide(color: Star.faint, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? Star.star : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(Star.onAccent),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Star.onAccent : Star.mut,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Star.star : Star.sunken,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Star.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: Star.surface,
      showDragHandle: false,
      dragHandleColor: Star.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
      color: Star.surface2,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Star.star,
      linearTrackColor: Star.sunken,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Star.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(color: Star.ink, fontSize: 12),
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
