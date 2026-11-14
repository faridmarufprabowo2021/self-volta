// Halaman Study: pelacak sesi belajar + timer fokus.
//
// Bukan sekadar daftar: user mencatat mata pelajaran/aktivitas, target menit
// per minggu, lalu sesi dicatat otomatis dari timer (atau +15 menit manual).
// Data disimpan di sv_v1 (`studySubjects`, `studySessions`) sehingga tetap
// kompatibel dengan data lama.

import 'dart:async';

import 'package:flutter/material.dart';

import '../store.dart';
import '../widgets.dart';
import 'todo_page.dart';
import '../theme.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  static const _presets = [15, 25, 50];

  int _preset = 25;
  int _remaining = 25 * 60;
  bool _running = false;
  Timer? _tick;
  int? _subjectId;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  int? get _activeSubject {
    final subs = AppState.I.studySubjects;
    if (subs.isEmpty) return null;
    if (_subjectId != null && subs.any((s) => s.id == _subjectId)) {
      return _subjectId;
    }
    return subs.first.id;
  }

  void _select(int id) {
    iosTapBuzz();
    setState(() => _subjectId = id);
  }

  void _setPreset(int min) {
    iosTapBuzz();
    _tick?.cancel();
    setState(() {
      _preset = min;
      _remaining = min * 60;
      _running = false;
    });
  }

  void _startPause() {
    iosTapBuzz();
    if (_running) {
      _tick?.cancel();
      setState(() => _running = false);
      return;
    }
    if (AppState.I.studySubjects.isEmpty) {
      _toast('Tambah mata pelajaran dulu untuk mencatat sesi.');
      return;
    }
    setState(() => _running = true);
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) _finish();
    });
  }

  void _reset() {
    _tick?.cancel();
    setState(() {
      _running = false;
      _remaining = _preset * 60;
    });
  }

  Future<void> _finish() async {
    _tick?.cancel();
    final id = _activeSubject;
    setState(() {
      _running = false;
      _remaining = _preset * 60;
    });
    if (id == null) return;
    triumphBuzz();
    await AppState.I.logStudy(id, _preset);
    if (!mounted) return;
    _toast('Sesi $_preset menit tercatat.');
  }

  void _toast(String copy) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(copy),
          behavior: SnackBarBehavior.floating,
          backgroundColor: TodoPal.header,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _addSubject() => showStudySubjectSheet(context);

  Future<void> _log15(StudySubject s) async {
    iosTapBuzz();
    await AppState.I.logStudy(s.id, 15);
    if (!mounted) return;
    _toast('+15 menit untuk ${s.name}.');
  }

  Future<void> _deleteSubject(StudySubject s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Star.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus mata pelajaran?',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: TodoPal.ink,
          ),
        ),
        content: Text(
          'Riwayat sesi "${s.name}" ikut dihapus. Tindakan ini tidak bisa dibatalkan.',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12.5,
            height: 1.4,
            color: TodoPal.sec,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12.5,
                color: TodoPal.sec,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: TodoPal.coral,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await AppState.I.deleteStudySubject(s.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        final st = AppState.I;
        final subs = st.studySubjects;
        final week = st.studyMinutesWeek;
        final target = subs.fold<int>(0, (a, s) => a + s.targetMin);
        final progress = target == 0 ? 0.0 : (week / target).clamp(0.0, 1.0);
        final last7 = st.studyLast7Minutes;

        return Container(
          color: TodoPal.canvas,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.zero,
            children: [
              _StudyHeader(
                minutes: week,
                target: target,
                progress: progress.toDouble(),
                sessionsToday: st.studySessionsToday,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _FocusCard(
                  timer: _timerLabel(),
                  progress: 1 - (_remaining / (_preset * 60)),
                  running: _running,
                  subjects: subs,
                  activeId: _activeSubject,
                  preset: _preset,
                  presets: _presets,
                  onPreset: _setPreset,
                  onSubject: _select,
                  onStartPause: _startPause,
                  onReset: _reset,
                  onAddSubject: _addSubject,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _WeekChart(minutes: last7),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Mata pelajaran',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: TodoPal.ink,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _addSubject,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded, size: 15, color: Star.star),
                            SizedBox(width: 3),
                            Text(
                              'Tambah',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Star.star,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (subs.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: Neu.raised(r: 16, d: 5),
                    child: Column(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: TodoPal.mintSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 24,
                            color: Star.star,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum ada mata pelajaran.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            color: TodoPal.sec,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tambahkan satu, lalu mulai sesi fokus 25 menit.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11.5,
                            color: TodoPal.ter,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 38,
                          child: FilledButton.icon(
                            onPressed: _addSubject,
                            style: FilledButton.styleFrom(
                              backgroundColor: TodoPal.header,
                              foregroundColor: Star.onAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Tambah mata pelajaran'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final s in subs)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _SubjectRow(
                      subject: s,
                      minutes: st.studyMinutesWeekOf(s.id),
                      onLog15: () => _log15(s),
                      onDelete: () => _deleteSubject(s),
                    ),
                  ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  String _timerLabel() {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ============================================================================
// Bagian UI
// ============================================================================

class _StudyHeader extends StatelessWidget {
  final int minutes, target, sessionsToday;
  final double progress;

  const _StudyHeader({
    required this.minutes,
    required this.target,
    required this.progress,
    required this.sessionsToday,
  });

  static String _dur(int m) {
    if (m < 60) return '$m menit';
    final h = m ~/ 60;
    final r = m % 60;
    return r == 0 ? '$h jam' : '$h j ${r}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Star.bg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
        boxShadow: Neu.shadows(d: 6),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Star.ink.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: Star.ink,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Study & fokus',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Star.ink,
                ),
              ),
              const Spacer(),
              Text(
                '$sessionsToday sesi hari ini',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: Star.mut,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minggu ini',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: Star.mut,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _dur(minutes),
                        maxLines: 1,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 30,
                          height: 1.06,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.7,
                          color: Star.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      target == 0
                          ? 'Belum ada target mingguan'
                          : 'Target ${_dur(target)}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.5,
                        color: Star.mut,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 62,
                height: 62,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Star.success),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  final String timer;
  final double progress;
  final bool running;
  final List<StudySubject> subjects;
  final int? activeId;
  final int preset;
  final List<int> presets;
  final ValueChanged<int> onPreset;
  final ValueChanged<int> onSubject;
  final VoidCallback onStartPause;
  final VoidCallback onReset;
  final VoidCallback onAddSubject;

  const _FocusCard({
    required this.timer,
    required this.progress,
    required this.running,
    required this.subjects,
    required this.activeId,
    required this.preset,
    required this.presets,
    required this.onPreset,
    required this.onSubject,
    required this.onStartPause,
    required this.onReset,
    required this.onAddSubject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: Neu.raised(r: 18, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Star.star),
              const SizedBox(width: 6),
              const Text(
                'Sesi fokus',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: TodoPal.ink,
                ),
              ),
              const Spacer(),
              for (final p in presets) ...[
                GestureDetector(
                  onTap: () => onPreset(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: preset == p ? TodoPal.header : TodoPal.field,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$p',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: preset == p ? Star.onAccent : TodoPal.sec,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            running
                ? 'Sedang berjalan — fokus sampai selesai.'
                : 'Pilih pelajaran, lalu mulai.',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              color: TodoPal.ter,
            ),
          ),
          const SizedBox(height: 10),
          if (subjects.isEmpty)
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: onAddSubject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Star.star,
                  side: const BorderSide(color: TodoPal.mintBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Tambah mata pelajaran'),
              ),
            )
          else
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: subjects.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final s = subjects[i];
                  final on = s.id == activeId;
                  return InkWell(
                    onTap: () => onSubject(s.id),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: on ? TodoPal.mintSoft : TodoPal.field,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: on ? TodoPal.mintBorder : TodoPal.hair,
                        ),
                      ),
                      child: Text(
                        s.name,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: on ? Star.star : TodoPal.sec,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 66,
                      height: 66,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 5,
                        backgroundColor: Paper.hair,
                        valueColor: const AlwaysStoppedAnimation(
                          TodoPal.header,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        timer,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: TodoPal.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: FilledButton(
                        onPressed: onStartPause,
                        style: FilledButton.styleFrom(
                          backgroundColor: running
                              ? TodoPal.field
                              : TodoPal.header,
                          foregroundColor: running
                              ? TodoPal.ink
                              : Star.onAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(running ? 'Jeda' : 'Mulai sesi'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: TextButton(
                        onPressed: onReset,
                        style: TextButton.styleFrom(
                          foregroundColor: TodoPal.ter,
                          textStyle: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Reset timer'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  final List<int> minutes; // 7 nilai, terakhir = hari ini
  const _WeekChart({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final maxV = minutes.fold<int>(1, (a, b) => b > a ? b : a);
    final total = minutes.fold<int>(0, (a, b) => a + b);
    final today = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '7 hari terakhir',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: TodoPal.ink,
                ),
              ),
              const Spacer(),
              Text(
                total == 0 ? 'belum ada sesi' : '$total menit',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: TodoPal.ter,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Belum ada sesi tercatat. Mulai timer di atas, menitnya '
                'otomatis masuk ke grafik ini.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  height: 1.4,
                  color: TodoPal.ter,
                ),
              ),
            )
          else
            SizedBox(
              height: 92,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 7; i++)
                    _Bar(
                      value: minutes[i],
                      max: maxV,
                      isToday: i == 6,
                      label:
                          kTodoHariPendek[today
                              .subtract(Duration(days: 6 - i))
                              .weekday],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final int value, max;
  final bool isToday;
  final String label;

  const _Bar({
    required this.value,
    required this.max,
    required this.isToday,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value',
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: value == 0 ? TodoPal.ter : Star.star,
              ),
            ),
          ),
          const SizedBox(height: 3),
          // Tinggi batang mengikuti ruang yang tersisa supaya tidak pernah
          // meluber saat ukuran teks sistem diperbesar.
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final maxH = c.maxHeight.isFinite ? c.maxHeight : 52.0;
                final h = value == 0
                    ? 4.0
                    : (value / max * maxH).clamp(6.0, maxH);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 14,
                    height: h,
                    decoration: BoxDecoration(
                      color: value == 0
                          ? Paper.hair
                          : (isToday ? TodoPal.header : TodoPal.mint),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 9,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? TodoPal.ink : TodoPal.ter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final StudySubject subject;
  final int minutes;
  final VoidCallback onLog15;
  final VoidCallback onDelete;

  const _SubjectRow({
    required this.subject,
    required this.minutes,
    required this.onLog15,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final target = subject.targetMin <= 0 ? 180 : subject.targetMin;
    final p = (minutes / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: Neu.raised(r: 14, d: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: TodoPal.mintSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 17,
              color: Star.star,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TodoPal.ink,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: p.toDouble(),
                    minHeight: 5,
                    backgroundColor: Paper.hair,
                    valueColor: const AlwaysStoppedAnimation(TodoPal.header),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$minutes / $target menit minggu ini',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    color: TodoPal.ter,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onLog15,
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: TodoPal.mintSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                '+15',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Star.star,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 17,
              color: TodoPal.ter,
            ),
            tooltip: 'Hapus mata pelajaran',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Sheet tambah mata pelajaran
// ============================================================================

Future<void> showStudySubjectSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SubjectSheet(),
  );
}

class _SubjectSheet extends StatefulWidget {
  const _SubjectSheet();

  @override
  State<_SubjectSheet> createState() => _SubjectSheetState();
}

class _SubjectSheetState extends State<_SubjectSheet> {
  final _name = TextEditingController();
  int _targetMin = 180;
  static const _targets = [120, 180, 300, 600];
  static const _labels = ['2 jam', '3 jam', '5 jam', '10 jam'];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = _name.text.trim();
    if (n.isEmpty) return;
    await AppState.I.addStudySubject(n, _targetMin);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Star.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Paper.hair,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Mata pelajaran baru',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: TodoPal.ink,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Beri nama aktivitas belajar dan target mingguan.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  color: TodoPal.sec,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _name,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TodoPal.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Mis. Matematika, Bahasa Inggris, Ngoding',
                  hintStyle: const TextStyle(color: Star.mut),
                  filled: true,
                  fillColor: TodoPal.field,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: TodoPal.hair,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: TodoPal.hair,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: TodoPal.header,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Target per minggu',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TodoPal.ter,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < _targets.length; i++)
                    InkWell(
                      onTap: () => setState(() => _targetMin = _targets[i]),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _targetMin == _targets[i]
                              ? TodoPal.header
                              : TodoPal.field,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: _targetMin == _targets[i]
                                ? TodoPal.header
                                : TodoPal.hair,
                          ),
                        ),
                        child: Text(
                          _labels[i],
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _targetMin == _targets[i]
                                ? Star.onAccent
                                : TodoPal.sec,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: TodoPal.header,
                    foregroundColor: Star.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Simpan mata pelajaran'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
