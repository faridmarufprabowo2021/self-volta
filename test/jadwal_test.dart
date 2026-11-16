import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:self_volta/pages/jadwal_page.dart';
import 'package:self_volta/store.dart';
import 'package:self_volta/theme.dart';

void _noop(String _) {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    st.todos = [];
    st.customAlarmName = '';
    await st.flushNow();
  });

  test('nama nada alarm kustom tersimpan dan terbaca lagi', () async {
    final st = AppState.I;
    await st.setCustomAlarmName('Audio pilihanmu.mp3');
    expect(st.hasCustomAlarm, true);

    final map = jsonDecode(jsonEncode(st.toJson())) as Map<String, dynamic>;
    expect(map['customAlarmName'], 'Audio pilihanmu.mp3');

    // Terapkan ulang seperti saat app dibuka.
    await st.importJson(jsonDecode(jsonEncode(map)) as Map<String, dynamic>);
    expect(st.customAlarmName, 'Audio pilihanmu.mp3');
    expect(st.hasCustomAlarm, true);

    await st.clearCustomAlarm();
    expect(st.customAlarmName, '');
    expect(st.hasCustomAlarm, false);
    expect(st.toJson()['customAlarmName'], '');
  });

  testWidgets('JadwalPage: tugas tampil urut jam & bisa dicentang', (
    tester,
  ) async {
    final loader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-Variable.ttf'));
    await loader.load();

    final st = AppState.I;
    st.todos = [
      const SvTask(
        id: 2,
        title: 'Review materi kimia',
        note: 'Sel volta & reaksi redoks',
        cat: 'Belajar',
        timeMin: 6 * 60,
      ),
      const SvTask(
        id: 1,
        title: 'Bangun pagi',
        cat: 'Kesehatan',
        timeMin: 4 * 60,
        pri: 2,
        alarm: true,
      ),
      const SvTask(id: 3, title: 'Rapikan meja', cat: 'Pribadi'),
    ];

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(body: JadwalPage(onNavigate: (_) {})),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Bangun pagi'), findsOneWidget);
    expect(find.text('Review materi kimia'), findsOneWidget);
    expect(find.text('Rapikan meja'), findsOneWidget);
    expect(find.text('04.00'), findsOneWidget);
    expect(find.text('06.00'), findsOneWidget);
    expect(find.text('3 tersisa'), findsOneWidget);
    expect(find.text('Tanpa jam'), findsOneWidget);

    final y1 = tester.getTopLeft(find.byKey(const Key('jadwal-task-1'))).dy;
    final y2 = tester.getTopLeft(find.byKey(const Key('jadwal-task-2'))).dy;
    expect(y1, lessThan(y2));

    await tester.tap(find.byKey(const Key('jadwal-check-1')));
    await tester.pump(const Duration(milliseconds: 400));

    final bangun = st.todos.firstWhere((t) => t.id == 1);
    expect(bangun.done, true);
    expect(find.text('Selesai · 1'), findsOneWidget);
    expect(find.text('Bangun pagi'), findsNothing);
  });

  testWidgets('JadwalPage: empty state & FAB membuka editor tugas', (
    tester,
  ) async {
    final loader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-Variable.ttf'));
    await loader.load();

    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AppState.I.todos = [];

    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(2.0),
          ),
          child: Scaffold(body: JadwalPage(onNavigate: _noop)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Belum ada jadwal'), findsOneWidget);

    await tester.tap(find.byKey(const Key('jadwal-add')));
    await tester.pumpAndSettle();

    expect(find.text('Tugas baru'), findsOneWidget);
    expect(find.text('Nada alarm kustom'), findsOneWidget);
    expect(find.text('Pilih audio dari HP'), findsOneWidget);

    // Tutup sheet agar timer save/animasi tidak tertinggal.
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pumpAndSettle();
  });
}
