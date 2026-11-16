import 'dart:math';

import 'package:flutter/material.dart';

import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Halaman Piano — gaya KHUSUS beda dari halaman lain (referensi: fintech
/// savings-goal): hero gelap + progress RING (satu-satunya ring di app,
/// semua halaman lain pakai bar), opsi nabung berupa kartu lega satu-tap,
/// dan badge "Paling pas" pada opsi yang sesuai sisa keuangan (rekomendasi
/// personal — user langsung notice kombinasi yang bagus).
class InginPage extends StatelessWidget {
  const InginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (_, _) {
        final st = AppState.I;
        final got = st.pianoTotal;
        final left = (PIANO_TARGET - got).clamp(0, PIANO_TARGET);
        final pct = got / PIANO_TARGET * 100;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const SecHead(
              'ingin',
              Icons.piano_rounded,
              'Target Piano Rp1.500.000',
              'Nabung mingguan, terhubung sisa keuangan',
            ),
            _HeroRing(got: got, left: left, pct: pct),
            _OptionsCard(left: left),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Riwayat Setoran',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (st.piano.isEmpty)
                    const EmptyHint('Belum nabung — mulai 75rb minggu ini')
                  else
                    for (final d in st.piano.reversed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RowItem(
                          Icon(Icons.piano_rounded, color: Themes.ingin.acc),
                          'Minggu ${d.week} · ${d.date}',
                          rp(d.amt),
                          lh: 1.7,
                          trailing: IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => st.delSaving(d.id),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Hero gelap deep-sea + RING progres emas: signature halaman Piano.
class _HeroRing extends StatelessWidget {
  final int got, left;
  final double pct;
  const _HeroRing({required this.got, required this.left, required this.pct});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: Neu.raised(r: 22, d: 6),
      child: Column(
        children: [
          _PianoRing(pct),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Terkumpul: ${rp(got)}',
                  maxLines: 2,
                  style: const TextStyle(
                    color: Star.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  left == 0 ? 'LUNAS!' : 'Sisa: ${rp(left)}',
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Star.star,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${pct.toStringAsFixed(1)}% · $got dari 1.500.000',
            style: TextStyle(color: Star.mut, fontSize: 12, height: 1.7),
          ),
        ],
      ),
    );
  }
}

/// Ring progres emas + glow: satu-satunya indikator melingkar di app.
class _PianoRing extends StatelessWidget {
  final double pct;
  const _PianoRing(this.pct);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: CustomPaint(
        painter: _RingPainter((pct.clamp(0, 100)) / 100),
        child: Center(
          child: Text(
            '${pct.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Star.onAccent,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double t;
  _RingPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    final track = Paint()
      ..color = Star.ink.withValues(alpha: .08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, track);
    if (t <= 0) return;
    final prog = Paint()
      ..color = Star.star
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2,
      2 * pi * t,
      false,
      prog,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.t != t;
}

/// Kartu opsi mingguan: tiap nominal kartunya sendiri (lega, min 64px),
/// satu tap langsung nabung + snackbar. Opsi yang sesuai sisa keuangan
/// dapat badge "Paling pas" + border emas.
class _OptionsCard extends StatelessWidget {
  final int left;
  const _OptionsCard({required this.left});
  @override
  Widget build(BuildContext context) {
    final st = AppState.I;
    // Rekomendasi personal: nominal terbesar yang muat di sisa keuangan;
    // kalau sisa kosong, mulai dari yang paling ringan.
    const opts = [75000, 90000, 100000, 120000];
    var rec = opts.first;
    for (final v in opts.reversed) {
      if (st.sisa >= v) {
        rec = v;
        break;
      }
    }
    void save(int v) {
      final w = st.piano.length + 1;
      st.addSaving(w, v);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nabung ${rp(v)} minggu ke-$w tercatat')),
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HRow(
            Icons.savings_rounded,
            'ingin',
            'Nabung Mingguan',
            'Tap nominal → langsung tercatat',
          ),
          const SizedBox(height: 12),
          for (final v in opts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionTile(
                amount: v,
                weeks: (left / v).ceil(),
                recommended: v == rec && left > 0,
                onTap: () => save(v),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () async {
              final left2 = st.sisa;
              if (left2 < 75000) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Sisa keuangan ${rp(left2)}, belum cukup 75rb.',
                    ),
                  ),
                );
                return;
              }
              await st.takeFromSisa();
            },
            icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
            label: const Text('Ambil dari sisa keuangan'),
          ),
          const SizedBox(height: 12),
          Text(
            'Terhubung: sisa uang pegangan ${rp(st.sisa)} (income ${rp(st.income)} - keluar ${rp(st.totalOut)}).',
            style: AppText.secondary.copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final int amount;
  final int weeks;
  final bool recommended;
  final VoidCallback onTap;
  const _OptionTile({
    required this.amount,
    required this.weeks,
    required this.recommended,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    const gold = Star.star;
    return PopTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: recommended
              ? gold.withValues(alpha: .1)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: recommended ? gold : Star.overlay,
            width: recommended ? 2 : 1,
          ),
          boxShadow: [if (recommended) Star.glowStarSm(opacity: .2)],
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: recommended ? gold : Star.faint,
                  width: 2,
                ),
              ),
              child: recommended
                  ? const Icon(Icons.star_rounded, size: 16, color: gold)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rp(amount),
                    style: AppText.statNum.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '±$weeks minggu sampai lunas',
                    style: AppText.secondary.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
            if (recommended)
              const Pill('Paling pas', page: gold)
            else
              const Icon(Icons.chevron_right_rounded, color: Star.faint),
          ],
        ),
      ),
    );
  }
}
