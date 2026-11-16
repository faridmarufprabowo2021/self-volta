// Kartu nada alarm kustom: pilih file audio milik user, dengar contoh, dan
// hapus. File aslinya disalin ke penyimpanan app oleh Android asli, jadi
// tetap bisa diputar walau file asli dipindah/dihapus dari HP.
//
// Catatan penting: nada ini hanya untuk alarm layar penuh. Notifikasi biasa
// memakai kanal Android yang nadanya dikunci saat kanal dibuat.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/alarm_audio.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class CustomAlarmCard extends StatefulWidget {
  /// Tampilkan versi lebih rapat (dipakai di sheet yang sudah panjang).
  final bool dense;

  const CustomAlarmCard({super.key, this.dense = false});

  @override
  State<CustomAlarmCard> createState() => _CustomAlarmCardState();
}

class _CustomAlarmCardState extends State<CustomAlarmCard> {
  bool _busy = false;

  void _toast(String copy, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(copy),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? Star.error : Star.star,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _pick() async {
    if (_busy) return;
    iosTapBuzz();
    setState(() => _busy = true);
    try {
      final name = await AlarmAudio.pickCustom();
      if (name == null || name.trim().isEmpty) return;
      await AppState.I.setCustomAlarmName(name);
      if (!mounted) return;
      _toast('Nada alarm disimpan: ${name.trim()}');
    } on PlatformException catch (e) {
      if (!mounted) return;
      _toast(e.message ?? 'File audio tidak bisa dipakai.', error: true);
    } catch (_) {
      if (!mounted) return;
      _toast('Tidak bisa membuka file audio.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    iosTapBuzz();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Star.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus nada kustom?',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Star.ink,
          ),
        ),
        content: const Text(
          'Alarm layar penuh akan kembali memakai nada alarm bawaan HP.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12.5,
            height: 1.45,
            color: Star.mut,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: Star.mut,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                color: Star.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AppState.I.clearCustomAlarm();
    _toast('Nada kustom dihapus.');
  }

  void _preview() {
    iosTapBuzz();
    AlarmAudio.previewCustom();
    _toast('Memutar contoh nada kustom ±6 detik.');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        final st = AppState.I;
        final has = st.hasCustomAlarm;
        final name = st.customAlarmName.trim();
        return Container(
          padding: EdgeInsets.fromLTRB(12, widget.dense ? 10 : 12, 8, 12),
          decoration: BoxDecoration(
            color: Star.fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Star.lineSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: widget.dense ? 32 : 36,
                    height: widget.dense ? 32 : 36,
                    decoration: BoxDecoration(
                      color: Star.star.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      has
                          ? Icons.audio_file_rounded
                          : Icons.library_music_outlined,
                      size: widget.dense ? 17 : 19,
                      color: Star.star,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          has ? name : 'Belum ada audio pilihanmu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: widget.dense ? 12.5 : 13,
                            fontWeight: FontWeight.w700,
                            color: Star.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          has
                              ? 'Dipakai untuk alarm layar penuh'
                              : 'MP3, WAV, M4A · maksimal 25 MB',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10.5,
                            color: Star.mut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (has) ...[
                    IconButton(
                      key: const Key('custom-alarm-play'),
                      onPressed: _preview,
                      tooltip: 'Dengar nada kustom',
                      iconSize: 19,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      padding: EdgeInsets.zero,
                      color: Star.success,
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
                    IconButton(
                      key: const Key('custom-alarm-delete'),
                      onPressed: _delete,
                      tooltip: 'Hapus nada kustom',
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      padding: EdgeInsets.zero,
                      color: Star.error,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('custom-alarm-pick'),
                  onPressed: _busy ? null : _pick,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Star.star,
                    side: const BorderSide(color: Star.line),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: _busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Star.star,
                          ),
                        )
                      : const Icon(Icons.upload_file_rounded, size: 17),
                  label: Text(
                    has ? 'Ganti audio dari HP' : 'Pilih audio dari HP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
