// Cuaca nyata untuk kartu hero Beranda.
//
// Sumber: Open-Meteo (tanpa API key). Titik koordinat diambil dari kota
// jadwal sholat yang dipilih user, jadi cuaca selalu mengikuti lokasi yang
// sama dengan jadwal sholat. Tidak ada data karangan: saat jaringan gagal,
// kartu menampilkan status "tidak tersedia" dan tombol coba lagi.

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'prayer_service.dart';

class WeatherHour {
  final DateTime at;
  final double temperatureC;
  final int code;

  const WeatherHour({
    required this.at,
    required this.temperatureC,
    required this.code,
  });
}

class WeatherSnapshot {
  final double temperatureC;
  final double feelsLikeC;
  final double windKph;
  final double uvIndex;
  final double pressureHpa;
  final int humidity;
  final int rainChance;

  /// US AQI dari Open-Meteo Air Quality. Null bila layanan AQI tidak
  /// merespons — UI menampilkan "—" alih-alih angka karangan.
  final int? aqi;
  final int code;
  final List<WeatherHour> hours;
  final DateTime fetchedAt;

  const WeatherSnapshot({
    required this.temperatureC,
    required this.feelsLikeC,
    required this.windKph,
    required this.uvIndex,
    required this.pressureHpa,
    required this.humidity,
    required this.rainChance,
    required this.aqi,
    required this.code,
    required this.hours,
    required this.fetchedAt,
  });
}

class WeatherService {
  WeatherService._();

  /// Snapshot khusus tes/preview. Selalu null di produksi.
  @visibleForTesting
  static WeatherSnapshot? debugSnapshot;

  /// Di flutter_test, HttpOverrides memang memblokir jaringan. Lewati
  /// permintaan supaya tes tidak menunggu timeout dan tetap deterministik.
  static bool get _isFlutterTest {
    if (kIsWeb) return false;
    return Platform.environment['FLUTTER_TEST'] == 'true';
  }

  static Future<WeatherSnapshot> fetch(CityLocation city) async {
    final debug = debugSnapshot;
    if (debug != null) return debug;
    if (_isFlutterTest) {
      throw const WeatherUnavailable('Cuaca dinonaktifkan saat pengujian');
    }
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': city.latitude.toStringAsFixed(4),
      'longitude': city.longitude.toStringAsFixed(4),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'weather_code,wind_speed_10m,surface_pressure',
      'hourly':
          'temperature_2m,weather_code,precipitation_probability,uv_index',
      'forecast_days': '2',
      'timezone': 'auto',
      'wind_speed_unit': 'kmh',
    });

    // AQI diambil paralel dan tidak boleh menggagalkan kartu cuaca.
    final aqiFuture = _fetchAqi(city);

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw WeatherUnavailable('Open-Meteo ${res.statusCode}');
    }
    final body = jsonDecode(res.body);
    if (body is! Map<String, dynamic>) {
      throw const WeatherUnavailable('Format cuaca tidak dikenali');
    }
    final current = body['current'];
    final hourly = body['hourly'];
    if (current is! Map<String, dynamic> || hourly is! Map<String, dynamic>) {
      throw const WeatherUnavailable('Data cuaca tidak lengkap');
    }

    final times = (hourly['time'] as List? ?? const [])
        .map((e) => DateTime.tryParse('$e'))
        .whereType<DateTime>()
        .toList();
    final temps = (hourly['temperature_2m'] as List? ?? const []);
    final codes = (hourly['weather_code'] as List? ?? const []);
    final rains = (hourly['precipitation_probability'] as List? ?? const []);
    final uvs = (hourly['uv_index'] as List? ?? const []);

    final now = DateTime.now();
    var idx = 0;
    var best = double.infinity;
    for (var i = 0; i < times.length; i++) {
      final diff = times[i].difference(now).inMinutes.abs().toDouble();
      if (diff < best) {
        best = diff;
        idx = i;
      }
    }

    double numAt(List<dynamic> list, int i, [double fallback = 0]) {
      if (i < 0 || i >= list.length) return fallback;
      final v = list[i];
      return v is num ? v.toDouble() : fallback;
    }

    final hours = <WeatherHour>[];
    for (var i = idx + 1; i < times.length && hours.length < 6; i++) {
      if (i >= temps.length) break;
      hours.add(
        WeatherHour(
          at: times[i],
          temperatureC: numAt(temps, i),
          code: numAt(codes, i).round(),
        ),
      );
    }

    // Peluang hujan = peluang tertinggi tiga jam ke depan (lebih jujur
    // daripada satu angka per jam yang mudah berubah).
    var rain = 0;
    for (var i = idx; i < idx + 3 && i < rains.length; i++) {
      final v = numAt(rains, i).round();
      if (v > rain) rain = v;
    }

    return WeatherSnapshot(
      temperatureC: numAt([current['temperature_2m']], 0),
      feelsLikeC: numAt([current['apparent_temperature']], 0),
      windKph: numAt([current['wind_speed_10m']], 0),
      uvIndex: numAt(uvs, idx),
      pressureHpa: numAt([current['surface_pressure']], 0),
      humidity: numAt([current['relative_humidity_2m']], 0).round(),
      rainChance: rain.clamp(0, 100),
      aqi: await aqiFuture,
      code: numAt([current['weather_code']], 0).round(),
      hours: hours,
      fetchedAt: now,
    );
  }

  /// US AQI (0–500) dari Open-Meteo Air Quality. Null bila gagal.
  static Future<int?> _fetchAqi(CityLocation city) async {
    try {
      final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
        'latitude': city.latitude.toStringAsFixed(4),
        'longitude': city.longitude.toStringAsFixed(4),
        'current': 'us_aqi',
        'timezone': 'auto',
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body);
      if (body is! Map<String, dynamic>) return null;
      final current = body['current'];
      if (current is! Map<String, dynamic>) return null;
      final value = current['us_aqi'];
      if (value is! num) return null;
      return value.round().clamp(0, 500);
    } catch (_) {
      return null;
    }
  }

  /// Kategori US AQI (EPA).
  static String aqiLabel(int? aqi) => switch (aqi) {
    null => '—',
    <= 50 => 'Baik',
    <= 100 => 'Sedang',
    <= 150 => 'Tidak Sehat',
    <= 200 => 'Sangat Tidak Sehat',
    <= 300 => 'Berbahaya',
    _ => 'Ekstrem',
  };

  static String label(int code) => switch (code) {
    0 => 'Cerah',
    1 => 'Cerah Berawan',
    2 => 'Berawan',
    3 => 'Mendung',
    45 || 48 => 'Berkabut',
    51 || 53 || 55 => 'Gerimis',
    56 || 57 => 'Gerimis Beku',
    61 || 63 || 65 => 'Hujan',
    66 || 67 => 'Hujan Beku',
    71 || 73 || 75 || 77 => 'Salju',
    80 || 81 || 82 => 'Hujan Lokal',
    85 || 86 => 'Hujan Salju',
    95 => 'Badai Petir',
    96 || 99 => 'Badai Es',
    _ => 'Berawan',
  };
}

class WeatherUnavailable implements Exception {
  final String message;
  const WeatherUnavailable(this.message);

  @override
  String toString() => message;
}
