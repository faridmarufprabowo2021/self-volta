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
import 'package:self_volta/pages/jadwal_page.dart';
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
    'Jadwal': () => JadwalPage(onNavigate: (_) {}),
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

  // Sheet anggaran Keuangan: layar pendek + font besar tidak boleh overflow.
  for (final size in const [Size(320, 568), Size(360, 800)]) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets('Sheet anggaran ${size.width.toInt()}x'
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
                child: const Scaffold(body: KeuanganPage()),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          await tester.tap(find.text('Atur'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.text('Atur anggaran'), findsOneWidget);
        } finally {
          FlutterError.onError = old;
        }
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    }
  }

  // Sheet parameter profil: stepper berat/tinggi/usia harus muat di layar
  // sempit, termasuk saat font diperbesar.
  for (final size in const [Size(360, 800), Size(412, 915)]) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets('Sheet parameter profil ${size.width.toInt()}x'
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
                child: Scaffold(body: ProfilePage(onNavigate: (_) {})),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          await tester.ensureVisible(find.text('Ubah'));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.tap(find.text('Ubah'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(
            find.text('Parameter Fisik & Target Asupan Gizi'),
            findsOneWidget,
          );
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

  // ---- Beranda hasil rebuild -------------------------------------------
  // Fokus: kartu "Hari Ini" & "Menu Makanan" tetap rapi saat data padat,
  // font scale 1.3, dan status kebiasaan berubah.

  Future<void> pumpHome(
    WidgetTester tester, {
    required Size size,
    required double scale,
    ValueChanged<String>? onNavigate,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(body: HomePage(onNavigate: onNavigate ?? _noop)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('Beranda padat 360 scale 1.3 tidak overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 7000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final oldTodos = List<SvTask>.from(AppState.I.todos);
    final oldEaten = Map<String, bool>.from(AppState.I.eaten);
    addTearDown(() {
      AppState.I.todos = oldTodos;
      AppState.I.eaten
        ..clear()
        ..addAll(oldEaten);
    });

    final date = AppState.todayKey;
    AppState.I.todos = [
      SvTask(
        id: 901,
        title: 'Beli galon air mineral',
        date: date,
        timeMin: 420,
        cat: 'Pribadi',
        note: 'Galon kosong di dapur',
        pri: 2,
      ),
      SvTask(
        id: 902,
        title: 'Bayar kos bulan ini',
        date: date,
        timeMin: 750,
        cat: 'Keuangan',
        done: true,
      ),
      SvTask(
        id: 903,
        title: 'Review materi kuliah yang judulnya panjang sekali',
        date: date,
        cat: 'Study',
      ),
      SvTask(
        id: 904,
        title: 'Jalan pagi',
        date: date,
        timeMin: 300,
        cat: 'Kesehatan',
        repeat: 'harian',
      ),
      SvTask(id: 905, title: 'Tugas kelima', date: date, timeMin: 1080),
      SvTask(id: 906, title: 'Tugas keenam', date: date, timeMin: 1200),
    ];

    final problems = <String>[];
    final old = FlutterError.onError;
    FlutterError.onError = (details) {
      problems.add(details.exceptionAsString());
    };
    try {
      await pumpHome(tester, size: const Size(360, 7000), scale: 1.3);
    } finally {
      FlutterError.onError = old;
    }

    expect(problems, isEmpty, reason: problems.join('\n'));
    expect(find.text('Tambah tugas'), findsOneWidget);
    expect(find.text('Lihat semua'), findsNWidgets(2));
    // Maksimal empat tugas tampil; sisanya lewat "Lihat semua".
    expect(find.text('Tugas kelima'), findsOneWidget);
    expect(find.text('Tugas keenam'), findsOneWidget);
    expect(
      find.text('Review materi kuliah yang judulnya panjang sekali'),
      findsNothing,
    );
    expect(find.text('Bayar kos bulan ini'), findsNothing);
  });

  testWidgets('Beranda: centang kebiasaan tidak menggeser baris', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final oldEaten = Map<String, bool>.from(AppState.I.eaten);
    addTearDown(() {
      AppState.I.eaten
        ..clear()
        ..addAll(oldEaten);
    });

    await pumpHome(tester, size: const Size(360, 900), scale: 1.0);
    await tester.ensureVisible(find.text('Booster BB'));
    await tester.pump(const Duration(milliseconds: 100));

    final air = find.text('Air 2,5–3 L');
    final slot = find.text('Tambah tugas');
    final beforeAir = tester.getRect(air);
    final beforeSlot = tester.getRect(slot);

    await tester.tap(find.text('Booster BB'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.getRect(air), beforeAir);
    expect(tester.getRect(slot), beforeSlot);

    final now = DateTime.now();
    expect(
      AppState.I.eaten['boost_${now.year}_${now.month}_${now.day}'],
      isTrue,
    );

    // Biarkan timer throttle AppState.save selesai sebelum tree dibuang.
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('Beranda: kartu menu memakai judul & cuplikan bersih', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpHome(tester, size: const Size(360, 900), scale: 1.0);
    await tester.scrollUntilVisible(
      find.text('Sayur'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Sayur'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('PAKET F · MENU HARIAN'), findsOneWidget);
    expect(find.text('Nila + Tahu + Oyong'), findsOneWidget);
    expect(find.textContaining('Nasi setengah matang'), findsOneWidget);
    expect(find.text('Rp19.000 /hari'), findsOneWidget);
  });

  testWidgets('Beranda: Lihat semua membuka Jadwal lalu Planning', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? nav;
    await pumpHome(
      tester,
      size: const Size(360, 900),
      scale: 1.0,
      onNavigate: (page) => nav = page,
    );

    await tester.tap(find.text('Lihat semua').first);
    await tester.pump(const Duration(milliseconds: 60));
    expect(nav, 'jadwal');

    await tester.ensureVisible(find.text('Lihat semua').last);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Lihat semua').last);
    await tester.pump(const Duration(milliseconds: 60));
    expect(nav, 'planning');
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('Beranda: slot Tambah tugas membuka editor', (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpHome(tester, size: const Size(360, 900), scale: 1.0);
    await tester.ensureVisible(find.text('Tambah tugas'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Tambah tugas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Tugas baru'), findsOneWidget);
  });
}

void _noop(String _) {}
