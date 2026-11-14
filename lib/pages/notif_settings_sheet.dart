// Sheet setelan notifikasi: izin sistem, nada dering, getar, dan jadwal
// pengingat latihan. Nada default = nada notifikasi bawaan HP; user bisa
// memilih nada lain kapan saja (disimpan di sv_v1).

import 'package:flutter/material.dart';

import '../services/todo_notifications.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'workout_reminder_sheet.dart';

Future<void> showNotifSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _NotifSettingsSheet(),
  );
}

class _NotifSettingsSheet extends StatefulWidget {
  const _NotifSettingsSheet();

  @override
  State<_NotifSettingsSheet> createState() => _NotifSettingsSheetState();
}

class _NotifSettingsSheetState extends State<_NotifSettingsSheet> {
  bool _asking = false;

  Future<void> _askPermission() async {
    setState(() => _asking = true);
    final ok = await TodoNotif.requestPermission();
    if (!mounted) return;
    setState(() => _asking = false);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Izin notifikasi diberikan.'
                : 'Izin belum diberikan — aktifkan dari Setelan Android.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _testAlarm() async {
    final ok = await TodoNotif.scheduleTest();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Notifikasi uji dijadwalkan 10 detik lagi. Kunci layar sekarang.'
                : 'Gagal menjadwalkan alarm — cek izin notifikasi Android.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _askFullScreen() async {
    final ok = await TodoNotif.requestFullScreenPermission();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok == true
                ? 'Izin alarm layar penuh aktif.'
                : ok == null
                ? 'Android versi ini tidak membutuhkan izin tambahan.'
                : 'Izin belum diberikan — alarm tetap muncul sebagai notifikasi.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _pickSound(String key) async {
    final st = AppState.I;
    if (st.notifSound == key) {
      // Ketuk ulang nada yang sama = dengar contohnya lagi.
      await TodoNotif.showTest();
      return;
    }
    iosTapBuzz();
    await st.setNotifPrefs(sound: key);
    if (!mounted) return;
    setState(() {});
    await TodoNotif.showTest();
  }

  @override
  Widget build(BuildContext context) {
    final st = AppState.I;
    final ok = TodoNotif.ready && TodoNotif.granted;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Star.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            'Notifikasi',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: Star.ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Nada, getar, izin, dan jadwal pengingat.',
                            style: TextStyle(
                              fontFamily: 'Manrope',
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
                const SizedBox(height: 14),

                // ---- status izin ----
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: ok
                        ? Star.success.withValues(alpha: .08)
                        : Star.warning.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ok
                          ? Star.success.withValues(alpha: .22)
                          : Star.warning.withValues(alpha: .22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ok
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        size: 20,
                        color: ok ? Star.success : Star.warning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ok
                                  ? 'Notifikasi aktif'
                                  : 'Notifikasi belum aktif',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: ok ? Star.success : Star.warning,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              !TodoNotif.ready
                                  ? 'Perangkat ini tidak mendukung notifikasi sistem; pengingat tampil sebagai banner di app.'
                                  : ok
                                  ? 'Pengingat muncul di luar app, termasuk saat layar mati.'
                                  : 'Izinkan sekali agar pengingat bisa berbunyi.',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11.5,
                                height: 1.35,
                                color: Star.mut,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (TodoNotif.ready && !ok) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 34,
                          child: FilledButton(
                            onPressed: _asking ? null : _askPermission,
                            style: FilledButton.styleFrom(
                              backgroundColor: Star.star,
                              foregroundColor: Star.onAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
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
                            child: Text(_asking ? '…' : 'Izinkan'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ---- nada dering ----
                const _SecLabel('Nada dering'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Star.fill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < AppState.notifSounds.length; i++) ...[
                        if (i > 0)
                          const Padding(
                            padding: EdgeInsets.only(left: 46),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: Star.lineSoft,
                            ),
                          ),
                        _SoundRow(
                          key: Key('notif-sound-${AppState.notifSounds[i]}'),
                          title: _soundTitle(i),
                          subtitle: _soundSub(i),
                          selected: st.notifSound == AppState.notifSounds[i],
                          onTap: () => _pickSound(AppState.notifSounds[i]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Nada diputar sebagai contoh saat dipilih. Pengaturan nada '
                  'per aplikasi di Android hanya berlaku untuk kanal baru, '
                  'jadi pengingat dijadwalkan ulang otomatis.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    height: 1.4,
                    color: Star.faint,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: !TodoNotif.ready ? null : TodoNotif.showTest,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Star.star,
                      side: const BorderSide(color: Star.line, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Tes nada sekarang'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: !TodoNotif.ready ? null : _testAlarm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Star.star,
                      side: const BorderSide(color: Star.line, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.alarm_rounded, size: 18),
                    label: const Text('Tes alarm 10 detik'),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tes nada = langsung berbunyi. Tes alarm = lewat sistem, sama '
                  'seperti pengingat tugas; kunci layar setelah menekannya.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    height: 1.45,
                    color: Star.mut,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: !TodoNotif.ready ? null : _askFullScreen,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Star.star,
                      side: const BorderSide(color: Star.line, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.lock_open_rounded, size: 18),
                    label: const Text('Izinkan alarm layar penuh'),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Android 14+ meminta izin khusus agar alarm bisa membuka '
                  'layar saat HP terkunci. Tanpa izin, alarm tetap berbunyi '
                  'sebagai notifikasi biasa.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    height: 1.4,
                    color: Star.faint,
                  ),
                ),
                const SizedBox(height: 18),

                // ---- getar ----
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
                  decoration: BoxDecoration(
                    color: Star.fill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Getar',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Star.ink,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Ikut pola getar bawaan ponsel.',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11.5,
                                color: Star.mut,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: st.notifVibrate,
                        activeThumbColor: Star.onAccent,
                        activeTrackColor: Star.star,
                        onChanged: (v) async {
                          await AppState.I.setNotifPrefs(vibrate: v);
                          if (mounted) setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ---- jadwal pengingat latihan ----
                const _SecLabel('Pengingat latihan'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => showWorkoutReminderSheet(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                    decoration: BoxDecoration(
                      color: Star.fill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.fitness_center_rounded,
                          size: 18,
                          color: Star.star,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                st.workoutReminderOn
                                    ? '${st.workoutReminderDaysLabel} · ${st.workoutReminderTimeLabel}'
                                    : 'Nonaktif',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Star.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Ubah hari & jam pengingat latihan.',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11.5,
                                  color: Star.mut,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Star.faint,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pengingat To-Do otomatis aktif saat tugas diberi jam. '
                  'Setiap tugas bisa dimatikan sendiri di editornya.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    height: 1.4,
                    color: Star.faint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _soundTitle(int i) => switch (i) {
    0 => 'Nada sistem',
    1 => 'Ding',
    2 => 'Chime',
    3 => 'Lembut',
    _ => '',
  };

  static String _soundSub(int i) => switch (i) {
    0 => 'Bawaan HP — default sebelum diubah',
    1 => 'Bel tunggal pendek, tegas',
    2 => 'Dua nada naik, seperti pesan masuk',
    3 => 'Nada rendah hangat untuk malam',
    _ => '',
  };
}

class _SecLabel extends StatelessWidget {
  final String text;
  const _SecLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Manrope',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Star.mut,
    ),
  );
}

class _SoundRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SoundRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? Star.star : Star.faint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Star.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: Star.mut,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.graphic_eq_rounded, size: 18, color: Star.star),
          ],
        ),
      ),
    );
  }
}
