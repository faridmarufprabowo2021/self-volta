// Perilaku tugas versi baru: nada per tugas, pengulangan, alarm layar penuh,
// dan tracker rutinitas bulanan.

import 'package:flutter_test/flutter_test.dart';
import 'package:self_volta/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _fresh() async {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  await AppState.I.resetAllData();
  await AppState.I.load();
  AppState.I.todos = [];
  AppState.I.routineMarks = [];
}

String _day(int offset) {
  final n = DateTime.now().add(Duration(days: offset));
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-'
      '${n.day.toString().padLeft(2, '0')}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SvTask menyimpan nada, pengulangan, alarm, dan rutinitas', () {
    const t = SvTask(
      id: 7,
      title: 'Bangun',
      sound: 'ding',
      repeat: 'harian',
      alarm: true,
      routine: true,
      seriesId: 3,
    );
    final back = SvTask.fromJson(t.toJson());
    expect(back.sound, 'ding');
    expect(back.repeat, 'harian');
    expect(back.alarm, isTrue);
    expect(back.routine, isTrue);
    expect(back.seriesId, 3);
  });

  test('data lama tanpa field baru tetap aman', () {
    final t = SvTask.fromJson(const {'id': 1, 't': 'Lama'});
    expect(t.sound, '');
    expect(t.repeat, '');
    expect(t.alarm, isFalse);
    expect(t.routine, isFalse);
    expect(t.seriesId, 0);
  });

  test('rutinitas tuntas tercatat di tracker bulan ini', () async {
    await _fresh();
    AppState.I.todos = [
      SvTask(
        id: 1,
        title: 'Jalan pagi',
        routine: true,
        date: _day(0),
        timeMin: 360,
      ),
    ];
    await AppState.I.toggleTodo(1);
    expect(AppState.I.todos.single.done, isTrue);
    expect(AppState.I.routineMarks.single.title, 'Jalan pagi');
    expect(AppState.I.routineDaysIn(AppState.todayKey.substring(0, 7)), 1);
  });

  test(
    'tugas harian melahirkan occurrence besok dengan setelan sama',
    () async {
      await _fresh();
      AppState.I.todos = [
        SvTask(
          id: 10,
          title: 'Tahajjud',
          date: _day(0),
          timeMin: 240,
          repeat: 'harian',
          alarm: true,
          sound: 'chime',
          routine: true,
        ),
      ];
      await AppState.I.toggleTodo(10);
      expect(AppState.I.todos, hasLength(2));
      final next = AppState.I.todos.singleWhere((t) => !t.done);
      expect(next.date, _day(1));
      expect(next.repeat, 'harian');
      expect(next.alarm, isTrue);
      expect(next.sound, 'chime');
      expect(next.routine, isTrue);
      expect(next.seriesId, 10);
      expect(next.timeMin, 240);
    },
  );

  test(
    'alarm selesai selalu masuk tracker walau rutinitas dimatikan',
    () async {
      await _fresh();
      AppState.I.todos = [
        SvTask(id: 20, title: 'Minum air', date: _day(0), timeMin: 420),
      ];
      await AppState.I.completeTodoFromAlarm(20);
      expect(AppState.I.todos.single.done, isTrue);
      expect(AppState.I.routineMarks, hasLength(1));
      expect(AppState.I.routineMarks.single.title, 'Minum air');
    },
  );

  test('RoutineMark bertahan lewat JSON cadangan', () {
    const m = RoutineMark(date: '2026-11-13', taskId: 4, title: 'Baca');
    final back = RoutineMark.fromJson(m.toJson());
    expect(back.date, '2026-11-13');
    expect(back.taskId, 4);
    expect(back.title, 'Baca');
  });
}
