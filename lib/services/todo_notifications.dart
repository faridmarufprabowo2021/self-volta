// Layanan notifikasi sistem untuk pengingat To-Do (flutter_local_notifications).
// Target utama Android (rilis APK). Di web/desktop layanan ini nonaktif dan
// pengingat dijalankan sebagai banner in-app, sehingga aplikasi tetap utuh.
//
// Catatan: receiver/reschedule plugin digabung otomatis lewat manifest
// merger, jadi dari sisi app hanya perlu menambah uses-permission.

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class TodoNotif {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Plugin berhasil diinisialisasi (perangkat Android + binding siap).
  static bool ready = false;

  /// Izin POST_NOTIFICATIONS sudah diberikan user.
  static bool granted = false;

  /// Pilihan nada dering user: 'sistem' | 'ding' | 'chime' | 'lembut'.
  /// Default 'sistem' = nada notifikasi bawaan HP (tidak ada aset dibundel
  /// yang dipaksakan sebelum user memilih).
  static String sound = 'sistem';

  /// Getar saat notifikasi muncul (mengikuti pola bawaan Android).
  static bool vibrate = true;

  /// Dipanggil saat user mengetuk notifikasi / alarm layar penuh.
  static void Function(String payload)? onPayload;

  /// Dipanggil setiap kali setelan notifikasi berubah / setelah load.
  static void configure({required String sound, required bool vibrate}) {
    TodoNotif.sound = sound;
    TodoNotif.vibrate = vibrate;
  }

  /// Inisialisasi: panggil satu kali di `main()`.
  static Future<void> init() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(_pickZone()));
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            onPayload?.call(payload);
          }
        },
      );
      // Catatan: izin "alarm presisi" TIDAK diminta di sini. Memintanya
      // membuka halaman Setelan sistem; itu hanya dilakukan saat user
      // menekan tombol izin (requestPermission), bukan tiap app dibuka.
      granted =
          await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;
      ready = true;
    } catch (_) {
      ready = false;
    }
  }

  /// Payload alarm yang membuka app dari keadaan mati (cold start).
  static Future<String?> initialPayload() async {
    if (!ready) return null;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        return details?.notificationResponse?.payload;
      }
    } catch (_) {}
    return null;
  }

  /// Nada efektif untuk satu tugas (kosong = ikut setelan global).
  static String soundFor(String taskSound) =>
      notifSoundKeys.contains(taskSound) ? taskSound : sound;

  static const notifSoundKeys = ['sistem', 'ding', 'chime', 'lembut'];

  static String soundLabel(String key) => switch (key) {
    'ding' => 'Ding',
    'chime' => 'Chime',
    'lembut' => 'Lembut',
    _ => 'Nada sistem',
  };

  /// Pilih zona waktu: nama baku dari OS bila dikenal, kalau tidak
  /// cocokkan zona Indonesia dengan offset perangkat (agar jam
  /// pengingat tidak meleset lintas zona WIB/WITA/WIT).
  static String _pickZone() {
    const candidates = ['Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura'];
    // 1) Nama baku dari OS (mis. "Asia/Jakarta").
    try {
      final name = DateTime.now().timeZoneName;
      if (name.contains('/')) {
        tz.getLocation(name); // melempar bila tidak dikenal
        return name;
      }
    } catch (_) {}
    // 2) Cocokkan kandidat Indonesia berdasarkan offset perangkat.
    final devOffset = DateTime.now().timeZoneOffset;
    for (final c in candidates) {
      try {
        final loc = tz.getLocation(c);
        if (tz.TZDateTime.now(loc).timeZoneOffset == devOffset) return c;
      } catch (_) {}
    }
    return 'Asia/Jakarta';
  }

  /// Minta izin notifikasi (dipanggil dari tombol penjelasan di sheet
  /// To-Do — user-initiated, bukan saat app menyala otomatis).
  static Future<bool> requestPermission() async {
    if (!ready) return false;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      try {
        await android?.requestExactAlarmsPermission();
      } catch (_) {}
      granted = await android?.areNotificationsEnabled() ?? false;
    } catch (_) {
      granted = false;
    }
    return granted;
  }

  /// Minta izin Android 14+ agar alarm boleh membuka layar penuh dari
  /// lockscreen. `null` = perangkat/versi tidak membutuhkan izin.
  static Future<bool?> requestFullScreenPermission() async {
    if (!ready) return null;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestFullScreenIntentPermission();
    } catch (_) {
      return null;
    }
  }

  /// Minta izin SEKALI saat app pertama kali dibuka. Bila user pernah
  /// menolak, jangan menagih lagi tiap app dibuka (bisa dibuka manual dari
  /// sheet To-Do / Pengingat Latihan).
  static Future<bool> ensurePermissionOnce() async {
    if (!ready) return false;
    if (granted) return true;
    try {
      final sp = await SharedPreferences.getInstance();
      if (sp.getBool(_askedKey) == true) return false;
      await sp.setBool(_askedKey, true);
    } catch (_) {}
    return requestPermission();
  }

  static const _askedKey = 'notif_izin_diminta_v1';

  /// Id notifikasi pengingat latihan: satu slot per hari (Senin..Minggu).
  static const int _workoutIdBase = 700000000;

  /// Sinkronkan jadwal pengingat satu tugas: batalkan jadwal lama lalu
  /// jadwal ulang bila memenuhi syarat (belum selesai, pengingat aktif,
  /// ada jam, dan waktunya masih di depan).
  static Future<void> sync({
    required int id,
    required String title,
    required String note,
    required String dateKey, // "yyyy-MM-dd"
    required int timeMin, // menit dalam sehari, -1 = tanpa jam
    required bool reminder,
    required bool done,
    String sound = '',
    bool alarm = false,
    String repeat = '',
  }) async {
    if (!ready) return;
    final nid = id % 2147483647;
    await _safeCancel(nid);
    if (done || !reminder || timeMin < 0 || dateKey.length < 10) return;
    final when = _dateAt(dateKey, timeMin);
    if (when == null || !when.isAfter(tz.TZDateTime.now(tz.local))) return;
    final body = note.isEmpty
        ? 'Tugas to-do SELF VOLTA menunggu selesai.'
        : note;
    final payload = jsonEncode({
      'id': id,
      't': title,
      'd': dateKey,
      'tm': timeMin,
      's': sound,
      'a': alarm,
      'rep': repeat,
    });
    // Alarm presisi dulu; bila ditolak OS → fallback inexact.
    try {
      await _schedule(
        nid,
        'Waktunya: $title',
        body,
        when,
        exact: true,
        sound: sound,
        alarm: alarm,
        payload: payload,
      );
    } catch (_) {
      try {
        await _schedule(
          nid,
          'Waktunya: $title',
          body,
          when,
          exact: false,
          sound: sound,
          alarm: alarm,
          payload: payload,
        );
      } catch (_) {}
    }
  }

  /// Notifikasi percobaan (tombol "Tes nada"): memakai kanal yang sama
  /// dengan pengingat asli, jadi user mendengar nada yang benar-benar
  /// akan dipakai.
  static Future<void> showTest({String sound = ''}) async {
    if (!ready) return;
    try {
      await _plugin.show(
        424242,
        'Tes nada pengingat',
        'Beginilah bunyi pengingat SELF VOLTA di perangkatmu.',
        _details(
          kind: 'todo',
          channelName: 'Pengingat To-Do',
          channelDesc: 'Pengingat tugas harian SELF VOLTA',
          soundKey: sound,
        ),
      );
    } catch (_) {}
  }

  static Future<void> cancel(int id) async {
    if (!ready) return;
    await _safeCancel(id % 2147483647);
  }

  static Future<void> cancelAll() async {
    if (!ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// Pengingat latihan mingguan sesuai jadwal pilihan user (bisa >1 hari).
  /// Setiap hari memakai id tetap supaya sinkronisasi ulang tidak
  /// menumpuk notifikasi ganda.
  static Future<void> syncWorkout({
    required bool on,
    required Set<int> days,
    required int timeMin,
  }) async {
    if (!ready) return;
    await cancelWorkout();
    if (!on || days.isEmpty || timeMin < 0) return;
    const body =
        'Sesi kalistenik SELF VOLTA menunggumu. Buka app dan centang progres hari ini.';
    for (final wd in days) {
      if (wd < DateTime.monday || wd > DateTime.sunday) continue;
      final when = _nextWeekday(wd, timeMin);
      if (when == null) continue;
      final nid = _workoutIdBase + wd;
      try {
        await _scheduleWeekly(nid, 'Waktunya latihan', body, when, exact: true);
      } catch (_) {
        try {
          await _scheduleWeekly(
            nid,
            'Waktunya latihan',
            body,
            when,
            exact: false,
          );
        } catch (_) {}
      }
    }
  }

  static Future<void> cancelWorkout() async {
    if (!ready) return;
    for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++) {
      await _safeCancel(_workoutIdBase + wd);
    }
  }

  /// Id khusus notifikasi uji terjadwal (jangan bertabrakan dengan id tugas
  /// maupun id pengingat latihan 700000001..700000007).
  static const int _testId = 710000099;

  /// Notifikasi uji **terjadwal** (default 10 detik lagi).
  ///
  /// Bedanya dengan [showTest]: `show()` langsung menampilkan notifikasi dari
  /// proses app, sedangkan jalur ini benar-benar memakai AlarmManager → kalau
  /// receiver di AndroidManifest hilang, yang ini tidak akan pernah muncul.
  /// Jadi tombol ini adalah cara tercepat memastikan pengingat benar-benar
  /// bekerja di HP. Uji ini sengaja memakai jalur alarm layar penuh agar
  /// perilaku yang diuji sama dengan alarm tugas sesungguhnya.
  static Future<bool> scheduleTest({int seconds = 10}) async {
    if (!ready) return false;
    const title = 'Tes alarm SELF VOLTA';
    const body = 'Geser "Selesaikan" untuk menghentikan alarm percobaan ini.';
    final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
    final payload = jsonEncode({
      'id': _testId,
      't': 'Alarm percobaan',
      'd':
          '${when.year}-${when.month.toString().padLeft(2, '0')}-'
          '${when.day.toString().padLeft(2, '0')}',
      'tm': when.hour * 60 + when.minute,
      's': '',
      'a': true,
      'rep': '',
    });
    try {
      await _plugin.zonedSchedule(
        _testId,
        title,
        body,
        when,
        _details(
          kind: 'alarm',
          channelName: 'Alarm To-Do',
          channelDesc: 'Alarm layar penuh SELF VOLTA',
          body: body,
          alarm: true,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      return true;
    } catch (_) {
      // Izin "Alarm & pengingat" ditolak → pakai alarm tidak presisi.
      try {
        await _plugin.zonedSchedule(
          _testId,
          title,
          body,
          when,
          _details(
            kind: 'alarm',
            channelName: 'Alarm To-Do',
            channelDesc: 'Alarm layar penuh SELF VOLTA',
            body: body,
            alarm: true,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  // ---- internal ----

  /// Kemunculan berikutnya untuk `weekday` (1=Senin..7=Minggu) pada jam
  /// `timeMin` menit setelah tengah malam waktu lokal.
  static tz.TZDateTime? _nextWeekday(int weekday, int timeMin) {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeMin ~/ 60,
      timeMin % 60,
    );
    for (var i = 0; i < 8; i++) {
      if (d.weekday == weekday && d.isAfter(now)) return d;
      // Konstruksi ulang (bukan add Duration) supaya jam tetap sama.
      d = tz.TZDateTime(
        tz.local,
        d.year,
        d.month,
        d.day + 1,
        timeMin ~/ 60,
        timeMin % 60,
      );
    }
    return null;
  }

  /// Jadwal berulang tiap minggu pada hari & jam yang sama.
  static Future<void> _scheduleWeekly(
    int nid,
    String title,
    String body,
    tz.TZDateTime when, {
    required bool exact,
  }) async {
    await _plugin.zonedSchedule(
      nid,
      title,
      body,
      when,
      _details(
        kind: 'latihan',
        channelName: 'Pengingat Latihan',
        channelDesc: 'Pengingat jadwal latihan SELF VOLTA',
        body: body,
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime? _dateAt(String dateKey, int timeMin) {
    try {
      final y = int.parse(dateKey.substring(0, 4));
      final m = int.parse(dateKey.substring(5, 7));
      final d = int.parse(dateKey.substring(8, 10));
      return tz.TZDateTime(tz.local, y, m, d, timeMin ~/ 60, timeMin % 60);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _safeCancel(int nid) async {
    try {
      await _plugin.cancel(nid);
    } catch (_) {}
  }

  static Future<void> _schedule(
    int nid,
    String title,
    String body,
    tz.TZDateTime when, {
    required bool exact,
    String sound = '',
    bool alarm = false,
    String? payload,
  }) async {
    await _plugin.zonedSchedule(
      nid,
      title,
      body,
      when,
      _details(
        kind: 'todo',
        channelName: alarm ? 'Alarm To-Do' : 'Pengingat To-Do',
        channelDesc: alarm
            ? 'Alarm layar penuh SELF VOLTA'
            : 'Pengingat tugas harian SELF VOLTA',
        body: body,
        soundKey: sound,
        alarm: alarm,
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Sidik setelan kanal. Android mengunci **nada** dan **getar** sebuah kanal
  /// begitu kanal itu dibuat, jadi keduanya harus masuk ke id kanal; kanal baru
  /// otomatis tercipta saat user mengganti salah satunya.
  static String _channelKey(String soundKey) {
    final s = soundFor(soundKey);
    return '${s}_${vibrate ? 'getar' : 'senyap'}';
  }

  /// Detail notifikasi Android. Nada & getar mengikuti setelan user atau
  /// nada khusus tugas. Alarm memakai jalur layar penuh + kategori alarm.
  static NotificationDetails _details({
    required String kind, // 'todo' | 'latihan'
    required String channelName,
    required String channelDesc,
    String? body,
    String soundKey = '',
    bool alarm = false,
  }) {
    final effective = soundFor(soundKey);
    final soundRes = switch (effective) {
      'ding' => 'notif_ding',
      'chime' => 'notif_chime',
      'lembut' => 'notif_lembut',
      _ => null,
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        '${kind}_${_channelKey(soundKey)}_v3',
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: soundRes == null
            ? null
            : RawResourceAndroidNotificationSound(soundRes),
        enableVibration: vibrate,
        category: alarm
            ? AndroidNotificationCategory.alarm
            : AndroidNotificationCategory.reminder,
        fullScreenIntent: alarm,
        visibility: NotificationVisibility.public,
        audioAttributesUsage: alarm
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
        ongoing: alarm,
        autoCancel: !alarm,
        styleInformation: body == null ? null : BigTextStyleInformation(body),
      ),
    );
  }
}
