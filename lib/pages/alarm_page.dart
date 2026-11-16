// Layar alarm layar penuh (bangun tidur / rutinitas).
//
// Dibuka dari notifikasi full-screen intent. Latar hitam OLED, jam besar,
// slider "Selesaikan" khas alarm HP. Saat slider selesai: suara berhenti,
// dialog high-five muncul, To-Do otomatis tuntas, dan rutinitas tercatat.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../services/alarm_audio.dart';
import '../services/todo_notifications.dart';
import '../store.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

bool _alarmVisible = false;

/// Buka layar alarm dari payload notifikasi. Aman dipanggil berkali-kali.
Future<void> openAlarmFromPayload(String payload) async {
  AlarmPayload data;
  try {
    data = AlarmPayload.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  } catch (_) {
    return;
  }
  // Notifikasi pengingat biasa hanya membuka app; layar alarm penuh khusus
  // untuk tugas yang memang ditandai alarm.
  if (!data.alarm || data.id == 0 || _alarmVisible) return;
  final nav = appNavigatorKey.currentState;
  if (nav == null) return;
  _alarmVisible = true;
  try {
    await nav.push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => AlarmPage(data: data),
      ),
    );
  } finally {
    _alarmVisible = false;
  }
}

class AlarmPayload {
  final int id;
  final String title;
  final String date;
  final int timeMin;
  final String sound;
  final bool alarm;
  final String repeat;

  const AlarmPayload({
    required this.id,
    required this.title,
    required this.date,
    required this.timeMin,
    required this.sound,
    required this.alarm,
    required this.repeat,
  });

  factory AlarmPayload.fromJson(Map<String, dynamic> j) => AlarmPayload(
    id: j['id'] as int? ?? 0,
    title: j['t'] as String? ?? 'Rutinitas',
    date: j['d'] as String? ?? '',
    timeMin: j['tm'] as int? ?? -1,
    sound: j['s'] as String? ?? '',
    alarm: j['a'] == true,
    repeat: j['rep'] as String? ?? '',
  );

  String get timeLabel => timeMin < 0
      ? ''
      : '${(timeMin ~/ 60).toString().padLeft(2, '0')}.'
            '${(timeMin % 60).toString().padLeft(2, '0')}';
}

class AlarmPage extends StatefulWidget {
  final AlarmPayload data;

  const AlarmPage({super.key, required this.data});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  static const _black = Color(0xFF050607);
  static const _white = Color(0xFFF5F7F8);
  static const _slate = Color(0xFF8D969D);
  static const _line = Color(0xFF252B2F);
  static const _coral = Color(0xFFE86A52);
  static const _cyan = Color(0xFF5BC8E8);

  Timer? _clock;
  DateTime _now = DateTime.now();
  double _progress = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: _black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    AlarmAudio.setAlarmMode(true);
    AlarmAudio.start(
      sound: AppState.I.hasCustomAlarm ? 'kustom' : widget.data.sound,
    );
  }

  @override
  void dispose() {
    _clock?.cancel();
    AlarmAudio.stop();
    AlarmAudio.setAlarmMode(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _complete() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.heavyImpact();
    await AlarmAudio.stop();
    final task = AppState.I.todos
        .where((t) => t.id == widget.data.id)
        .firstOrNull;
    final title = task?.title ?? widget.data.title;
    await AppState.I.completeTodoFromAlarm(widget.data.id);
    await TodoNotif.cancel(widget.data.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (ctx) => _SuccessDialog(title: title),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    await AlarmAudio.stop();
    await AppState.I.snoozeTodo(widget.data.id, minutes: 5);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _dismiss() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.selectionClick();
    await AlarmAudio.stop();
    await TodoNotif.cancel(widget.data.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hari = (widget.data.date.length >= 10)
        ? DateTime.tryParse(widget.data.date)
        : null;
    final dateLabel = hari == null
        ? ''
        : '${HARI_ID[hari.weekday]}, ${hari.day} '
                  '${BULAN_ID[hari.month]} ${hari.year}'
              .toUpperCase();
    final clock =
        '${_now.hour.toString().padLeft(2, '0')}:'
        '${_now.minute.toString().padLeft(2, '0')}';
    final task = AppState.I.todos
        .where((t) => t.id == widget.data.id)
        .firstOrNull;
    final title = task?.title ?? widget.data.title;
    final soundLabel = AppState.I.hasCustomAlarm
        ? 'Nada kustom'
        : widget.data.sound.isEmpty
        ? 'Nada setelan'
        : TodoNotif.soundLabel(widget.data.sound);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _dismiss();
      },
      child: Scaffold(
        backgroundColor: _black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text(
                      'SELF VOLTA',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: _slate,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      soundLabel.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: _slate,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: _slate,
                  ),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    clock,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 104,
                      height: 0.95,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -5,
                      color: _white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 9),
                      decoration: const BoxDecoration(
                        color: _cyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 23,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: _white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.data.repeat.isEmpty
                                ? 'Alarm · ${widget.data.timeLabel}'
                                : '${widget.data.repeat[0].toUpperCase()}'
                                      '${widget.data.repeat.substring(1)} · '
                                      '${widget.data.timeLabel}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: _slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                _buildSlider(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy ? null : _snooze,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _white,
                          side: const BorderSide(color: _line, width: 1.2),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('+5 mnt'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy ? null : _dismiss,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _slate,
                          side: const BorderSide(color: _line, width: 1.2),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Matikan'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Geser ke kanan untuk menyelesaikan rutinitas ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    color: _slate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return LayoutBuilder(
      builder: (context, box) {
        const thumb = 54.0;
        final maxLeft = (box.maxWidth - thumb).clamp(0.0, double.infinity);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _busy
              ? null
              : (d) {
                  setState(() {
                    _progress = (_progress + d.delta.dx / maxLeft).clamp(
                      0.0,
                      1.0,
                    );
                  });
                  if (_progress >= 0.97) _complete();
                },
          onHorizontalDragEnd: _busy
              ? null
              : (_) {
                  if (_progress < 0.82) {
                    setState(() => _progress = 0);
                  } else {
                    _complete();
                  }
                },
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFF111518),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: _line),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: (1 - _progress * 1.4).clamp(0.0, 1.0),
                    child: const Text(
                      'Selesaikan',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: _white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _progress * maxLeft,
                  top: 6,
                  child: Container(
                    width: thumb,
                    height: thumb,
                    decoration: const BoxDecoration(
                      color: _coral,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF2A0D08),
                      size: 27,
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
}

class _SuccessDialog extends StatelessWidget {
  final String title;

  const _SuccessDialog({required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF101416),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: Color(0xFF17313A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.back_hand_rounded,
                color: Color(0xFF5BC8E8),
                size: 31,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rutinitas selesai!',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: Color(0xFFF5F7F8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'High five! "$title" sudah tuntas dan tercatat di rutinitas bulan ini.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF9AA3A9),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F7F8),
                  foregroundColor: const Color(0xFF101416),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
