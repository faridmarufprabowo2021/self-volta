import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:self_volta/store.dart';
import 'package:self_volta/theme.dart';
import 'package:self_volta/services/prayer_service.dart';
import 'package:self_volta/services/weather_service.dart';
import 'package:self_volta/pages/home_page.dart';

/// Menguji state machine hero Beranda (2×2 ↔ 4×2), swipe, dan streak header.
void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.I.load();
    PrayerService.instance;
    final loader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-Variable.ttf'));
    await loader.load();
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    Size size = const Size(360, 900),
    double scale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(body: HomePage(onNavigate: (_) {})),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  for (final width in const [320.0, 360.0, 412.0]) {
    for (final scale in const [1.3, 2.0]) {
      testWidgets(
        'hero ${width.toInt()}px scale $scale: buka, tutup, dan swipe',
        (tester) async {
          final problems = <String>[];
          final old = FlutterError.onError;
          FlutterError.onError = (details) {
            problems.add(details.exceptionAsString());
          };
          try {
            await pumpHome(
              tester,
              size: Size(width, 7000),
              scale: scale,
            );

            expect(find.byKey(const Key('hero-prayer-mode')), findsOneWidget);
            expect(find.byKey(const Key('hero-weather-mode')), findsOneWidget);

            // 2×2 → sholat 4×2.
            await tester.tap(find.byKey(const Key('hero-prayer-mode')));
            await tester.pumpAndSettle();
            expect(find.text('Subuh'), findsOneWidget);
            expect(find.textContaining('Imsak'), findsOneWidget);

            // 4×2 → 2×2.
            await tester.tap(find.byKey(const Key('hero-prayer-mode')));
            await tester.pumpAndSettle();
            expect(find.text('Subuh'), findsNothing);

            // Swipe kiri → cuaca 4×2.
            await tester.drag(
              find.byKey(const Key('hero-bento')),
              const Offset(-260, 0),
            );
            await tester.pumpAndSettle();
            expect(
              find.descendant(
                of: find.byKey(const Key('hero-weather-mode')),
                matching: find.byIcon(Icons.close_rounded),
              ),
              findsOneWidget,
            );

            // Swipe saat melebar → kembali 2×2.
            await tester.drag(
              find.byKey(const Key('hero-bento')),
              const Offset(260, 0),
            );
            await tester.pumpAndSettle();
            expect(
              find.descendant(
                of: find.byKey(const Key('hero-weather-mode')),
                matching: find.byIcon(Icons.chevron_left_rounded),
              ),
              findsOneWidget,
            );
          } finally {
            FlutterError.onError = old;
          }
          expect(problems, isEmpty, reason: problems.join('\n'));
        },
      );
    }
  }

  testWidgets('header menampilkan streak dan XP dari AppState', (tester) async {
    final oldStreak = AppState.I.streak;
    final oldXp = AppState.I.xp;
    addTearDown(() {
      AppState.I.streak = oldStreak;
      AppState.I.xp = oldXp;
    });
    AppState.I.streak = 9;
    AppState.I.xp = 4321;

    await pumpHome(tester);

    expect(find.text('🔥 9 Hari Aktif'), findsOneWidget);
    expect(
      find.text('⚡ Level ${AppState.I.level} · 4321 XP'),
      findsOneWidget,
    );
  });

  for (final (width, scale) in const [(320.0, 2.0), (412.0, 1.3)]) {
    testWidgets('cuaca 4×2 dengan data nyata di ${width.toInt()}px '
        'scale $scale', (tester) async {
      WeatherService.debugSnapshot = WeatherSnapshot(
        temperatureC: 32,
        feelsLikeC: 34,
        windKph: 12,
        uvIndex: 6,
        pressureHpa: 1012,
        humidity: 68,
        rainChance: 15,
        aqi: 42,
        code: 0,
        hours: [
          for (var i = 0; i < 6; i++)
            WeatherHour(
              at: DateTime(2026, 11, 16, 18 + i),
              temperatureC: 31 - i.toDouble(),
              code: i == 4 ? 61 : 0,
            ),
        ],
        fetchedAt: DateTime(2026, 11, 16, 17, 20),
      );
      addTearDown(() => WeatherService.debugSnapshot = null);

      final problems = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (details) {
        problems.add(details.exceptionAsString());
      };
      try {
        await pumpHome(
          tester,
          size: Size(width, 7000),
          scale: scale,
        );
        await tester.tap(find.byKey(const Key('hero-weather-mode')));
        await tester.pumpAndSettle();

        expect(find.text('Lembap'), findsOneWidget);
        expect(find.text('1012 hPa'), findsOneWidget);
        expect(find.text('42 Baik'), findsOneWidget);
        expect(find.text('18.00'), findsOneWidget);
        expect(find.text('23.00'), findsOneWidget);
      } finally {
        FlutterError.onError = old;
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  }
}
