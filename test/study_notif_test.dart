import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:self_volta/services/todo_notifications.dart';
import 'package:self_volta/store.dart';
import 'package:self_volta/theme.dart';
import 'package:self_volta/pages/study_page.dart';
import 'package:self_volta/pages/todo_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    st.studySubjects = [];
    st.studySessions = [];
    st.notifSound = 'sistem';
    st.notifVibrate = true;
    await st.flushNow();
  });

  test('default notifikasi: nada sistem + getar aktif', () {
    final st = AppState.I;
    expect(st.notifSound, 'sistem');
    expect(st.notifVibrate, true);
    expect(st.notifSoundLabel, 'Nada sistem');
    expect(TodoNotif.sound, 'sistem');
  });

  test('pilihan nada disimpan & diteruskan ke TodoNotif', () async {
    final st = AppState.I;
    await st.setNotifPrefs(sound: 'chime', vibrate: false);
    expect(st.notifSound, 'chime');
    expect(st.notifVibrate, false);
    expect(st.notifSoundLabel, 'Chime');
    expect(TodoNotif.sound, 'chime');
    expect(TodoNotif.vibrate, false);

    final map = jsonDecode(jsonEncode(st.toJson())) as Map<String, dynamic>;
    expect(map['notifSound'], 'chime');
    expect(map['notifVibrate'], false);
  });

  test('nada tidak dikenal diabaikan (data lama tetap aman)', () async {
    final st = AppState.I;
    await st.setNotifPrefs(sound: 'metal');
    expect(st.notifSound, 'sistem');
  });

  test(
    'study: tambah pelajaran, catat sesi, hitung minggu & hari ini',
    () async {
      final st = AppState.I;
      await st.addStudySubject('Matematika', 120);
      expect(st.studySubjects.length, 1);
      final id = st.studySubjects.single.id;

      await st.logStudy(id, 25);
      await st.logStudy(id, 15);

      expect(st.studyMinutesWeek, 40);
      expect(st.studySessionsToday, 2);
      expect(st.studyMinutesWeekOf(id), 40);
      expect(st.studyLast7Minutes.length, 7);
      expect(st.studyLast7Minutes.last, 40);
    },
  );

  test(
    'study: nama kosong tidak menambah pelajaran, hapus ikut sesi',
    () async {
      final st = AppState.I;
      await st.addStudySubject('   ', 180);
      expect(st.studySubjects, isEmpty);

      await st.addStudySubject('Fisika', 180);
      final id = st.studySubjects.single.id;
      await st.logStudy(id, 30);
      await st.deleteStudySubject(id);
      expect(st.studySubjects, isEmpty);
      expect(st.studySessions, isEmpty);
      expect(st.studyMinutesWeek, 0);
    },
  );

  test('study tersimpan di sv_v1 dan terbaca lagi (kompatibel)', () async {
    final st = AppState.I;
    await st.addStudySubject('Bahasa Inggris', 300);
    await st.logStudy(st.studySubjects.single.id, 50);

    final map = jsonDecode(jsonEncode(st.toJson())) as Map<String, dynamic>;
    expect((map['studySubjects'] as List).length, 1);
    expect((map['studySessions'] as List).length, 1);

    // Terapkan ulang seperti saat app dibuka.
    final snapshot = jsonDecode(jsonEncode(map)) as Map<String, dynamic>;
    await st.importJson(snapshot);
    expect(st.studySubjects.single.name, 'Bahasa Inggris');
    expect(st.studyMinutesWeek, 50);
  });

  test('target study di-clamp ke rentang wajar', () async {
    final st = AppState.I;
    await st.addStudySubject('Koding', 5);
    expect(st.studySubjects.single.targetMin, 30);
  });

  testWidgets('StudyPage: tombol +15 menambah sesi & memperbarui UI', (
    tester,
  ) async {
    final loader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-Variable.ttf'));
    await loader.load();

    final st = AppState.I;
    st.studySubjects = [
      const StudySubject(id: 1, name: 'Matematika', targetMin: 180),
    ];
    st.studySessions = [];
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(body: StudyPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('0 / 180 menit minggu ini'), findsOneWidget);
    await tester.tap(find.text('+15'));
    await tester.pump();
    // Beri waktu debounce 300 ms agar save() tidak tertinggal sebagai timer.
    await tester.pump(const Duration(milliseconds: 400));

    expect(st.studyMinutesWeek, 15);
    expect(find.text('15 / 180 menit minggu ini'), findsOneWidget);
    // Total 7 hari juga ikut bertambah (teks "15 menit" muncul di header
    // kartu grafik, jadi boleh lebih dari satu).
    expect(find.text('15 menit'), findsWidgets);
  });

  testWidgets('StudyPage dengan data 7 hari tidak error di layar sempit', (
    tester,
  ) async {
    final loader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-Variable.ttf'));
    await loader.load();

    final st = AppState.I;
    st.studySubjects = [
      const StudySubject(id: 1, name: 'Bahasa Inggris', targetMin: 300),
    ];
    st.studySessions = [
      for (var i = 0; i < 7; i++)
        StudySession(
          subjectId: 1,
          date: dKey(DateTime.now().subtract(Duration(days: i))),
          minutes: 15 + i * 10,
        ),
    ];

    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final problems = <String>[];
    final old = FlutterError.onError;
    FlutterError.onError = (d) =>
        problems.add('${d.exceptionAsString()} @ ${d.context}');
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(1.3),
            ),
            child: const Scaffold(body: StudyPage()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
    } finally {
      FlutterError.onError = old;
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
    expect(find.text('7 hari terakhir'), findsOneWidget);
  });
}
