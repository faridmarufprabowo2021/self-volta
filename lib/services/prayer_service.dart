// Prayer Times (Jadwal Sholat) Service for SELF VOLTA
// Real-Time & Continuous Astronomical Calculations (Standard Kemenag RI / Indonesia)
// 100% Offline Capable, Zero-Latency, Cached for High Performance (Anti-Lag 60-120 FPS)

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class CityLocation {
  final String name;
  final double latitude;
  final double longitude;
  final double timezone;

  const CityLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });
}

const List<CityLocation> kIndonesianCities = [
  // Solo Raya & Jawa Tengah (Permintaan Spesifik Pengguna)
  CityLocation(
    name: 'Surakarta / Solo (WIB)',
    latitude: -7.5755,
    longitude: 110.8243,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Sukoharjo (WIB)',
    latitude: -7.6833,
    longitude: 110.8333,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Boyolali (WIB)',
    latitude: -7.5317,
    longitude: 110.5960,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Karanganyar (WIB)',
    latitude: -7.5964,
    longitude: 110.9520,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Klaten (WIB)',
    latitude: -7.7058,
    longitude: 110.6033,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Wonogiri (WIB)',
    latitude: -7.8136,
    longitude: 110.9255,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Sragen (WIB)',
    latitude: -7.4266,
    longitude: 111.0222,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Yogyakarta (WIB)',
    latitude: -7.7956,
    longitude: 110.3695,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Semarang (WIB)',
    latitude: -6.9667,
    longitude: 110.4167,
    timezone: 7.0,
  ),
  // Kota-kota Metropolitan Indonesia
  CityLocation(
    name: 'Jakarta (WIB)',
    latitude: -6.2088,
    longitude: 106.8456,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Bandung (WIB)',
    latitude: -6.9175,
    longitude: 107.6191,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Surabaya (WIB)',
    latitude: -7.2575,
    longitude: 112.7521,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Medan (WIB)',
    latitude: 3.5952,
    longitude: 98.6722,
    timezone: 7.0,
  ),
  CityLocation(
    name: 'Makassar (WITA)',
    latitude: -5.1477,
    longitude: 119.4327,
    timezone: 8.0,
  ),
  CityLocation(
    name: 'Denpasar (WITA)',
    latitude: -8.6705,
    longitude: 115.2126,
    timezone: 8.0,
  ),
];

class PrayerSchedule {
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final DateTime imsakTime;
  final DateTime subuhTime;
  final DateTime terbitTime;
  final DateTime dhuhaTime;
  final DateTime dzuhurTime;
  final DateTime asharTime;
  final DateTime maghribTime;
  final DateTime isyaTime;

  const PrayerSchedule({
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.imsakTime,
    required this.subuhTime,
    required this.terbitTime,
    required this.dhuhaTime,
    required this.dzuhurTime,
    required this.asharTime,
    required this.maghribTime,
    required this.isyaTime,
  });
}

class PrayerService extends ChangeNotifier {
  static final PrayerService instance = PrayerService._();
  PrayerService._() {
    _startTimer();
  }

  CityLocation _selectedCity = kIndonesianCities[0];
  Timer? _timer;
  DateTime _now = DateTime.now();

  // Cache untuk mencegah perhitungan berulang setiap detik (Anti-Lag)
  PrayerSchedule? _cachedSchedule;
  int? _cachedDay;
  String? _cachedCity;

  CityLocation get selectedCity => _selectedCity;
  DateTime get now => _now;

  void setCity(CityLocation city) {
    _selectedCity = city;
    _cachedSchedule = null;
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static double _d2r(double d) => d * pi / 180.0;
  static double _r2d(double r) => r * 180.0 / pi;
  static double _sinD(double d) => sin(_d2r(d));
  static double _cosD(double d) => cos(_d2r(d));
  static double _tanD(double d) => tan(_d2r(d));
  static double _asinD(double x) => _r2d(asin(x.clamp(-1.0, 1.0)));
  static double _acosD(double x) => _r2d(acos(x.clamp(-1.0, 1.0)));

  PrayerSchedule getTodaySchedule([DateTime? date]) {
    final d = date ?? _now;
    if (date == null &&
        _cachedSchedule != null &&
        _cachedDay == d.day &&
        _cachedCity == _selectedCity.name) {
      return _cachedSchedule!;
    }

    final lat = _selectedCity.latitude;
    final lng = _selectedCity.longitude;
    final tz = _selectedCity.timezone;

    final n = d.difference(DateTime(d.year, 1, 1)).inDays + 1;
    final m = 357.5291 + 0.98560028 * n;
    final c = 1.9148 * _sinD(m) + 0.02 * _sinD(2 * m) + 0.0003 * _sinD(3 * m);
    final l = 280.4665 + 0.98564736 * n + c;
    final eps = 23.439 - 0.00000036 * n;
    final decl = _asinD(_sinD(eps) * _sinD(l));

    final varY = pow(_tanD(eps / 2.0), 2);
    final eqT =
        4 *
        _r2d(
          varY * _sinD(2 * l) -
              2 * 0.0167 * _sinD(m) +
              4 * 0.0167 * varY * _sinD(m) * _cosD(2 * l) -
              0.5 * pow(varY, 2) * _sinD(4 * l) -
              1.25 * pow(0.0167, 2) * _sinD(2 * m),
        );

    final noon = 12.0 + tz - (lng / 15.0) - (eqT / 60.0);

    // Kemenag standard: Subuh -20 deg, Isya -18 deg, +2 min ihtiyat
    final cosHFajr =
        (_sinD(-20.0) - _sinD(lat) * _sinD(decl)) / (_cosD(lat) * _cosD(decl));
    final hFajr = _acosD(cosHFajr);
    final fajrH = noon - (hFajr / 15.0) + (2.0 / 60.0);

    final cosHRise =
        (_sinD(-0.833) - _sinD(lat) * _sinD(decl)) / (_cosD(lat) * _cosD(decl));
    final hRise = _acosD(cosHRise);
    final sunriseH = noon - (hRise / 15.0);
    final sunsetH = noon + (hRise / 15.0) + (2.0 / 60.0);

    final asrAlt = _r2d(atan(1.0 / (1.0 + _tanD((lat - decl).abs()))));
    final cosHAsr =
        (_sinD(asrAlt) - _sinD(lat) * _sinD(decl)) / (_cosD(lat) * _cosD(decl));
    final hAsr = _acosD(cosHAsr);
    final asrH = noon + (hAsr / 15.0) + (2.0 / 60.0);

    final cosHIsha =
        (_sinD(-18.0) - _sinD(lat) * _sinD(decl)) / (_cosD(lat) * _cosD(decl));
    final hIsha = _acosD(cosHIsha);
    final ishaH = noon + (hIsha / 15.0) + (2.0 / 60.0);
    final noonH = noon + (2.0 / 60.0);

    DateTime toDateTime(double hours) {
      final h = hours % 24;
      final intH = h.floor();
      final intM = ((h - intH) * 60).round();
      final finalH = intM == 60 ? (intH + 1) % 24 : intH;
      final finalM = intM == 60 ? 0 : intM;
      return DateTime(d.year, d.month, d.day, finalH, finalM);
    }

    String fmt(DateTime dt) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    final subuhDt = toDateTime(fajrH);
    final terbitDt = toDateTime(sunriseH);
    final dzuhurDt = toDateTime(noonH);
    final asharDt = toDateTime(asrH);
    final maghribDt = toDateTime(sunsetH);
    final isyaDt = toDateTime(ishaH);

    // Standar Indonesia: Imsak = 10 menit sebelum Subuh, Dhuha = 20 menit setelah Terbit
    final imsakDt = subuhDt.subtract(const Duration(minutes: 10));
    final dhuhaDt = terbitDt.add(const Duration(minutes: 20));

    final sched = PrayerSchedule(
      imsak: fmt(imsakDt),
      subuh: fmt(subuhDt),
      terbit: fmt(terbitDt),
      dhuha: fmt(dhuhaDt),
      dzuhur: fmt(dzuhurDt),
      ashar: fmt(asharDt),
      maghrib: fmt(maghribDt),
      isya: fmt(isyaDt),
      imsakTime: imsakDt,
      subuhTime: subuhDt,
      terbitTime: terbitDt,
      dhuhaTime: dhuhaDt,
      dzuhurTime: dzuhurDt,
      asharTime: asharDt,
      maghribTime: maghribDt,
      isyaTime: isyaDt,
    );

    if (date == null) {
      _cachedSchedule = sched;
      _cachedDay = d.day;
      _cachedCity = _selectedCity.name;
    }

    return sched;
  }

  /// Menentukan jadwal sholat berikutnya dan sisa waktu live
  ({String name, String timeStr, Duration remaining, String activePeriod})
  getNextPrayerInfo() {
    final sched = getTodaySchedule();
    final current = _now;

    if (current.isBefore(sched.imsakTime)) {
      return (
        name: 'Imsak',
        timeStr: sched.imsak,
        remaining: sched.imsakTime.difference(current),
        activePeriod: 'Menjelang Imsak',
      );
    } else if (current.isBefore(sched.subuhTime)) {
      return (
        name: 'Subuh',
        timeStr: sched.subuh,
        remaining: sched.subuhTime.difference(current),
        activePeriod: 'Waktu Imsak',
      );
    } else if (current.isBefore(sched.terbitTime)) {
      return (
        name: 'Terbit',
        timeStr: sched.terbit,
        remaining: sched.terbitTime.difference(current),
        activePeriod: 'Waktu Subuh',
      );
    } else if (current.isBefore(sched.dhuhaTime)) {
      return (
        name: 'Dhuha',
        timeStr: sched.dhuha,
        remaining: sched.dhuhaTime.difference(current),
        activePeriod: 'Waktu Syuruq',
      );
    } else if (current.isBefore(sched.dzuhurTime)) {
      return (
        name: 'Dzuhur',
        timeStr: sched.dzuhur,
        remaining: sched.dzuhurTime.difference(current),
        activePeriod: 'Waktu Dhuha',
      );
    } else if (current.isBefore(sched.asharTime)) {
      return (
        name: 'Ashar',
        timeStr: sched.ashar,
        remaining: sched.asharTime.difference(current),
        activePeriod: 'Waktu Dzuhur',
      );
    } else if (current.isBefore(sched.maghribTime)) {
      return (
        name: 'Maghrib',
        timeStr: sched.maghrib,
        remaining: sched.maghribTime.difference(current),
        activePeriod: 'Waktu Ashar',
      );
    } else if (current.isBefore(sched.isyaTime)) {
      return (
        name: 'Isya',
        timeStr: sched.isya,
        remaining: sched.isyaTime.difference(current),
        activePeriod: 'Waktu Maghrib',
      );
    } else {
      // Menuju Imsak / Subuh besok
      final tmr = current.add(const Duration(days: 1));
      final tmrSched = getTodaySchedule(tmr);
      return (
        name: 'Imsak',
        timeStr: tmrSched.imsak,
        remaining: tmrSched.imsakTime.difference(current),
        activePeriod: 'Waktu Isya / Malam',
      );
    }
  }

  static String formatDuration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
