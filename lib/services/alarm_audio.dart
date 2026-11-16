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

  /// Penanda preview aktif; start/stop lain membatalkan preview agar alarm
  /// sungguhan tidak ikut dimatikan oleh timer preview.
  static int _previewToken = 0;

  /// Mulai nada alarm berulang. `sound` = '', 'sistem', 'ding', 'chime',
  /// 'lembut', atau 'kustom'.
  static Future<void> start({String sound = ''}) async {
    if (!_supported) return;
    _previewToken++;
    try {
      await _channel.invokeMethod<void>('start', {'sound': sound});
    } catch (_) {}
  }

  static Future<void> stop() async {
    if (!_supported) return;
    _previewToken++;
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (_) {}
  }

  /// Buka pemilih file audio milik user, lalu simpan sebagai nada alarm.
  ///
  /// Mengembalikan nama file yang dipilih, `null` bila user batal, atau
  /// melempar [PlatformException] bila file terlalu besar / tidak terbaca.
  static Future<String?> pickCustom() async {
    if (!_supported) return null;
    return _channel.invokeMethod<String>('pickCustom');
  }

  /// Hapus file nada kustom dari penyimpanan app.
  static Future<void> clearCustom() async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('clearCustom');
    } catch (_) {}
  }

  /// Putar nada kustom ±6 detik sebagai contoh, lalu berhenti sendiri.
  static Future<void> previewCustom() async {
    if (!_supported) return;
    final token = ++_previewToken;
    try {
      await _channel.invokeMethod<void>('start', {'sound': 'kustom'});
    } catch (_) {
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 6));
    if (token != _previewToken) return;
    _previewToken++;
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (_) {}
  }

  /// Hentikan preview nada kustom tanpa menyentuh alarm yang sedang tampil.
  static Future<void> stopPreview() async {
    if (!_supported) return;
    _previewToken++;
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
