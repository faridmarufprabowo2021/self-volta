import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:self_volta/store.dart';
import 'package:self_volta/theme.dart';
import 'package:self_volta/services/prayer_service.dart';
import 'package:self_volta/pages/air_page.dart';
import 'package:self_volta/pages/booster_page.dart';
import 'package:self_volta/pages/buat_page.dart';
import 'package:self_volta/pages/choice_plan_page.dart';
import 'package:self_volta/pages/home_page.dart';
import 'package:self_volta/pages/ingin_page.dart';
import 'package:self_volta/pages/keuangan_page.dart';
import 'package:self_volta/pages/minggu_page.dart';
import 'package:self_volta/pages/panduan_page.dart';
import 'package:self_volta/pages/planning_page.dart';
import 'package:self_volta/pages/profile_page.dart';
import 'package:self_volta/pages/tips_page.dart';
import 'package:self_volta/pages/todo_page.dart';
import 'package:self_volta/pages/workout_page.dart';
import 'package:self_volta/pages/study_page.dart';

/// Audit layout: semua halaman dipompa pada lebar sempit & font scale besar.
/// Gagal bila ada RenderFlex overflow / overflow horizontal-vertikal.
void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.I.load();
    // Panaskan singleton (timer detik) di luar FakeAsync agar tidak tersisa
    // sebagai pending timer pada test pertama.
    PrayerService.instance;
    // Muat font asli agar lebar teks di test sama dengan di HP
    // (font bawaan flutter_test membuat semua glyph selebar kotak).
    final loader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-Variable.ttf'));
    await loader.load();
  });

  final pages = <String, Widget Function()>{
    'Beranda': () => HomePage(onNavigate: (_) {}),
    'Profil': () => ProfilePage(onNavigate: (_) {}),
    'Latihan': () => const WorkoutPage(),
    'Planning': () => const PlanningPage(),
    'Keuangan': () => const KeuanganPage(),
    'Air': () => const AirPage(),
    'Booster': () => const BoosterPage(),
    'Tips': () => const TipsPage(),
    'Panduan': () => const PanduanPage(),
    'To-Do': () => TodoPage(onNavigate: (_) {}),
    'Study': () => const StudyPage(),
    'Choice Plan': () => const ChoicePlanPage(),
    'Ingin': () => const InginPage(),
    'Buat Kombinasi': () => const BuatPage(),
    'Minggu 1-2': () => const MingguPage(m1: true, onGo: _noop),
  };

  for (final entry in pages.entries) {
    for (final size in const [Size(360, 800), Size(412, 915)]) {
      for (final scale in const [1.0, 1.3]) {
        testWidgets('${entry.key} ${size.width.toInt()}x${size.height.toInt()} '
            'scale $scale tidak overflow', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final problems = <String>[];
          final old = FlutterError.onError;
          FlutterError.onError = (details) {
            problems.add(details.exceptionAsString());
          };

          try {
            await tester.pumpWidget(
              MaterialApp(
                theme: buildTheme(),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: Scaffold(body: entry.value()),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 50));
            await tester.pump(const Duration(milliseconds: 300));
          } finally {
            FlutterError.onError = old;
          }
          expect(problems, isEmpty, reason: problems.join('\n'));
        });
      }
    }
  }

  // Seluruh isi halaman (viewport sangat tinggi supaya list malas ikut
  // dibangun) — menangkap overflow di bagian bawah yang tak terlihat awal.
  for (final entry in pages.entries) {
    for (final w in const [360.0, 412.0]) {
      testWidgets('${entry.key} penuh ${w.toInt()}px tidak overflow', (
        tester,
      ) async {
        tester.view.physicalSize = Size(w, 7000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final problems = <String>[];
        final old = FlutterError.onError;
        FlutterError.onError = (details) {
          problems.add(details.exceptionAsString());
        };
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: buildTheme(),
              home: Scaffold(body: entry.value()),
            ),
          );
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 300));
        } finally {
          FlutterError.onError = old;
        }
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    }
  }

  // Sheet pengingat latihan: layar pendek + font besar tidak boleh overflow.
  for (final size in const [Size(320, 568), Size(360, 800)]) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets('Sheet pengingat latihan ${size.width.toInt()}x'
          '${size.height.toInt()} scale $scale tidak overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final problems = <String>[];
        final old = FlutterError.onError;
        FlutterError.onError = (details) {
          problems.add(details.exceptionAsString());
        };

        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: buildTheme(),
              home: MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(scale),
                ),
                child: const Scaffold(body: WorkoutPage()),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          await tester.tap(find.byKey(const Key('workout-reminder-btn')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
        } finally {
          FlutterError.onError = old;
        }
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    }
  }

  // Sheet notifikasi & editor To-Do: layar pendek + font besar.
  for (final sheet in const ['notif', 'editor']) {
    for (final size in const [Size(320, 568), Size(360, 800)]) {
      for (final scale in const [1.0, 1.3]) {
        testWidgets('Sheet $sheet ${size.width.toInt()}x${size.height.toInt()} '
            'scale $scale tidak overflow', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final problems = <String>[];
          final old = FlutterError.onError;
          FlutterError.onError = (details) {
            problems.add(details.exceptionAsString());
          };

          try {
            await tester.pumpWidget(
              MaterialApp(
                theme: buildTheme(),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: Scaffold(body: TodoPage(onNavigate: (_) {})),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
            await tester.tap(
              find.byKey(
                Key(sheet == 'notif' ? 'todo-notif-btn' : 'todo-add-header'),
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 500));
          } finally {
            FlutterError.onError = old;
          }
          expect(problems, isEmpty, reason: problems.join('\n'));
        });
      }
    }
  }
}

void _noop(String _) {}
