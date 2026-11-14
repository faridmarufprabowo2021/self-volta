// Beranda "Kertas & Tinta" SELF VOLTA.
//
// Satu kartu jangkar navy untuk sholat, satu kartu putih untuk Hari Ini
// (kebiasaan + To-Do), lalu aksi cepat dan menu makanan bergaya monokrom.
// Data selalu nyata: jadwal sholat dihitung PrayerService, cuaca tidak
// dikarang, dan streak palsu tidak ditampilkan.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../services/prayer_service.dart';
import '../store.dart';
import '../widgets.dart';
import 'notif_settings_sheet.dart';
import 'todo_page.dart';
import '../theme.dart';

const Color _canvas = Star.bg;
const Color _card = Star.surface;
const Color _border = Paper.hair;
const Color _navy = Star.ink;
const Color _navyFill = Star.star;
const Color _slate = Star.mut;
const Color _amber = Star.star;
const Color _amberDark = Paper.amberInk;

class HomePage extends StatefulWidget {
  final ValueChanged<String> onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showPrayerDetails = false;
  String _mealCategory = 'semua';

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
        final doneHabits = habits.where((h) => h.done).length;
        final doneTasks = todayTasks.where((t) => t.done).length;
        final total = habits.length + todayTasks.length;
        final done = doneHabits + doneTasks;
        final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        final routineDays = st.routineDaysIn(monthKey);

        return ColoredBox(
          color: _canvas,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 36),
            children: [
              _header(now, st),
              const SizedBox(height: 16),
              _prayerCard(now),
              const SizedBox(height: 16),
              _todayCard(
                now: now,
                habits: habits,
                tasks: todayTasks,
                done: done,
                total: total,
              ),
              const SizedBox(height: 16),
              _quickActions(now),
              const SizedBox(height: 16),
              _mealCard(now),
              const SizedBox(height: 16),
              _routineStrip(routineDays, monthKey),
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
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: _slate,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                _greeting(now.hour),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                  color: _navy,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 128),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: Neu.raised(r: 999, d: 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Lv ${st.level} · ${st.xp} XP',
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _slate,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --------------------------------------------------------------- prayer
  Widget _prayerCard(DateTime now) {
    return ListenableBuilder(
      listenable: PrayerService.instance,
      builder: (context, _) {
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
            ? '${rem.inHours} j ${rem.inMinutes % 60} m lagi'
            : '${rem.inMinutes} mnt lagi';

        return Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          decoration: Neu.raised(r: 26, d: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'BERIKUTNYA',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Star.mut,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      iosTapBuzz();
                      showNotifSettingsSheet(context);
                    },
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    tooltip: 'Setelan alarm & notifikasi',
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                      size: 18,
                      color: Star.mut,
                    ),
                  ),
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: () => _showCitySelector(context),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Star.mut,
                          ),
                          const SizedBox(width: 3),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 88),
                            child: Text(
                              city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Star.mut,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 15,
                            color: Star.mut,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, box) {
                  return Row(
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
                                next.name,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 24,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: Star.ink,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                next.time,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 24,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  color: Star.ink,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Star.sunken,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            remText,
                            maxLines: 1,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Star.ink,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 13),
              GradBar(progress * 100, height: 7),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final p in _wajibList(sched))
                    Expanded(
                      child: _prayerSlot(
                        name: p.name,
                        time: p.time,
                        active: p.name == next.name,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  iosTapBuzz();
                  setState(() => _showPrayerDetails = !_showPrayerDetails);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _showPrayerDetails
                              ? 'Sembunyikan detail'
                              : 'Imsak ${sched.imsak}  ·  Terbit ${sched.terbit}  ·  Dhuha ${sched.dhuha}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Star.mut,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      Icon(
                        _showPrayerDetails
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Star.mut,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showPrayerDetails) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Star.sunken,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _extraPrayer('Imsak', sched.imsak),
                      _extraPrayer('Terbit', sched.terbit),
                      _extraPrayer('Dhuha', sched.dhuha),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _prayerSlot({
    required String name,
    required String time,
    required bool active,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      decoration: active
          ? Neu.well(r: 12)
          : BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Star.star : Star.mut,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: active ? Star.star : Star.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _extraPrayer(String label, String time) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              color: Star.mut,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Star.ink,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- hari ini
  Widget _todayCard({
    required DateTime now,
    required List<_Habit> habits,
    required List<SvTask> tasks,
    required int done,
    required int total,
  }) {
    final ratio = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    final nowMin = now.hour * 60 + now.minute;
    final doneTasks = tasks.where((t) => t.done).length;
    final visibleTasks = tasks.take(4).toList();

    return Container(
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 0),
            child: Row(
              children: [
                const Text(
                  'HARI INI',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: _slate,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$done/$total',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _slate,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                _textLink('Lihat semua', () {
                  iosTapBuzz();
                  widget.onNavigate('todo');
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4,
                backgroundColor: _border,
                valueColor: const AlwaysStoppedAnimation<Color>(_amber),
              ),
            ),
          ),
          const SizedBox(height: 4),
          for (final h in habits)
            _todayRow(
              title: h.title,
              subtitle: h.subtitle,
              icon: h.icon,
              done: h.done,
              onTap: h.onTap,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
            child: Row(
              children: [
                const Text(
                  'TUGAS',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w600,
                    color: _slate,
                  ),
                ),
                if (tasks.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$doneTasks/${tasks.length}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Star.faint,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(
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
            for (final t in visibleTasks) _taskRow(t, nowMin),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: DashedSlot(
              label: 'Tambah tugas',
              onTap: () {
                iosTapBuzz();
                showTodoEditor(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool done,
    required VoidCallback onTap,
  }) {
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              children: [
                _habitMark(icon, done),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13.5,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: done ? _slate : _navy,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11.5,
                          height: 1.3,
                          color: _slate,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusPill(done),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _habitMark(IconData icon, bool done) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: done ? _amber : _canvas,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: done ? _amber : _border),
      ),
      child: Icon(
        done ? Icons.check_rounded : icon,
        size: 16,
        color: done ? _navy : _slate,
      ),
    );
  }

  Widget _statusPill(bool done) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: done ? Paper.mintSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: done ? Paper.mint.withValues(alpha: 0.35) : Star.overlay,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!done) ...[
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Star.faint,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            done ? 'Selesai' : 'Belum',
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: done ? Paper.mintDeep : _slate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(width: 1),
              const Icon(Icons.chevron_right_rounded, size: 16, color: _navy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskRow(SvTask t, int nowMin) {
    final overdue = !t.done && t.timeMin >= 0 && t.timeMin < nowMin;
    final time = t.timeMin < 0 ? '' : timeLabel(t.timeMin);
    final sub = [
      t.cat,
      if (t.repeat.isNotEmpty) _repeatLabel(t.repeat),
      if (t.note.isNotEmpty) t.note,
    ].join(' · ');
    final hasMeta = overdue || sub.isNotEmpty;

    return InkWell(
      onTap: () {
        iosTapBuzz();
        AppState.I.toggleTodo(t.id);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: time.isEmpty
                    ? const Text(
                        '—',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: Star.faint,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          time,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: overdue
                                ? Paper.coralInk
                                : (t.done ? _slate : _amberDark),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              _checkCircle(t.done),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13.5,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: t.done ? _slate : _navy,
                        decoration: t.done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: _slate,
                      ),
                    ),
                    if (hasMeta)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              if (overdue)
                                const TextSpan(
                                  text: 'Terlewat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Paper.coralInk,
                                  ),
                                ),
                              if (overdue && sub.isNotEmpty)
                                const TextSpan(text: ' · '),
                              if (sub.isNotEmpty) TextSpan(text: sub),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            height: 1.3,
                            color: _slate,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkCircle(bool done) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? _amber : Colors.transparent,
        border: Border.all(
          color: done ? _amber : _navyFill.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 16, color: _navy)
          : null,
    );
  }

  // --------------------------------------------------------- aksi & menu
  Widget _quickActions(DateTime now) {
    final isWorkoutDay = [
      DateTime.monday,
      DateTime.wednesday,
      DateTime.friday,
    ].contains(now.weekday);
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
        const Text(
          'AKSI CEPAT',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10.5,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: _slate,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _showQuickExpense(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Catat uang'),
                style: FilledButton.styleFrom(
                  backgroundColor: _navyFill,
                  foregroundColor: Star.onAccent,
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  iosTapBuzz();
                  widget.onNavigate('workout');
                },
                icon: Icon(
                  isWorkoutDay
                      ? Icons.play_arrow_rounded
                      : Icons.event_available_outlined,
                  size: 18,
                ),
                label: Text(isWorkoutDay ? 'Mulai sesi' : 'Jadwal'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  minimumSize: const Size(0, 46),
                  side: const BorderSide(color: _border, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: shortcuts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = shortcuts[i];
              return InkWell(
                onTap: () {
                  iosTapBuzz();
                  widget.onNavigate(s.page);
                },
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: Neu.raised(r: 10, d: 3),
                        child: Icon(s.icon, size: 19, color: _navy),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _slate,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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
    final image = 'assets/images/paket_${key.toLowerCase()}.png';

    return Container(
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'MENU MAKANAN',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: _slate,
                    ),
                  ),
                ),
                _textLink('Lihat semua', () {
                  iosTapBuzz();
                  widget.onNavigate('planning');
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SingleChildScrollView(
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 104,
                    height: 104,
                    color: Star.surface2,
                    child: Image.asset(
                      image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.restaurant_outlined,
                        color: _slate,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                          fontSize: 10.5,
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.w700,
                          color: Star.faint,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          height: 1.22,
                          fontWeight: FontWeight.w700,
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
                            fontSize: 11.5,
                            height: 1.45,
                            color: _slate,
                          ),
                        ),
                      ],
                      const SizedBox(height: 5),
                      Text(
                        '$kcal kkal · $protein g protein',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _slate,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: rp(budget),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _navy,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const TextSpan(
                          text: ' /hari',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
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
                  child: const SizedBox(
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat resep',
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: _navy,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _navyFill : _card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _navyFill : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Star.onAccent : _slate,
          ),
        ),
      ),
    );
  }

  Widget _routineStrip(int days, String monthKey) {
    return InkWell(
      onTap: () => _showRoutineSheet(context, monthKey),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: Neu.raised(r: 16, d: 5),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _canvas,
                shape: BoxShape.circle,
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: _navy,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rutinitas bulan ini',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    days == 0
                        ? 'Belum ada hari yang tercatat.'
                        : '$days hari tuntas · lihat tracker',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11.5,
                      color: _slate,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: _slate),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- helpers
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: 38,
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
