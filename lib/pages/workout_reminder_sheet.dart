// Sheet pengaturan pengingat latihan (notifikasi sistem).
//
// Jadwal diatur sendiri oleh user: hari (boleh lebih dari satu) + jam.
// Dipakai dari halaman Latihan dan Planning supaya jadwal bisa diubah
// tanpa harus mencari menu lain.

import 'package:flutter/material.dart';

import '../services/todo_notifications.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

Future<void> showWorkoutReminderSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _WorkoutReminderSheet(),
  );
}

class _WorkoutReminderSheet extends StatefulWidget {
  const _WorkoutReminderSheet();

  @override
  State<_WorkoutReminderSheet> createState() => _WorkoutReminderSheetState();
}

class _WorkoutReminderSheetState extends State<_WorkoutReminderSheet> {
  static const _wdNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  Future<void> _toggleDay(int day) async {
    final st = AppState.I;
    final next = Set<int>.of(st.workoutReminderDays);
    if (next.contains(day)) {
      if (next.length == 1) return; // minimal satu hari
      next.remove(day);
    } else {
      next.add(day);
    }
    await st.setWorkoutReminder(days: next);
    if (mounted) setState(() {});
  }

  Future<void> _pickTime() async {
    final st = AppState.I;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: st.workoutReminderMin ~/ 60,
        minute: st.workoutReminderMin % 60,
      ),
    );
    if (picked == null) return;
    await st.setWorkoutReminder(timeMin: picked.hour * 60 + picked.minute);
    if (mounted) setState(() {});
  }

  Future<void> _askPermission() async {
    await TodoNotif.requestPermission();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final st = AppState.I;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Star.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          top: false,
          // Bisa digulir: di layar pendek / font besar isi sheet tidak boleh
          // terpotong (overflow) — tombol Selesai selalu bisa dijangkau.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle manual (showDragHandle dimatikan global).
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Star.sunken,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Star.star.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        size: 18,
                        color: Star.star,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengingat latihan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: Star.ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Notifikasi sistem di hari & jam pilihanmu.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Star.mut,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Star.faint,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Switch aktif/mati
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                  decoration: BoxDecoration(
                    color: Star.fill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktifkan pengingat',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Star.ink,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bunyi di hari latihan, tanpa perlu app terbuka.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                color: Star.mut,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: st.workoutReminderOn,
                        activeThumbColor: Colors.white,
                        activeTrackColor: Star.star,
                        onChanged: (v) async {
                          await st.setWorkoutReminder(on: v);
                          if (mounted) setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Hari latihan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Star.mut,
                  ),
                ),
                const SizedBox(height: 8),
                // Satu baris 7 hari (tidak turun ke baris kedua walau layar
                // sempit): setiap chip mengambil lebar yang sama.
                Row(
                  children: [
                    for (var i = 0; i < 7; i++) ...[
                      if (i > 0) const SizedBox(width: 5),
                      Expanded(
                        child: _DayChip(
                          label: _wdNames[i],
                          active: st.workoutReminderDays.contains(i + 1),
                          enabled: st.workoutReminderOn,
                          onTap: () => _toggleDay(i + 1),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Jam
                InkWell(
                  onTap: st.workoutReminderOn ? _pickTime : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Star.fill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: Star.star,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Jam pengingat',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Star.ink,
                            ),
                          ),
                        ),
                        Text(
                          st.workoutReminderTimeLabel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: st.workoutReminderOn
                                ? Star.star
                                : Star.faint,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Star.faint,
                        ),
                      ],
                    ),
                  ),
                ),

                // Status izin / ketersediaan plugin
                if (!TodoNotif.ready) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Notifikasi sistem tidak tersedia di perangkat ini; '
                    'pengingat tampil sebagai banner di dalam aplikasi.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: Star.mut,
                    ),
                  ),
                ] else if (!TodoNotif.granted) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: FilledButton.icon(
                      onPressed: _askPermission,
                      style: FilledButton.styleFrom(
                        backgroundColor: Star.star,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: const Icon(Icons.notifications_rounded, size: 16),
                      label: const Text('Izinkan notifikasi'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      iosTapBuzz();
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Star.star,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Selesai'),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Pengingat disimpan otomatis di perangkat ini.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Star.faint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;
  const _DayChip({
    required this.label,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Star.star : Star.fill,
          borderRadius: BorderRadius.circular(9),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : (enabled ? Star.ink : Star.faint),
            ),
          ),
        ),
      ),
    );
  }
}
