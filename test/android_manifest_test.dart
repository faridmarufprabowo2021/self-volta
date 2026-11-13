// Penjaga regresi untuk dua bug nyata yang pernah lolos ke APK:
//
// 1. `flutter_local_notifications` >= 16 TIDAK lagi mendeklarasikan receiver
//    di manifest-nya sendiri. Tanpa dua receiver di manifest app, pengingat
//    terjadwal tidak pernah muncul (AlarmManager menyala, broadcast tidak ada
//    penerima). Gejalanya: "tes nada" jalan, pengingat tugas tidak.
// 2. Resource shrinker R8 membuang `res/raw/notif_*.wav` karena hanya
//    dirujuk dari Dart, sehingga pilihan nada jatuh ke nada sistem.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');

  test('manifest mendeklarasikan receiver penjadwal notifikasi', () {
    expect(manifest.existsSync(), isTrue);
    final xml = manifest.readAsStringSync();
    expect(
      xml,
      contains(
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
      ),
      reason:
          'Tanpa receiver ini notifikasi terjadwal tidak pernah tampil. '
          'Lihat README flutter_local_notifications bagian AndroidManifest.',
    );
    expect(
      xml,
      contains(
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
      ),
      reason: 'Tanpa receiver ini pengingat hilang setelah HP di-reboot.',
    );
    expect(xml, contains('android.intent.action.BOOT_COMPLETED'));
    expect(xml, contains('android.intent.action.MY_PACKAGE_REPLACED'));
  });

  test('manifest memuat izin notifikasi yang dibutuhkan', () {
    final xml = manifest.readAsStringSync();
    for (final p in const [
      'android.permission.POST_NOTIFICATIONS',
      'android.permission.SCHEDULE_EXACT_ALARM',
      'android.permission.RECEIVE_BOOT_COMPLETED',
      'android.permission.VIBRATE',
      'android.permission.USE_FULL_SCREEN_INTENT',
      'android.permission.WAKE_LOCK',
    ]) {
      expect(xml, contains(p), reason: 'Izin $p hilang dari manifest.');
    }
  });

  test('activity siap membuka alarm dari layar terkunci', () {
    final xml = manifest.readAsStringSync();
    expect(xml, contains('android:showWhenLocked="true"'));
    expect(xml, contains('android:turnScreenOn="true"'));
  });

  test('nada dering tidak dibuang resource shrinker', () {
    const keep = 'android/app/src/main/res/raw/keep.xml';
    expect(File(keep).existsSync(), isTrue);
    final xml = File(keep).readAsStringSync();
    for (final name in const ['notif_ding', 'notif_chime', 'notif_lembut']) {
      expect(xml, contains('@raw/$name'));
      expect(
        File('android/app/src/main/res/raw/$name.wav').existsSync(),
        isTrue,
        reason: 'Aset $name.wav hilang.',
      );
    }
  });
}
