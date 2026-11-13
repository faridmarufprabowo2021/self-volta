import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:self_volta/store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    st.workoutReminderOn = true;
    st.workoutReminderDays = {1, 3, 5};
    st.workoutReminderMin = 16 * 60 + 30;
    await st.flushNow();
  });

  test('default pengingat latihan: Sen/Rab/Jum 16.30, aktif', () {
    final st = AppState.I;
    expect(st.workoutReminderOn, true);
    expect(st.workoutReminderDays, {1, 3, 5});
    expect(st.workoutReminderMin, 16 * 60 + 30);
    expect(st.workoutReminderTimeLabel, '16.30');
    expect(st.workoutReminderDaysLabel, 'Sen · Rab · Jum');
    expect(st.workoutReminderShort, '16.30');
  });

  test('jadwal bisa diubah user (hari + jam) dan label ikut', () async {
    final st = AppState.I;
    await st.setWorkoutReminder(days: {2, 4, 6, 7});
    expect(st.workoutReminderDaysLabel, 'Sel · Kam · Sab · Min');
    await st.setWorkoutReminder(timeMin: 6 * 60 + 5);
    expect(st.workoutReminderTimeLabel, '06.05');
    await st.setWorkoutReminder(on: false);
    expect(st.workoutReminderShort, 'Notif mati');
    await st.setWorkoutReminder(on: true);
    expect(st.workoutReminderShort, '06.05');
  });

  test('semua hari dipilih -> label "Setiap hari"', () async {
    final st = AppState.I;
    await st.setWorkoutReminder(days: {1, 2, 3, 4, 5, 6, 7});
    expect(st.workoutReminderDaysLabel, 'Setiap hari');
  });

  test('hari kosong saat aktif -> otomatis pilih hari ini', () async {
    final st = AppState.I;
    await st.setWorkoutReminder(days: <int>{});
    expect(st.workoutReminderDays.isNotEmpty, true);
    expect(st.workoutReminderDays, {DateTime.now().weekday});
  });

  test('jadwal ikut tersimpan di sv_v1 (kompatibel data lama)', () async {
    final st = AppState.I;
    await st.setWorkoutReminder(days: {2, 5}, timeMin: 19 * 60 + 15);
    final map = jsonDecode(jsonEncode(st.toJson())) as Map<String, dynamic>;
    expect(map['workoutReminderOn'], true);
    expect(map['workoutReminderDays'], [2, 5]);
    expect(map['workoutReminderMin'], 19 * 60 + 15);
  });

  test('resync notifikasi aman walau plugin tidak tersedia', () async {
    // Di test (non-Android) TodoNotif.ready == false: tidak boleh melempar.
    await AppState.I.resyncNotifications();
    expect(AppState.I.workoutReminderDays.isNotEmpty, true);
  });
}
