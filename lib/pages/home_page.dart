// Beranda SELF VOLTA — dashboard terang bergaya editorial.
//
// Susunan mengikuti mockup_beranda.html: header sapaan + XP, hero 2x2
// (jadwal sholat & cuaca nyata), Pilar Harian 2x2 dengan trek progres
// tersegmentasi, kebiasaan, tugas, resep hemat, lalu menu cepat.
// Data tetap nyata: jadwal sholat dari PrayerService, cuaca dari Open-Meteo,
// progres latihan/air/keuangan/study dari AppState.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../services/prayer_service.dart';
import '../services/weather_service.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'notif_settings_sheet.dart';
import 'todo_page.dart';

const Color _canvas = Star.bg;
const Color _card = Star.surface;
const Color _border = Paper.hair;
const Color _navy = Star.ink;
const Color _navyFill = Star.star;
const Color _slate = Star.mut;
const Color _amber = Star.star;
const Color _amberDark = Paper.amberInk;

/// Mode hero Beranda: dua kartu sejajar (2×2), kartu sholat melebar penuh
/// 4×2, atau kartu cuaca melebar penuh 4×2. Kartu yang tidak aktif digeser
/// keluar layar, bukan disembunyikan mendadak.
enum HeroBentoMode { split, prayer4x2, weather4x2 }

class HomePage extends StatefulWidget {
  final ValueChanged<String> onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _mealCategory = 'semua';
  HeroBentoMode _heroMode = HeroBentoMode.split;
  double _heroDragDx = 0;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    // Orbit matahari/bulan dan hitung mundur sholat ikut berjalan tanpa
    // menunggu interaksi lain.
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String _greeting(int hour) {
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _dateKicker(DateTime now) =>
      '${HARI_ID[now.weekday]}, ${now.day} ${BULAN_ID[now.month]} '
              '${now.year}'
          .toUpperCase();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        final now = DateTime.now();
        final st = AppState.I;
        final today = AppState.todayKey;
        final habits = <_Habit>[
          _Habit(
            title: 'Makan teratur',
            subtitle: 'Sarapan, siang, malam',
            icon: Icons.restaurant_outlined,
            done: st.eaten['pola_${now.year}_${now.month}_${now.day}'] ?? false,
            onTap: () =>
                _toggleHabit('pola_${now.year}_${now.month}_${now.day}'),
          ),
          _Habit(
            title: 'Booster BB',
            subtitle: 'Telur, susu, pisang, madu',
            icon: Icons.bolt_outlined,
            done:
                st.eaten['boost_${now.year}_${now.month}_${now.day}'] ?? false,
            onTap: () =>
                _toggleHabit('boost_${now.year}_${now.month}_${now.day}'),
          ),
          _Habit(
            title: 'Air 2,5–3 L',
            subtitle: 'Galon isi ulang',
            icon: Icons.water_drop_outlined,
            done:
                st.eaten['water_${now.year}_${now.month}_${now.day}'] ?? false,
            onTap: () =>
                _toggleHabit('water_${now.year}_${now.month}_${now.day}'),
          ),
        ];
        final todayTasks = st.todos.where((t) => st.dateOf(t) == today).toList()
          ..sort((a, b) {
            if (a.done != b.done) return a.done ? 1 : -1;
            if (a.timeMin < 0 && b.timeMin >= 0) return 1;
            if (b.timeMin < 0 && a.timeMin >= 0) return -1;
            if (a.timeMin != b.timeMin) {
              return a.timeMin.compareTo(b.timeMin);
            }
            return b.pri.compareTo(a.pri);
          });
        final doneTasks = todayTasks.where((t) => t.done).length;
        final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        final routineDays = st.routineDaysIn(monthKey);

        return ColoredBox(
          color: _canvas,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 36),
            children: [
              _header(now, st),
              const SizedBox(height: 14),
              ListenableBuilder(
                listenable: PrayerService.instance,
                builder: (_, _) => _heroBento(now),
              ),
              const SizedBox(height: 18),
              _sectionLabel('Pilar Harian'),
              const SizedBox(height: 10),
              _pilarGrid(now, st),
              const SizedBox(height: 16),
              _habitStrip(habits),
              const SizedBox(height: 18),
              _tasksSection(now, todayTasks, doneTasks),
              const SizedBox(height: 18),
              _mealCard(now),
              const SizedBox(height: 12),
              _routineStrip(routineDays, monthKey),
              const SizedBox(height: 16),
              _quickMenu(),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------- header
  Widget _header(DateTime now, AppState st) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _dateKicker(now),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10.5,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w700,
            color: _slate,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _greeting(now.hour),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 26,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            color: _navy,
          ),
        ),
        const SizedBox(height: 9),
        // Streak & XP selalu terlihat dan terhubung langsung ke AppState.
        // Wrap supaya dua chip turun baris di layar sempit / skala teks 2.0.
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _headerChip('🔥 ${st.streak} Hari Aktif'),
            _headerChip('⚡ Level ${st.level} · ${st.xp} XP'),
          ],
        ),
      ],
    );
  }

  Widget _headerChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: _navy,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ hero
  /// Hero bento 2×2 ↔ 4×2. Tinggi tetap 195 (ditambah ruang saat teks
  /// diperbesar) dan posisi kartu dianimasikan, jadi kartu benar-benar
  /// bergeser keluar layar seperti mockup — bukan sekadar ditukar.
  Widget _heroBento(DateTime now) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final heroHeight = 195 + (scale - 1).clamp(0.0, 1.0) * 51;
    final celestial = _celestialPosition(now);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final halfWidth = (totalWidth - 10) / 2;
        final prayerExpanded = _heroMode == HeroBentoMode.prayer4x2;
        final weatherExpanded = _heroMode == HeroBentoMode.weather4x2;
        final prayerLeft = weatherExpanded ? -totalWidth - 30.0 : 0.0;
        final weatherLeft = prayerExpanded
            ? totalWidth + 30.0
            : weatherExpanded
            ? 0.0
            : halfWidth + 10;
        final prayerWidth = prayerExpanded ? totalWidth : halfWidth;
        final weatherWidth = weatherExpanded ? totalWidth : halfWidth;

        return GestureDetector(
          key: const Key('hero-bento'),
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) => _heroDragDx = 0,
          onHorizontalDragUpdate: (d) => _heroDragDx += d.delta.dx,
          onHorizontalDragEnd: _onHeroDragEnd,
          child: SizedBox(
            height: heroHeight,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 430),
                  curve: Curves.easeOutCubic,
                  left: prayerLeft,
                  top: 0,
                  width: prayerWidth,
                  height: heroHeight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    opacity: weatherExpanded ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: weatherExpanded,
                      child: _prayerHero(
                        now,
                        heroHeight,
                        expanded: prayerExpanded,
                        celestial: celestial,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 430),
                  curve: Curves.easeOutCubic,
                  left: weatherLeft,
                  top: 0,
                  width: weatherWidth,
                  height: heroHeight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    opacity: prayerExpanded ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: prayerExpanded,
                      child: _WeatherHero(
                        height: heroHeight,
                        city: PrayerService.instance.selectedCity,
                        expanded: weatherExpanded,
                        celestial: celestial,
                        onToggleMode: _toggleWeatherMode,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _togglePrayerMode() {
    iosTapBuzz();
    _setHeroMode(
      _heroMode == HeroBentoMode.prayer4x2
          ? HeroBentoMode.split
          : HeroBentoMode.prayer4x2,
    );
  }

  void _toggleWeatherMode() {
    iosTapBuzz();
    _setHeroMode(
      _heroMode == HeroBentoMode.weather4x2
          ? HeroBentoMode.split
          : HeroBentoMode.weather4x2,
    );
  }

  void _setHeroMode(HeroBentoMode mode) {
    if (_heroMode == mode) return;
    setState(() => _heroMode = mode);
  }

  /// Swipe kiri menarik kartu cuaca (kanan) melebar; swipe kanan menarik
  /// kartu sholat (kiri) melebar. Saat sudah melebar, swipe apa pun menutup.
  void _onHeroDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final dx = _heroDragDx;
    _heroDragDx = 0;
    if (_heroMode != HeroBentoMode.split) {
      if (dx.abs() > 36 || velocity.abs() > 240) {
        _setHeroMode(HeroBentoMode.split);
      }
      return;
    }
    if (dx < -56 || velocity < -380) {
      _setHeroMode(HeroBentoMode.weather4x2);
    } else if (dx > 56 || velocity > 380) {
      _setHeroMode(HeroBentoMode.prayer4x2);
    }
  }

  /// Posisi 0..1 siklus langit + status malam. Siang 05.00–18.00 dihitung
  /// linear; malam 18.00–05.00 memakai porsi sisa hari.
  ({double t, bool night}) _celestialPosition(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    const sunrise = 5 * 60;
    const sunset = 18 * 60;
    if (minutes >= sunrise && minutes <= sunset) {
      return (
        t: (minutes - sunrise) / (sunset - sunrise),
        night: false,
      );
    }
    final nightMinutes = minutes > sunset
        ? minutes - sunset
        : minutes + 1440 - sunset;
    return (t: nightMinutes / (1440 - (sunset - sunrise)), night: true);
  }

  Widget _prayerHero(
    DateTime now,
    double height, {
    required bool expanded,
    required ({double t, bool night}) celestial,
  }) {
    final ps = PrayerService.instance;
    final sched = ps.getTodaySchedule();
    final current = ps.now;
    final city = ps.selectedCity.name.split(' (').first.split(' /').first;
    final next = _nextWajib(sched, current);
    final prev = _previousWajib(sched, next, current);
    final totalSec = next.at.difference(prev.at).inSeconds;
    final elapsedSec = current.difference(prev.at).inSeconds;
    final progress = totalSec <= 0
        ? 0.0
        : (elapsedSec / totalSec).clamp(0.0, 1.0);
    final rem = next.at.difference(current);
    final remText = rem.isNegative
        ? 'sekarang'
        : rem.inHours > 0
        ? '${rem.inHours}j ${rem.inMinutes % 60}m'
        : '${rem.inMinutes} mnt';
    final wajib = _wajibList(sched);
    final activeIndex = wajib.indexWhere((p) => p.name == next.name);

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66FFFFFF)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0284C7),
            Color(0xFF38BDF8),
            Color(0xFF7DD3FC),
            Color(0xFFBAE6FD),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: .18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _SkyPainter(t: celestial.t, night: celestial.night),
          ),
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 11),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: expanded
                    ? _prayerExpandedBody(
                        city: city,
                        sched: sched,
                        next: next,
                        progress: progress,
                        wajib: wajib,
                      )
                    : _prayerCompactBody(
                        city: city,
                        next: next,
                        remText: remText,
                        progress: progress,
                        wajib: wajib,
                        activeIndex: activeIndex,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prayerTopBar(String city, {required bool expanded}) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _showCitySelector(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 11,
                    color: Color(0xCCFFFFFF),
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _heroCircleButton(
          Icons.notifications_none_rounded,
          'Setelan alarm & notifikasi',
          () {
            iosTapBuzz();
            showNotifSettingsSheet(context);
          },
        ),
        const SizedBox(width: 4),
        _heroCircleButton(
          expanded ? Icons.close_rounded : Icons.chevron_right_rounded,
          expanded ? 'Tutup jadwal sholat' : 'Perluas jadwal sholat',
          _togglePrayerMode,
          key: const Key('hero-prayer-mode'),
        ),
      ],
    );
  }

  Widget _prayerCompactBody({
    required String city,
    required _PrayerPoint next,
    required String remText,
    required double progress,
    required List<_PrayerPoint> wajib,
    required int activeIndex,
  }) {
    return Column(
      key: const ValueKey('prayer-compact'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _prayerTopBar(city, expanded: false),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showPrayerScheduleSheet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  next.name,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  next.time,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 27,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x3D0B2A31),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Star.workoutBright,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$remText lagi',
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          children: [
            for (var i = 0; i < wajib.length; i++) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: i == activeIndex ? 7 : 5,
                height: i == activeIndex ? 7 : 5,
                decoration: BoxDecoration(
                  color: i == activeIndex
                      ? Star.workoutBright
                      : const Color(0x66FFFFFF),
                  shape: BoxShape.circle,
                  border: i == activeIndex
                      ? Border.all(
                          color: const Color(0x99FDE68A),
                          width: 1.5,
                        )
                      : null,
                ),
              ),
              if (i < wajib.length - 1) const SizedBox(width: 5),
            ],
            const Spacer(),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  'Jadwal Sholat',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: .78),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: Colors.white.withValues(alpha: .24),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _prayerExpandedBody({
    required String city,
    required PrayerSchedule sched,
    required _PrayerPoint next,
    required double progress,
    required List<_PrayerPoint> wajib,
  }) {
    return Column(
      key: const ValueKey('prayer-expanded'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _prayerTopBar(city, expanded: true),
        const SizedBox(height: 7),
        Row(
          children: [
            for (var i = 0; i < wajib.length; i++) ...[
              Expanded(
                child: _prayerGridCell(
                  wajib[i],
                  active: wajib[i].name == next.name,
                ),
              ),
              if (i < wajib.length - 1) const SizedBox(width: 3),
            ],
          ],
        ),
        const Spacer(),
        Center(child: _prayerSunnahPill(sched)),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: Colors.white.withValues(alpha: .24),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _prayerGridCell(_PrayerPoint p, {required bool active}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 5, 2, 5),
      decoration: BoxDecoration(
        color: active ? const Color(0x73000000) : const Color(0x33000000),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: active ? const Color(0xCCFBBF24) : const Color(0x1FFFFFFF),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (active) ...[
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Star.workoutBright,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
                Text(
                  p.name,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8.5,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active
                        ? const Color(0xFFFDE68A)
                        : const Color(0xCCFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              p.time,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                height: 1.0,
                fontWeight: FontWeight.w800,
                color: active ? const Color(0xFFFDE68A) : Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prayerSunnahPill(PrayerSchedule sched) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x59000000),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sunnahText('Imsak', sched.imsak, const Color(0xFFE2E8F0)),
            const Text(
              '  ·  ',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                color: Color(0x4DFFFFFF),
              ),
            ),
            _sunnahText('Terbit', sched.terbit, const Color(0xFFFDE68A)),
            const Text(
              '  ·  ',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                color: Color(0x4DFFFFFF),
              ),
            ),
            _sunnahText('Dhuha', sched.dhuha, const Color(0xFFBAE6FD)),
          ],
        ),
      ),
    );
  }

  Widget _sunnahText(String label, String time, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 8.5,
            fontWeight: FontWeight.w500,
            color: Color(0xB3FFFFFF),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _heroCircleButton(
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    Key? key,
    double size = 24,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Icon(icon, size: size * .58, color: Colors.white),
        ),
      ),
    );
  }

  // ------------------------------------------------------- pilar harian
  Widget _pilarGrid(DateTime now, AppState st) {
    return Column(
      children: [
        _pilarRow([_workoutCard(now, st), _airCard(now, st)]),
        const SizedBox(height: 10),
        _pilarRow([_financeCard(now, st), _studyCard(st)]),
      ],
    );
  }

  Widget _pilarRow(List<Widget> cards) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 10),
          Expanded(child: cards[1]),
        ],
      ),
    );
  }

  Widget _workoutCard(DateTime now, AppState st) {
    final session = switch (now.weekday) {
      DateTime.monday => SESSIONS[0],
      DateTime.wednesday => SESSIONS[1],
      DateTime.friday => SESSIONS[2],
      _ => null,
    };
    final title = switch (now.weekday) {
      DateTime.monday => 'Pull & Push',
      DateTime.wednesday => 'Wide & Legs',
      DateTime.friday => 'Full Body',
      _ => 'Pemulihan',
    };
    final subtitle = switch (now.weekday) {
      DateTime.monday => 'Pull-up · Push-up · Squat',
      DateTime.wednesday => 'Pull-up · Dip · Lunges',
      DateTime.friday => 'Pull-up · Pike · Plank',
      _ => 'Jalan · Mobilitas · Napas',
    };
    final total = session?.ex.length ?? 4;
    var done = 0;
    if (session != null) {
      for (var i = 0; i < session.ex.length; i++) {
        if (st.workoutDone['${session.id}_$i'] == true) done++;
      }
    }
    return _PilarCard(
      label: 'Workout',
      badge: session == null ? 'Rest day' : '$done / $total selesai',
      badgeBg: Star.workoutSoft,
      badgeFg: const Color(0xFF92400E),
      badgeBorder: const Color(0xFFFDE68A),
      accent: Star.workout,
      action: session == null ? 'Lihat Jadwal' : 'Catat Sesi',
      onTap: () {
        iosTapBuzz();
        widget.onNavigate('workout');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: _navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10.5,
              height: 1.35,
              color: _slate,
            ),
          ),
          const Spacer(),
          SegmentTrack(
            count: 4,
            active: done.clamp(0, 4),
            color: Star.workoutBright,
          ),
          const SizedBox(height: 4),
          Text(
            session == null ? 'Hari pemulihan' : '$done dari $total gerakan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Star.faint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _airCard(DateTime now, AppState st) {
    final waterDone =
        st.eaten['water_${now.year}_${now.month}_${now.day}'] == true;
    final targetMl = st.dailyWaterMl;
    final liters = targetMl / 1000;
    final galonDays = (19000 / targetMl).round();
    return _PilarCard(
      label: 'Air Minum',
      badge: waterDone ? 'Tercapai' : '${liters.toStringAsFixed(1)} L',
      badgeBg: Star.waterSoft,
      badgeFg: const Color(0xFF155E75),
      badgeBorder: const Color(0xFFA5F3FC),
      accent: Star.water,
      action: 'Catat Air',
      onTap: () {
        iosTapBuzz();
        widget.onNavigate('air');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  liters.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 21,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: _navy,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 2),
                const Text(
                  'L',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
                const SizedBox(width: 3),
                const Text(
                  '/ hari',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Star.faint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Target hidrasi · galon ~$galonDays hari',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10.5,
              height: 1.35,
              color: _slate,
            ),
          ),
          const Spacer(),
          SegmentTrack(
            count: 10,
            active: waterDone ? 10 : 0,
            color: Star.waterBright,
            gap: 2,
          ),
          const SizedBox(height: 4),
          Text(
            waterDone ? 'Target hari ini tuntas' : 'Belum ada catatan hari ini',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Star.faint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _financeCard(DateTime now, AppState st) {
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final monthOut = st.txns
        .where((t) => t.bln == monthKey && t.kat != 'masuk')
        .fold<int>(0, (a, t) => a + t.jml);
    final budget = st.budget;
    final sisa = budget - monthOut;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, 31);
    final jatah = sisa <= 0 ? 0 : (sisa / daysLeft).floor();
    final used = budget <= 0 ? 1.0 : (monthOut / budget).clamp(0.0, 1.0);
    final over = used >= 1.0;
    return _PilarCard(
      label: 'Keuangan',
      badge: over ? 'Lewat budget' : 'Jatah aman',
      badgeBg: over ? Paper.coralSoft : Star.financeSoft,
      badgeFg: over ? Paper.coralInk : const Color(0xFF065F46),
      badgeBorder: over ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0),
      accent: over ? Star.error : Star.finance,
      action: 'Catat Uang',
      onTap: () => _showQuickExpense(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  rp(jatah),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 21,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: _navy,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 3),
                const Text(
                  '/ hari',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Star.faint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Sisa bln ${rp(sisa)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10.5,
              height: 1.35,
              color: _slate,
            ),
          ),
          const Spacer(),
          SegmentTrack(
            count: 10,
            active: (used * 10).ceil().clamp(0, 10),
            color: over ? Star.error : Star.financeBright,
            gap: 2,
          ),
          const SizedBox(height: 4),
          Text(
            'Terpakai ${rp(monthOut)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Star.faint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _studyCard(AppState st) {
    final todayMin = _studyMinutesToday(st);
    final target = 50;
    return _PilarCard(
      label: 'Study & Fokus',
      badge: '${st.studySessionsToday} sesi',
      badgeBg: Star.studySoft,
      badgeFg: const Color(0xFF115E59),
      badgeBorder: const Color(0xFF99F6E4),
      accent: Star.study,
      action: 'Mulai Fokus',
      onTap: () {
        iosTapBuzz();
        widget.onNavigate('study');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$todayMin',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 21,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: _navy,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '/ $target mnt',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Star.faint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Target fokus harian',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10.5,
              height: 1.35,
              color: _slate,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              for (final m in const [15, 25, 50]) ...[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      iosTapBuzz();
                      widget.onNavigate('study');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: m == 25 ? Star.study : Star.fill,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: m == 25 ? Star.study : Star.line,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${m}m',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: m == 25 ? Colors.white : Star.mut,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (m != 50) const SizedBox(width: 3),
              ],
            ],
          ),
          const SizedBox(height: 6),
          SegmentTrack(
            count: 10,
            active: (todayMin / target * 10).round().clamp(0, 10),
            color: Star.study,
            gap: 2,
          ),
        ],
      ),
    );
  }

  int _studyMinutesToday(AppState st) {
    final now = DateTime.now();
    final key =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return st.studySessions
        .where((s) => s.date == key)
        .fold<int>(0, (a, s) => a + s.minutes);
  }

  // ------------------------------------------------------------- kebiasaan
  Widget _habitStrip(List<_Habit> habits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Kebiasaan'),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < habits.length; i++) ...[
                Expanded(child: _habitChip(habits[i])),
                if (i < habits.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _habitChip(_Habit h) {
    final color = switch (h.icon) {
      Icons.restaurant_outlined => Star.workout,
      Icons.bolt_outlined => Star.finance,
      _ => Star.water,
    };
    return InkWell(
      onTap: h.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 9, 9),
        decoration: Neu.raised(r: 14, d: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(h.icon, size: 15, color: color),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: h.done ? color : Colors.transparent,
                    border: Border.all(
                      color: h.done ? color : Star.overlay,
                      width: 1.4,
                    ),
                  ),
                  child: h.done
                      ? const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              h.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: h.done ? _slate : _navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              h.done ? 'Selesai' : 'Belum',
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Star.faint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- tugas
  Widget _tasksSection(DateTime now, List<SvTask> tasks, int doneTasks) {
    final nowMin = now.hour * 60 + now.minute;
    final visible = tasks.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrap, bukan Row: pada skala teks 2.0 judul + badge + tautan tidak
        // muat satu baris, jadi badge/tautan turun baris tanpa terpotong.
        Wrap(
          spacing: 8,
          runSpacing: 0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Tugas hari ini',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: _navy,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Star.studySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: Text(
                '$doneTasks / ${tasks.length} selesai',
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF115E59),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            _textLink('Lihat semua', () {
              iosTapBuzz();
              widget.onNavigate('jadwal');
            }),
          ],
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: Neu.raised(r: 16, d: 4),
            child: const Text(
              'Belum ada tugas hari ini.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                height: 1.4,
                color: _slate,
              ),
            ),
          )
        else
          for (final t in visible) _taskCard(t, nowMin),
        const SizedBox(height: 2),
        DashedSlot(
          label: 'Tambah tugas',
          onTap: () {
            iosTapBuzz();
            showTodoEditor(context);
          },
        ),
      ],
    );
  }

  Widget _taskCard(SvTask t, int nowMin) {
    final overdue = !t.done && t.timeMin >= 0 && t.timeMin < nowMin;
    final time = t.timeMin < 0 ? '' : timeLabel(t.timeMin);
    final meta = [
      if (time.isNotEmpty) time,
      if (t.cat.isNotEmpty) t.cat,
      if (t.repeat.isNotEmpty) _repeatLabel(t.repeat),
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(11, 9, 4, 9),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Star.lineSoft),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: .035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              iosTapBuzz();
              AppState.I.toggleTodo(t.id);
            },
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _checkCircle(t.done),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: InkWell(
              onTap: () {
                iosTapBuzz();
                AppState.I.toggleTodo(t.id);
              },
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                      color: t.done ? Star.faint : _navy,
                      decoration: t.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Star.faint,
                    ),
                  ),
                  if (meta.isNotEmpty || overdue) ...[
                    const SizedBox(height: 2),
                    Text(
                      overdue ? 'Terlewat · $meta' : meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10.5,
                        height: 1.3,
                        fontWeight: overdue ? FontWeight.w700 : FontWeight.w500,
                        color: overdue ? Paper.coralInk : _slate,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              iosTapBuzz();
              showTodoEditor(context, existing: t);
            },
            tooltip: 'Edit tugas',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: Star.faint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkCircle(bool done) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? _navyFill : Colors.transparent,
        border: Border.all(color: done ? _navyFill : Star.overlay, width: 1.5),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }

  // --------------------------------------------------------------- resep
  Widget _mealCard(DateTime now) {
    final key = switch (_mealCategory) {
      'protein' => 'D',
      'hemat' => 'A',
      'sayur' => 'F',
      'booster' => 'G',
      _ => URUTAN[(now.day - 1) % URUTAN.length],
    };
    final pola = POLA[key];
    final macro = MACRO_PAKET[key];
    final title = _menuTitle(pola?.t ?? 'Menu harian');
    final snippet = _menuSnippet(pola?.cara ?? '');
    final kcal = macro?.k ?? TARGET_KKAL;
    final protein = macro?.p ?? TARGET_P;
    final budget = pola?.b ?? 20000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          'Resep Makanan Hemat',
          trailing: _textLink('Lihat semua', () {
            iosTapBuzz();
            widget.onNavigate('planning');
          }),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: Neu.raised(r: 16, d: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (final c in const {
                      'semua': 'Hari ini',
                      'protein': 'Protein',
                      'hemat': 'Telur & tempe',
                      'sayur': 'Sayur',
                      'booster': 'Booster',
                    }.entries)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _mealPill(c.key, c.value),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Star.workoutSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'PAKET',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            Text(
                              key,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 23,
                                height: 1.0,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PAKET $key · MENU HARIAN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 9.5,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700,
                            color: Star.faint,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            height: 1.22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: _navy,
                          ),
                        ),
                        if (snippet.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            snippet,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10.5,
                              height: 1.4,
                              color: _slate,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 6,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _mealTag(
                    '$kcal kkal',
                    bg: const Color(0xFFF1F5F9),
                    fg: _navy,
                  ),
                  _mealTag(
                    '$protein g protein',
                    bg: Star.workoutSoft,
                    fg: const Color(0xFF92400E),
                  ),
                  Text(
                    rp(budget),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const Divider(height: 18, color: Star.lineSoft),
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: rp(budget),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _navy,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const TextSpan(
                            text: ' /hari',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: _slate,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      iosTapBuzz();
                      widget.onNavigate('planning');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat resep',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: _navy,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mealTag(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: fg,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _mealPill(String key, String label) {
    final selected = _mealCategory == key;
    return InkWell(
      onTap: () {
        iosTapBuzz();
        setState(() => _mealCategory = key);
      },
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? _navyFill : _canvas,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _navyFill : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Star.onAccent : _slate,
          ),
        ),
      ),
    );
  }

  /// Judul paket disimpan dengan prefiks "F | ..." dan tag "(otot)".
  /// Kartu Beranda hanya butuh nama menunya.
  String _menuTitle(String raw) {
    var text = raw;
    final bar = text.indexOf('|');
    if (bar >= 0) text = text.substring(bar + 1);
    text = text.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '');
    return text.trim();
  }

  /// Cuplikan 2 baris: langkah masak pertama tanpa penanda [MC]/[PL].
  String _menuSnippet(String cara) {
    final clean = cara.replaceAll('[MC]', '').replaceAll('[PL]', '').trim();
    if (clean.isEmpty) return '';
    final dot = clean.indexOf('. ');
    return (dot > 0 ? clean.substring(0, dot) : clean).trim();
  }

  // -------------------------------------------------------------- rutinitas
  Widget _routineStrip(int days, String monthKey) {
    return InkWell(
      onTap: () => _showRoutineSheet(context, monthKey),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: Neu.raised(r: 16, d: 4),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Star.surface2,
                shape: BoxShape.circle,
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 17,
                color: _navy,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rutinitas bulan ini',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    days == 0
                        ? 'Belum ada hari yang tercatat.'
                        : '$days hari tuntas · lihat tracker',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: _slate,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 19, color: _slate),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------- menu cepat
  Widget _quickMenu() {
    final shortcuts = <({String title, IconData icon, String page})>[
      (title: 'Cari Menu', icon: Icons.restaurant_outlined, page: 'planning'),
      (title: 'Latihan', icon: Icons.fitness_center_outlined, page: 'workout'),
      (
        title: 'Uang',
        icon: Icons.account_balance_wallet_outlined,
        page: 'keuangan',
      ),
      (title: 'To-Do', icon: Icons.checklist_outlined, page: 'todo'),
      (title: 'Air', icon: Icons.water_drop_outlined, page: 'air'),
      (title: 'Booster', icon: Icons.bolt_outlined, page: 'booster'),
      (title: 'Piano', icon: Icons.piano_outlined, page: 'ingin'),
      (title: 'Panduan', icon: Icons.menu_book_outlined, page: 'panduan'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Menu Cepat'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (final s in shortcuts)
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: InkWell(
                    onTap: () {
                      iosTapBuzz();
                      widget.onNavigate(s.page);
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s.icon, size: 14, color: _navy),
                          const SizedBox(width: 5),
                          Text(
                            s.title,
                            maxLines: 1,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: _navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- helpers
  Widget _sectionLabel(String text, {Widget? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10.5,
              letterSpacing: 0.9,
              fontWeight: FontWeight.w800,
              color: _slate,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _textLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: _slate,
                ),
              ),
              const SizedBox(width: 1),
              const Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color: Star.faint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleHabit(String key) {
    iosTapBuzz();
    final next = !(AppState.I.eaten[key] ?? false);
    AppState.I.eaten[key] = next;
    unawaited(AppState.I.save());
    if (next) {
      AppState.I.addXp(25);
    } else {
      AppState.I.removeXp(25);
    }
  }

  String _repeatLabel(String r) => switch (r) {
    'harian' => 'Harian',
    'mingguan' => 'Mingguan',
    'bulanan' => 'Bulanan',
    _ => '',
  };

  // ----------------------------------------------------------- sheet cepat
  void _showQuickExpense(BuildContext context) {
    iosTapBuzz();
    final amount = TextEditingController();
    final note = TextEditingController();
    var cat = 'protein';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final inset = MediaQuery.viewInsetsOf(ctx).bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + inset),
              decoration: const BoxDecoration(
                color: Star.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Catat pengeluaran',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                    decoration: _expenseField('Nominal', prefix: 'Rp '),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: note,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: _navy,
                    ),
                    decoration: _expenseField('Keterangan (opsional)'),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final c in const {
                        'protein': 'Protein',
                        'bumbu': 'Sayur & bumbu',
                        'galon': 'Galon',
                        'lain': 'Lain-lain',
                      }.entries)
                        ChoiceChip(
                          label: Text(c.value),
                          selected: cat == c.key,
                          onSelected: (_) => setSheet(() => cat = c.key),
                          selectedColor: _navyFill,
                          backgroundColor: _canvas,
                          side: const BorderSide(color: _border),
                          labelStyle: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cat == c.key ? Star.onAccent : _slate,
                          ),
                          showCheckmark: false,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: () async {
                        final raw = amount.text.replaceAll('.', '').trim();
                        final value = int.tryParse(raw) ?? 0;
                        if (value <= 0) return;
                        final n = DateTime.now();
                        final desc = note.text.trim().isEmpty
                            ? 'Pengeluaran harian'
                            : note.text.trim();
                        await AppState.I.addTxn(
                          desc,
                          value,
                          hari: n.day,
                          kat: cat,
                        );
                        AppState.I.addXp(15);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                content: Text('Tercatat ${rp(value)} · $desc'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: _navyFill,
                              ),
                            );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _navyFill,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _expenseField(String hint, {String? prefix}) =>
      InputDecoration(
        hintText: hint,
        prefixText: prefix,
        prefixStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          color: _navy,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Manrope',
          color: _slate,
          fontSize: 13,
        ),
        filled: true,
        fillColor: _canvas,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _navyFill, width: 1.5),
        ),
      );

  void _showPrayerScheduleSheet() {
    iosTapBuzz();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          decoration: const BoxDecoration(
            color: Star.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: ListenableBuilder(
              listenable: PrayerService.instance,
              builder: (_, _) {
                final ps = PrayerService.instance;
                final sched = ps.getTodaySchedule();
                final city = ps.selectedCity.name
                    .split(' (')
                    .first
                    .split(' /')
                    .first;
                final next = _nextWajib(sched, ps.now);
                final rows = [
                  ('Imsak', sched.imsak),
                  ('Subuh', sched.subuh),
                  ('Terbit', sched.terbit),
                  ('Dhuha', sched.dhuha),
                  ('Dzuhur', sched.dzuhur),
                  ('Ashar', sched.ashar),
                  ('Maghrib', sched.maghrib),
                  ('Isya', sched.isya),
                ];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Jadwal sholat hari ini',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$city · dihitung astronomis (Kemenag RI)',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.5,
                        color: _slate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Star.waterSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA5F3FC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mosque_rounded,
                            size: 20,
                            color: Star.water,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Berikutnya: ${next.name} ${next.time}',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF155E75),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < rows.length; i += 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: _prayerSheetCell(
                                rows[i].$1,
                                rows[i].$2,
                                active: rows[i].$1 == next.name,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: i + 1 < rows.length
                                  ? _prayerSheetCell(
                                      rows[i + 1].$1,
                                      rows[i + 1].$2,
                                      active: rows[i + 1].$1 == next.name,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          iosTapBuzz();
                          Navigator.pop(ctx);
                          showNotifSettingsSheet(context);
                        },
                        icon: const Icon(
                          Icons.notifications_active_outlined,
                          size: 18,
                        ),
                        label: const Text('Atur alarm & notifikasi'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _prayerSheetCell(String label, String time, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Star.workoutSoft : Star.fill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? const Color(0xFFFDE68A) : Star.lineSoft,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? const Color(0xFF92400E) : _slate,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: active ? const Color(0xFF92400E) : _navy,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- sheets
  void _showCitySelector(BuildContext context) {
    iosTapBuzz();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.76,
          ),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
          decoration: const BoxDecoration(
            color: Star.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pilih kota sholat',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Jadwal dihitung astronomis, standar Kemenag RI.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  color: _slate,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: kIndonesianCities.length,
                  itemBuilder: (_, i) {
                    final city = kIndonesianCities[i];
                    final selected =
                        city.name == PrayerService.instance.selectedCity.name;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.location_on_outlined,
                        size: 19,
                        color: selected ? _navy : _slate,
                      ),
                      title: Text(
                        city.name,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _navy,
                        ),
                      ),
                      onTap: () {
                        iosTapBuzz();
                        PrayerService.instance.setCity(city);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRoutineSheet(BuildContext context, String monthKey) {
    iosTapBuzz();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RoutineSheet(initialMonth: monthKey),
    );
  }
}

// ---------------------------------------------------------------- data kecil
class _Habit {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool done;
  final VoidCallback onTap;

  const _Habit({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.done,
    required this.onTap,
  });
}

class _PrayerPoint {
  final String name;
  final String time;
  final DateTime at;

  const _PrayerPoint({
    required this.name,
    required this.time,
    required this.at,
  });
}

List<_PrayerPoint> _wajibList(PrayerSchedule s) => [
  _PrayerPoint(name: 'Subuh', time: s.subuh, at: s.subuhTime),
  _PrayerPoint(name: 'Dzuhur', time: s.dzuhur, at: s.dzuhurTime),
  _PrayerPoint(name: 'Ashar', time: s.ashar, at: s.asharTime),
  _PrayerPoint(name: 'Maghrib', time: s.maghrib, at: s.maghribTime),
  _PrayerPoint(name: 'Isya', time: s.isya, at: s.isyaTime),
];

_PrayerPoint _nextWajib(PrayerSchedule s, DateTime now) {
  for (final p in _wajibList(s)) {
    if (p.at.isAfter(now)) return p;
  }
  final tomorrow = PrayerService.instance.getTodaySchedule(
    now.add(const Duration(days: 1)),
  );
  return _PrayerPoint(
    name: 'Subuh',
    time: tomorrow.subuh,
    at: tomorrow.subuhTime,
  );
}

_PrayerPoint _previousWajib(PrayerSchedule s, _PrayerPoint next, DateTime now) {
  if (next.name == 'Subuh' && next.at.day != now.day) {
    return _PrayerPoint(name: 'Isya', time: s.isya, at: s.isyaTime);
  }
  final list = _wajibList(s);
  final i = list.indexWhere((p) => p.name == next.name);
  if (i <= 0) {
    final yesterday = PrayerService.instance.getTodaySchedule(
      now.subtract(const Duration(days: 1)),
    );
    return _PrayerPoint(
      name: 'Isya',
      time: yesterday.isya,
      at: yesterday.isyaTime,
    );
  }
  return list[i - 1];
}

// ------------------------------------------------------------- routine sheet
class _RoutineSheet extends StatefulWidget {
  final String initialMonth; // yyyy-MM

  const _RoutineSheet({required this.initialMonth});

  @override
  State<_RoutineSheet> createState() => _RoutineSheetState();
}

class _RoutineSheetState extends State<_RoutineSheet> {
  late int _year;
  late int _month;
  int? _selectedDay;

  static const _bulan = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static const _hari = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  void initState() {
    super.initState();
    final parts = widget.initialMonth.split('-');
    _year = int.tryParse(parts[0]) ?? DateTime.now().year;
    _month =
        int.tryParse(parts.length > 1 ? parts[1] : '') ?? DateTime.now().month;
  }

  void _go(int delta) {
    setState(() {
      _month += delta;
      if (_month < 1) {
        _month = 12;
        _year--;
      } else if (_month > 12) {
        _month = 1;
        _year++;
      }
      _selectedDay = null;
    });
  }

  String get _key => '$_year-${_month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final marks = AppState.I.routineMarksIn(_key);
    final days = <int, List<RoutineMark>>{};
    for (final m in marks) {
      final d = int.tryParse(m.date.substring(8, 10)) ?? 0;
      if (d > 0) (days[d] ??= []).add(m);
    }
    final totalDays = DateTime(_year, _month + 1, 0).day;
    final firstWeekday = DateTime(_year, _month, 1).weekday; // 1=Senin
    final selectedMarks = _selectedDay == null
        ? const <RoutineMark>[]
        : (days[_selectedDay!] ?? const <RoutineMark>[]);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: const BoxDecoration(
        color: Star.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Rutinitas bulanan',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${marks.length} catatan · ${days.length} hari tuntas',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  color: _slate,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _go(-1),
                    icon: const Icon(Icons.chevron_left_rounded, color: _navy),
                  ),
                  Expanded(
                    child: Text(
                      '${_bulan[_month]} $_year',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _go(1),
                    icon: const Icon(Icons.chevron_right_rounded, color: _navy),
                  ),
                ],
              ),
              Row(
                children: [
                  for (final h in _hari.skip(1))
                    Expanded(
                      child: Text(
                        h,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: _slate,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (firstWeekday - 1) + totalDays,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent:
                      38 + (MediaQuery.textScalerOf(context).scale(1) - 1) * 12,
                ),
                itemBuilder: (_, i) {
                  final day = i - (firstWeekday - 1) + 1;
                  if (day < 1 || day > totalDays) {
                    return const SizedBox.shrink();
                  }
                  final done = days.containsKey(day);
                  final selected = _selectedDay == day;
                  return InkWell(
                    onTap: done
                        ? () => setState(
                            () => _selectedDay = selected ? null : day,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? _navyFill
                            : done
                            ? _amber.withValues(alpha: 0.16)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: selected
                            ? null
                            : done
                            ? Border.all(color: _amber)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: done
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? Star.onAccent
                                  : done
                                  ? _navy
                                  : _slate,
                            ),
                          ),
                          if (done)
                            Container(
                              width: 3,
                              height: 3,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: BoxDecoration(
                                color: selected ? Star.surface : _amberDark,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              if (_selectedDay != null && selectedMarks.isNotEmpty) ...[
                Text(
                  '$_selectedDay ${_bulan[_month]} $_year',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _slate,
                  ),
                ),
                const SizedBox(height: 4),
                for (final m in selectedMarks)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: _amberDark,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            m.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12.5,
                              color: _navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],
              if (marks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: Neu.raised(r: 12, d: 3),
                  child: const Text(
                    'Tandai tugas sebagai rutinitas atau selesaikan alarm untuk mulai mencatat bulan ini.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      height: 1.4,
                      color: _slate,
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              const Text(
                'Rutinitas bulanan: aktifkan di editor tugas. Alarm layar penuh otomatis mencatatnya saat tugas selesai.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  height: 1.5,
                  color: _slate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu dasar Pilar Harian: label, badge semantik, isi, dan aksi bawah.
class _PilarCard extends StatelessWidget {
  final String label;
  final String badge;
  final Color badgeBg;
  final Color badgeFg;
  final Color badgeBorder;
  final Color accent;
  final String action;
  final VoidCallback onTap;
  final Widget child;

  const _PilarCard({
    required this.label,
    required this.badge,
    required this.badgeBg,
    required this.badgeFg,
    required this.badgeBorder,
    required this.accent,
    required this.action,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
      decoration: Neu.raised(r: 16, d: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 5,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                label.toUpperCase(),
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 9.5,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w800,
                  color: Star.mut,
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 66),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: badgeBorder),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    badge,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: badgeFg,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Expanded(child: child),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(9),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
              decoration: BoxDecoration(
                color: Star.fill,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Star.line),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        action,
                        maxLines: 1,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Star.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: accent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu cuaca hero. Memuat data nyata dari Open-Meteo sesuai kota sholat.
class _WeatherHero extends StatefulWidget {
  final double height;
  final CityLocation city;
  final bool expanded;
  final ({double t, bool night}) celestial;
  final VoidCallback onToggleMode;

  const _WeatherHero({
    required this.height,
    required this.city,
    required this.expanded,
    required this.celestial,
    required this.onToggleMode,
  });

  @override
  State<_WeatherHero> createState() => _WeatherHeroState();
}

class _WeatherHeroState extends State<_WeatherHero> {
  WeatherSnapshot? _data;
  bool _loading = true;
  String? _error;
  String _cityKey = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _WeatherHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city.name != widget.city.name) _load();
  }

  Future<void> _load() async {
    final key = widget.city.name;
    setState(() {
      _cityKey = key;
      _loading = true;
      _error = null;
    });
    try {
      final data = await WeatherService.fetch(widget.city);
      if (!mounted || _cityKey != key) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || _cityKey != key) return;
      setState(() {
        _loading = false;
        _error = 'Cuaca tidak tersedia';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = widget.city.name.split(' (').first.split(' /').first;
    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66FFFFFF)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF075985),
            Color(0xFF0284C7),
            Color(0xFF38BDF8),
            Color(0xFF7DD3FC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: .16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _SkyPainter(
              t: widget.celestial.t,
              night: widget.celestial.night,
            ),
          ),
          const ColoredBox(color: Color(0x44123A46)),
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _weatherTopBar(city),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: widget.expanded
                          ? _weatherExpandedBody()
                          : _weatherCompactBody(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherTopBar(String city) {
    return Row(
      children: [
        const Icon(
          Icons.wb_sunny_outlined,
          size: 12,
          color: Color(0xFFFFE08A),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.expanded ? 'CUACA · ${city.toUpperCase()}' : 'CUACA',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 8,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: Color(0xCCFFFFFF),
            ),
          ),
        ),
        if (!_loading)
          Tooltip(
            message: 'Muat ulang cuaca',
            child: InkWell(
              onTap: _load,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 13,
                  color: Colors.white.withValues(alpha: .78),
                ),
              ),
            ),
          ),
        const SizedBox(width: 3),
        Tooltip(
          message: widget.expanded ? 'Tutup cuaca' : 'Perluas cuaca',
          child: InkWell(
            key: const Key('hero-weather-mode'),
            onTap: widget.onToggleMode,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Icon(
                widget.expanded
                    ? Icons.close_rounded
                    : Icons.chevron_left_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weatherCompactBody() {
    return Column(
      key: const ValueKey('weather-compact'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        if (_loading)
          _weatherLoading()
        else if (_error != null)
          _weatherError()
        else
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${_data!.temperatureC.round()}°C',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 26,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  WeatherService.label(_data!.code),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: .82),
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        if (_data != null) ...[
          Row(
            children: [
              Expanded(
                child: _weatherMetric('Lembap', '${_data!.humidity}%'),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _weatherMetric('Hujan', '${_data!.rainChance}%'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _weatherMetric(
                  'Angin',
                  '${_data!.windKph.round()} km/j',
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _weatherMetric('UV', '${_data!.uvIndex.round()}'),
              ),
            ],
          ),
          if (_data!.hours.isNotEmpty) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                for (final h in _data!.hours.take(2)) ...[
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${h.at.hour.toString().padLeft(2, '0')}.'
                        '00  ${h.temperatureC.round()}°',
                        maxLines: 1,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xCCFFFFFF),
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                  if (h != _data!.hours.take(2).last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _weatherExpandedBody() {
    return Column(
      key: const ValueKey('weather-expanded'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        if (_loading)
          _weatherLoading()
        else if (_error != null)
          _weatherError()
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${_data!.temperatureC.round()}°',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 24,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: Colors.white,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        WeatherService.label(_data!.code),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: .84),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x1FFFFFFF)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Terasa ${_data!.feelsLikeC.round()}°C',
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Color(0xE6FFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _weatherMetric(
                  'Lembap',
                  '${_data!.humidity}%',
                  dense: true,
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: _weatherMetric(
                  'Hujan',
                  '${_data!.rainChance}%',
                  dense: true,
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: _weatherMetric(
                  'Angin',
                  '${_data!.windKph.round()} km/j',
                  dense: true,
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: _weatherMetric(
                  'UV',
                  '${_data!.uvIndex.round()}',
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          if (_data!.hours.isNotEmpty)
            Row(
              children: [
                for (var i = 0; i < _data!.hours.take(6).length; i++) ...[
                  Expanded(
                    child: _weatherHourCell(
                      _data!.hours[i],
                      highlighted: i == 0,
                    ),
                  ),
                  if (i < _data!.hours.take(6).length - 1)
                    const SizedBox(width: 2),
                ],
              ],
            ),
          const Spacer(),
          Center(child: _weatherExtraPill()),
        ],
      ],
    );
  }

  Widget _weatherLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memuat cuaca…',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: .9),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Mengikuti kota sholat',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 8.5,
            color: Colors.white.withValues(alpha: .65),
          ),
        ),
      ],
    );
  }

  Widget _weatherError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _error!,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Ketuk ikon segarkan untuk coba lagi',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 8.5,
            color: Colors.white.withValues(alpha: .7),
          ),
        ),
      ],
    );
  }

  Widget _weatherHourCell(WeatherHour h, {required bool highlighted}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0x6622D3EE) : const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: highlighted
            ? Border.all(color: const Color(0x6638BDF8))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${h.at.hour.toString().padLeft(2, '0')}.00',
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                color: Color(0xB3FFFFFF),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Icon(_weatherIcon(h.code), size: 12, color: _weatherIconColor(h.code)),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${h.temperatureC.round()}°',
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 9.5,
                height: 1.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFDE68A),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherExtraPill() {
    final data = _data!;
    final aqi = data.aqi;
    final pressure = data.pressureHpa > 0
        ? '${data.pressureHpa.round()} hPa'
        : '—';
    final aqiText = aqi == null
        ? '—'
        : '$aqi ${WeatherService.aqiLabel(aqi)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x59000000),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tekanan ',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
                color: Color(0xB3FFFFFF),
              ),
            ),
            Text(
              pressure,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const Text(
              '  ·  ',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                color: Color(0x4DFFFFFF),
              ),
            ),
            const Text(
              'AQI ',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
                color: Color(0xB3FFFFFF),
              ),
            ),
            Text(
              aqiText,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: _aqiColor(aqi),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _aqiColor(int? aqi) {
    if (aqi == null) return const Color(0xB3FFFFFF);
    if (aqi <= 50) return const Color(0xFF6EE7B7);
    if (aqi <= 100) return const Color(0xFFFDE68A);
    if (aqi <= 150) return const Color(0xFFFDBA74);
    return const Color(0xFFFCA5A5);
  }

  IconData _weatherIcon(int code) => switch (code) {
    0 || 1 => Icons.wb_sunny_rounded,
    2 => Icons.wb_cloudy_rounded,
    3 => Icons.cloud_rounded,
    45 || 48 => Icons.foggy,
    51 || 53 || 55 || 56 || 57 => Icons.grain_rounded,
    61 || 63 || 65 || 66 || 67 => Icons.water_drop_rounded,
    71 || 73 || 75 || 77 || 85 || 86 => Icons.ac_unit_rounded,
    80 || 81 || 82 => Icons.umbrella_rounded,
    95 || 96 || 99 => Icons.thunderstorm_rounded,
    _ => Icons.cloud_rounded,
  };

  Color _weatherIconColor(int code) => switch (code) {
    0 || 1 => const Color(0xFFFFE08A),
    51 || 53 || 55 || 56 || 57 || 61 || 63 || 65 ||
    80 || 81 || 82 =>
      const Color(0xFFA5F3FC),
    71 || 73 || 75 || 77 || 85 || 86 => const Color(0xFFE0F2FE),
    95 || 96 || 99 => const Color(0xFFFDE68A),
    _ => const Color(0xE6FFFFFF),
  };

  Widget _weatherMetric(String label, String value, {bool dense = false}) {
    if (dense) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x33000000),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x1FFFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: .65),
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 7,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: .65),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Latar hero: busur orbit putus-putus, matahari/bulan sesuai jam, bintang
/// saat malam, lalu dua lapis bukit. Digambar, bukan emoji.
class _SkyPainter extends CustomPainter {
  final double t;
  final bool night;

  const _SkyPainter({this.t = .5, this.night = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final startX = w * .08;
    final endX = w * .92;
    final baseY = h * .60;
    final arcHeight = h * .40;

    if (night) {
      for (final (fx, fy, r) in const [
        (.16, .18, 1.1),
        (.34, .11, .8),
        (.58, .20, 1.0),
        (.78, .12, .8),
        (.90, .26, 1.0),
        (.47, .30, .7),
        (.24, .32, .7),
      ]) {
        canvas.drawCircle(
          Offset(w * fx, h * fy),
          r,
          Paint()..color = Colors.white.withValues(alpha: .55),
        );
      }
    }

    // Busur orbit mengikuti y = baseY - sin(t·π)·arcHeight, jadi orb selalu
    // duduk tepat di atas garis putus-putus.
    final arc = Path()..moveTo(startX, baseY);
    const steps = 56;
    for (var i = 1; i <= steps; i++) {
      final u = i / steps;
      arc.lineTo(
        startX + (endX - startX) * u,
        baseY - math.sin(u * math.pi) * arcHeight,
      );
    }
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .30);
    for (final metric in arc.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + 3.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), dashPaint);
        distance = end + 3.0;
      }
    }

    final u = t.clamp(0.0, 1.0);
    final orb = Offset(
      startX + (endX - startX) * u,
      baseY - math.sin(u * math.pi) * arcHeight,
    );
    if (night) {
      canvas.drawCircle(
        orb,
        13,
        Paint()..color = const Color(0x1FFFFFFF),
      );
      canvas.drawCircle(
        orb,
        8,
        Paint()..color = const Color(0x33E2E8F0),
      );
      canvas.drawCircle(orb, 4.6, Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawCircle(
        orb.translate(1.3, -1.1),
        1.1,
        Paint()..color = const Color(0x5594A3B8),
      );
    } else {
      canvas.drawCircle(
        orb,
        18,
        Paint()..color = const Color(0x22FFE08A),
      );
      canvas.drawCircle(
        orb,
        12,
        Paint()..color = const Color(0x44FBBF24),
      );
      canvas.drawCircle(
        orb,
        7,
        Paint()..color = const Color(0x66F59E0B),
      );
      canvas.drawCircle(orb, 4.8, Paint()..color = const Color(0xFFFFF3C4));
    }

    final back = Path()
      ..moveTo(0, h * 0.74)
      ..quadraticBezierTo(w * .32, h * .58, w * .62, h * .71)
      ..quadraticBezierTo(w * .84, h * .79, w, h * .68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0x33115E6E));

    final front = Path()
      ..moveTo(0, h * 0.84)
      ..quadraticBezierTo(w * .36, h * .72, w * .68, h * .83)
      ..quadraticBezierTo(w * .88, h * .90, w, h * .80)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0x5521505B));
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.night != night;
}
