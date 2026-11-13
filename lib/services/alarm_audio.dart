// Jembatan audio alarm ke Android asli.
//
// Flutter tidak punya pemutar audio looping bawaan. Supaya alarm layar penuh
// benar-benar berbunyi terus di layar terkunci (tanpa menambah package), UI
// memanggil MethodChannel ini. Di web/desktop semua panggilan menjadi no-op
// agar preview tetap berjalan.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AlarmAudio {
  static const _channel = MethodChannel('selfvolta/alarm');

  static bool get _supported => !kIsWeb && Platform.isAndroid;

  /// Mulai nada alarm berulang. `sound` = '', 'sistem', 'ding', 'chime',
  /// atau 'lembut'.
  static Future<void> start({String sound = ''}) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('start', {'sound': sound});
    } catch (_) {}
  }

  static Future<void> stop() async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (_) {}
  }

  /// Nyalakan/matikan mode layar alarm: tampil di atas lockscreen, bangunkan
  /// layar, dan jaga layar tetap menyala selama alarm.
  static Future<void> setAlarmMode(bool on) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('alarmMode', {'on': on});
    } catch (_) {}
  }
}
