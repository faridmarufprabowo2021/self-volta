import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../store.dart';
import '../widgets.dart';
import '../theme.dart';

// Palet "Kertas & Tinta" untuk halaman Uang: kanvas terang, kartu putih
// bergaris rambut, navy sebagai jangkar, amber hanya untuk uang/progres.
const Color _kCanvas = Star.bg;
const Color _kCard = Star.surface;
const Color _kBorder = Paper.hair;
const Color _kNavy = Star.ink;
const Color _kNavyFill = Star.star;
const Color _kSlate = Star.mut;
const Color _kAmber = Star.star;
const Color _kAmberDark = Paper.amberInk;
const Color _kCyan = Star.star;
const Color _kCyanPill = Star.sunken;

/// Kartu putih dasar halaman Uang. Dibuat lokal agar halaman lain yang masih
/// memakai tema lama tidak ikut berubah.
class _KCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;

  const _KCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color = _kCard,
    this.borderColor = _kBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Neu.raised(
        r: 22,
        d: 6,
        color: (color == _kCard || color == _kNavyFill) ? null : color,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _KSectionHead extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _KSectionHead({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow.isNotEmpty)
                Text(
                  eyebrow.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _kSlate,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16.5,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  height: 1.45,
                  color: _kSlate,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}

class _KIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _KIconBox({required this.icon, this.color = _kNavy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: Neu.raised(r: 10, d: 3),
      child: Icon(icon, size: 17, color: color),
    );
  }
}

class KeuanganPage extends StatelessWidget {
  const KeuanganPage({super.key});

  void _showFloatingCalcSheet(BuildContext context) {
    iosTapBuzz();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: _kCanvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const _KIconBox(
                    icon: Icons.calculate_outlined,
                    color: _kNavyFill,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kalkulator',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: -0.3,
                            color: _kNavy,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Hitung belanja & harga per porsi',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11.5,
                            color: _kSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _Calc(),
            ],
          ),
        ),
      ),
    );
  }

  void _showPianoDepositDialog(BuildContext context, AppState st) {
    iosTapBuzz();
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.piano_rounded, color: _kAmberDark),
            SizedBox(width: 8),
            Text(
              'Setor Tabungan Piano',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Target Rp1.500.000 untuk keyboard/piano impian.',
              style: TextStyle(fontSize: 12, color: _kSlate),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: 'Contoh: 50.000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final raw = ctrl.text
                  .replaceAll('.', '')
                  .replaceAll(',', '')
                  .trim();
              final amt = int.tryParse(raw) ?? 0;
              if (amt <= 0) return;
              final now = DateTime.now();
              await st.addSaving(st.piano.length + 1, amt);
              await st.addTxn(
                'Setor Tabungan Piano',
                amt,
                hari: now.day,
                kat: 'lain',
              );
              st.addXp(20);
              triumphBuzz();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _kAmberDark,
                    content: Text(
                      'Berhasil menyetor Rp$raw ke Target Piano! (+20 XP)',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAmberDark,
              foregroundColor: Star.onAccent,
            ),
            child: const Text('Simpan Setoran'),
          ),
        ],
      ),
    );
  }

  void _showKeuanganTutorial(BuildContext context) {
    showInteractiveSpotlightTutorial(
      context,
      tutorialTitle: 'Panduan Finansial Kost',
      steps: const [
        TutorialStepItem(
          title: 'Kalkulator Belanja Anti-Jebol',
          category: 'Kalkulasi Praktis & Presisi',
          featureTag: 'Sistem Hitung Aman',
          description: 'Gunakan kalkulator mengambang untuk menjumlahkan belanja pasar, bagi biaya sewa kost, atau hitung selisih harga. Dilengkapi pelindung pembagian nol dan format error otomatis.',
          tip: 'Bisa dibuka kapan saja dengan mengetuk tombol Kalkulator di pojok kanan bawah layar.',
          icon: Icons.calculate_rounded,
          accentColor: Star.star,
        ),
        TutorialStepItem(
          title: 'Catat Pemasukan & Pengeluaran',
          category: 'Manajemen Kas Bulanan',
          featureTag: 'Validasi Angka Bounded',
          description: 'Input nominal harian terlindungi dengan pemisah ribuan titik otomatis. Mencegah angka ekstrem (maksimal Rp 1 Miliar) dan menjamin data tersimpan aman di database lokal.',
          tip: 'Kategorikan belanja ke Lauk/Protein, Sayur, Beras, atau Lainnya untuk analisis proporsi nutrisi.',
          icon: Icons.receipt_long_rounded,
          accentColor: Star.success,
        ),
        TutorialStepItem(
          title: 'Sinkronisasi Jatah Harian & Tabungan',
          category: 'Ekonomi Kost Cerdas',
          featureTag: 'Realtime Budget Tracker',
          description: 'Aplikasi membagi sisa budget dengan sisa hari bulan berjalan secara otomatis sehingga kamu tahu persis batas pengeluaran aman hari ini.',
          tip: 'Pantau kartu Target Impian (Piano) untuk mengalokasikan sisa uang belanja ke tabungan produktif.',
          icon: Icons.savings_rounded,
          accentColor: Star.star,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        final st = AppState.I;
        final budget = st.budget;
        final totalOut = st.totalOut;
        final double usedRatio = budget > 0
            ? (totalOut / budget).clamp(0.0, 1.0)
            : 0.0;
        final int pctUsed = (usedRatio * 100).round();

        final now = DateTime.now();
        final dim = st.daysInSelMonth();
        final isCurrentMonth =
            st.calYear == now.year && st.calMonth == now.month;
        final daysLeft = isCurrentMonth
            ? (dim - now.day + 1).clamp(1, 31)
            : dim;
        final jatahHarian = st.sisaBudget <= 0
            ? 0
            : (st.sisaBudget / daysLeft).floor();
        final pianoPct = (st.pianoTotal / PIANO_TARGET).clamp(0.0, 1.0);

        Widget metric(String label, String value) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: Star.mut,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Star.ink,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: _kCanvas,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showFloatingCalcSheet(context),
            backgroundColor: _kNavyFill,
            foregroundColor: Star.onAccent,
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            icon: const Icon(Icons.calculate_outlined, size: 18),
            label: const Text(
              'Kalkulator',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              _header(context),
              const SizedBox(height: 16),

              // Jangkar halaman: ringkasan anggaran bulan berjalan.
              _KCard(
                color: _kNavyFill,
                borderColor: _kNavyFill,
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                onTap: () => _showBudgetSheet(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SISA BUDGET',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Star.mut,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Atur',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Star.mut,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(Icons.tune_rounded, size: 15, color: Star.mut),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        rp(st.sisaBudget),
                        maxLines: 1,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 31,
                          height: 1.05,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: Star.ink,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$pctUsed% terpakai · jatah ${rp(jatahHarian)}/hari',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.5,
                        color: Star.mut,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: usedRatio,
                        minHeight: 5,
                        backgroundColor: Star.ink.withValues(alpha: 0.07),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          _kAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 1,
                      color: Star.ink.withValues(alpha: 0.07),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        metric('Masuk', rp(st.totalIn)),
                        Container(
                          width: 1,
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: Star.ink.withValues(alpha: 0.07),
                        ),
                        metric('Keluar', rp(totalOut)),
                        Container(
                          width: 1,
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: Star.ink.withValues(alpha: 0.07),
                        ),
                        metric('Pegangan', rp(st.sisa)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Target tabungan tetap terlihat, tetapi tidak mendominasi.
              _KCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _KIconBox(
                          icon: Icons.piano_outlined,
                          color: _kAmberDark,
                        ),
                        const SizedBox(width: 11),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target Tabungan Piano',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: _kNavy,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Keyboard impian · Rp1.500.000',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11.5,
                                  color: _kSlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(pianoPct * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kAmberDark,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pianoPct,
                        minHeight: 5,
                        backgroundColor: _kCanvas,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          _kAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terkumpul ${rp(st.pianoTotal)}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _kNavy,
                          ),
                        ),
                        Text(
                          'Sisa ${rp((PIANO_TARGET - st.pianoTotal).clamp(0, PIANO_TARGET))}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11.5,
                            color: _kSlate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: () => _showPianoDepositDialog(context, st),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kNavy,
                          side: const BorderSide(color: _kBorder),
                          minimumSize: const Size(0, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 16,
                        ),
                        label: const Text('Setor tabungan'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              const _MoneyCalendar(),
              const SizedBox(height: 14),

              _KCard(child: const _DayGrid()),
              const SizedBox(height: 14),

              _KCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _KSectionHead(
                      eyebrow: 'Catat cepat',
                      title: 'Tambah transaksi',
                      subtitle: 'Pemasukan atau pengeluaran, langsung masuk rekap bulan ini.',
                    ),
                    const SizedBox(height: 4),
                    const _TxnInput(),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _KCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _KSectionHead(
                      eyebrow: 'Riwayat',
                      title: 'Transaksi bulan ini',
                      subtitle:
                          '${st.txnsSel.length} catatan · urut paling baru',
                    ),
                    const SizedBox(height: 10),
                    _TxnTable(st),
                    if (st.txnsSel.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: _kBorder),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _confirmClearTxns(context),
                          style: TextButton.styleFrom(
                            foregroundColor: _kSlate,
                            textStyle: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                          ),
                          label: const Text('Kosongkan bulan ini'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'LAPORAN BULAN INI',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: _kSlate,
                  ),
                ),
              ),
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: () => _showKeuanganTutorial(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kNavy,
                    side: const BorderSide(color: _kBorder),
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: const Icon(Icons.menu_book_outlined, size: 14),
                  label: const Text('Panduan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Laporan & Keuangan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 25,
              height: 1.15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Anggaran, tabungan, dan catatan harian dalam satu tempat.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.5,
              height: 1.45,
              color: _kSlate,
            ),
          ),
        ],
      ),
    );
  }

  void _showBudgetSheet(BuildContext context) {
    iosTapBuzz();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kCanvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _BudgetSheet(),
    );
  }

  void _confirmClearTxns(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus semua?'),
        content: const Text('Hapus semua data keuangan lokal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              AppState.I.clearTxns();
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _BudgetSheet extends StatefulWidget {
  const _BudgetSheet();

  @override
  State<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends State<_BudgetSheet> {
  late final TextEditingController _budget = TextEditingController(
    text: ThousandsSeparatorInputFormatter.format(AppState.I.budget.toString()),
  );
  late final TextEditingController _income = TextEditingController(
    text: ThousandsSeparatorInputFormatter.format(AppState.I.income.toString()),
  );

  @override
  void dispose() {
    _budget.dispose();
    _income.dispose();
    super.dispose();
  }

  void _save() {
    final b = int.tryParse(_budget.text.replaceAll('.', '')) ?? 0;
    final i = int.tryParse(_income.text.replaceAll('.', '')) ?? 0;
    AppState.I.budget = b.clamp(0, 1000000000);
    AppState.I.income = i.clamp(0, 1000000000);
    AppState.I.save();
    Navigator.pop(context);
  }

  Widget _field(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandsSeparatorInputFormatter(),
      ],
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _kNavy,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: 'Rp ',
        filled: true,
        fillColor: _kCard,
        prefixStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _kSlate,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kNavyFill, width: 1.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Atur anggaran',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Budget dipakai untuk menghitung sisa dan jatah harian.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    height: 1.45,
                    color: _kSlate,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Budget bulanan',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _kSlate,
                  ),
                ),
                const SizedBox(height: 6),
                _field(_budget, '750.000'),
                const SizedBox(height: 14),
                const Text(
                  'Uang pegangan',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _kSlate,
                  ),
                ),
                const SizedBox(height: 6),
                _field(_income, '900.000'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kCyanPill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: _kCyan),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Uang pegangan adalah saldo awal sebelum pengeluaran. '
                          'Sisa budget dipakai untuk jatah harian.',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            height: 1.45,
                            color: _kNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: _kNavyFill,
                      foregroundColor: Star.onAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Simpan pengaturan'),
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

class _Calc extends StatefulWidget {
  const _Calc();
  @override
  State<_Calc> createState() => _CalcState();
}

class _CalcState extends State<_Calc> {
  String expr = '';
  void press(String k) {
    setState(() {
      if (k == 'C') {
        expr = '';
      } else if (k == 'DEL') {
        expr = expr.isEmpty ? '' : expr.substring(0, expr.length - 1);
      } else if (k == '=') {
        try {
          final r = _eval(expr);
          expr = r == null
              ? 'Salah'
              : r.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
        } catch (_) {
          expr = 'Salah';
        }
      } else {
        expr += k;
      }
    });
  }

  double? _eval(String e) {
    try {
      final s = e
          .replaceAll('×', '*')
          .replaceAll('x', '*')
          .replaceAll('X', '*')
          .replaceAll('÷', '/')
          .replaceAll(':', '/')
          .replaceAll(',', '.')
          .trim();
      if (s.isEmpty) return null;

      final tokens = <String>[];
      var i = 0;
      while (i < s.length) {
        final ch = s[i];
        if (ch == ' ') {
          i++;
          continue;
        }
        if ('+-*/()'.contains(ch)) {
          tokens.add(ch);
          i++;
        } else if (RegExp(r'[0-9.]').hasMatch(ch)) {
          final start = i;
          while (i < s.length && RegExp(r'[0-9.]').hasMatch(s[i])) {
            i++;
          }
          tokens.add(s.substring(start, i));
        } else {
          return null;
        }
      }

      if (tokens.isEmpty) return null;

      int pos = 0;
      late double Function() parseExpression;
      late double Function() parseTerm;
      late double Function() parseFactor;

      parseFactor = () {
        if (pos >= tokens.length) throw Exception('End');
        final t = tokens[pos];
        if (t == '+') {
          pos++;
          return parseFactor();
        }
        if (t == '-') {
          pos++;
          return -parseFactor();
        }
        if (t == '(') {
          pos++;
          final val = parseExpression();
          if (pos < tokens.length && tokens[pos] == ')') {
            pos++;
          }
          return val;
        }
        final num = double.tryParse(t);
        if (num == null) throw Exception('NaN');
        pos++;
        return num;
      };

      parseTerm = () {
        var left = parseFactor();
        while (pos < tokens.length &&
            (tokens[pos] == '*' || tokens[pos] == '/')) {
          final op = tokens[pos];
          pos++;
          final right = parseFactor();
          if (op == '*') {
            left *= right;
          } else {
            if (right == 0 || right.abs() < 1e-12) {
              throw Exception('Div0');
            }
            left /= right;
          }
        }
        return left;
      };

      parseExpression = () {
        var left = parseTerm();
        while (pos < tokens.length &&
            (tokens[pos] == '+' || tokens[pos] == '-')) {
          final op = tokens[pos];
          pos++;
          final right = parseTerm();
          if (op == '+') {
            left += right;
          } else {
            left -= right;
          }
        }
        return left;
      };

      final result = parseExpression();
      if (result.isNaN || result.isInfinite) return null;
      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ops = ['+', '-', '×', '÷', '(', ')'];
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: Neu.raised(r: 14, d: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'HASIL',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: _kSlate,
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  expr.isEmpty ? '0' : expr,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: _kNavy,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (final row in [
          ['C', '(', ')', 'DEL'],
          ['7', '8', '9', '÷'],
          ['4', '5', '6', '×'],
          ['1', '2', '3', '-'],
          ['0', '.', '=', '+'],
        ])
          Row(
            children: [
              for (final k in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: AspectRatio(
                      aspectRatio: 1.45,
                      child: FilledButton(
                        onPressed: () => press(k),
                        style: FilledButton.styleFrom(
                          backgroundColor: k == '='
                              ? _kNavy
                              : k == 'C' || k == 'DEL'
                              ? _kAmberDark.withValues(alpha: 0.10)
                              : ops.contains(k)
                              ? _kCyanPill
                              : _kCard,
                          foregroundColor: k == '='
                              ? Star.onAccent
                              : k == 'C' || k == 'DEL'
                              ? _kAmberDark
                              : _kNavy,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: k == '='
                                  ? _kNavy
                                  : k == 'C' || k == 'DEL'
                                  ? _kAmberDark.withValues(alpha: 0.22)
                                  : _kBorder,
                            ),
                          ),
                        ),
                        child: Text(
                          k,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: k == 'DEL' ? 12 : 16,
                            fontWeight: FontWeight.w600,
                          ),
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
}

class _TxnInput extends StatefulWidget {
  const _TxnInput();
  @override
  State<_TxnInput> createState() => _TxnInputState();
}

class _TxnInputState extends State<_TxnInput> {
  final h = TextEditingController(text: '1');
  final ket = TextEditingController();
  final jml = TextEditingController();
  String kat = 'protein';
  bool isMasuk = false;
  void add() {
    final dim = AppState.I.daysInSelMonth();
    final hj = int.tryParse(h.text) ?? 1;
    final jv = int.tryParse(jml.text.replaceAll('.', ''));
    if (jv == null || jv <= 0 || hj < 1 || hj > dim) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi hari 1-$dim dan jumlah Rp yang benar')),
      );
      return;
    }
    if (jv > 1000000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal maksimal Rp 1.000.000.000')),
      );
      return;
    }
    final cleanKet = ket.text.trim().isEmpty
        ? (isMasuk ? 'pemasukan' : 'belanja')
        : (ket.text.trim().length > 60
              ? ket.text.trim().substring(0, 60)
              : ket.text.trim());
    AppState.I.addTxn(cleanKet, jv, hari: hj, kat: isMasuk ? 'masuk' : kat);
    ket.clear();
    jml.clear();
  }

  @override
  Widget build(BuildContext context) {
    final dim = AppState.I.daysInSelMonth();
    InputDecoration deco(String label, {String? prefix, String? hint}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: _kCanvas,
        labelStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          color: _kSlate,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          color: _kSlate,
        ),
        prefixStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          color: _kSlate,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kNavyFill, width: 1.4),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Segmented control: dua pilihan besar, tanpa warna tambahan.
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: isMasuk ? 1 : 0,
            backgroundColor: _kCanvas,
            thumbColor: Star.surface,
            padding: const EdgeInsets.all(4),
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Keluar',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kNavy,
                  ),
                ),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Masuk',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kNavy,
                  ),
                ),
              ),
            },
            onValueChanged: (v) => setState(() => isMasuk = (v ?? 0) == 1),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: TextField(
                controller: h,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: deco('Hari', hint: '1-$dim'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: jml,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: deco('Jumlah Rp', prefix: 'Rp '),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: ket,
          decoration: deco('Keterangan', hint: 'Mis. belanja pasar'),
        ),
        if (!isMasuk) ...[
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: kat,
            items: const [
              DropdownMenuItem(value: 'protein', child: Text('Protein')),
              DropdownMenuItem(value: 'sayur', child: Text('Sayur')),
              DropdownMenuItem(value: 'beras', child: Text('Beras')),
              DropdownMenuItem(value: 'lain', child: Text('Lainnya')),
            ],
            onChanged: (v) => setState(() => kat = v ?? 'protein'),
            decoration: deco('Kategori'),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton.icon(
            onPressed: add,
            style: FilledButton.styleFrom(
              backgroundColor: _kNavyFill,
              foregroundColor: Star.onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(isMasuk ? 'Simpan pemasukan' : 'Simpan pengeluaran'),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tersimpan otomatis di perangkat ini.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10.5,
            color: _kSlate,
          ),
        ),
      ],
    );
  }
}

class _TxnTable extends StatelessWidget {
  final AppState st;
  const _TxnTable(this.st);

  @override
  Widget build(BuildContext context) {
    final rows = st.txnsSel;
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 26, color: _kSlate),
            SizedBox(height: 8),
            Text(
              'Belum ada data bulan ini — catat belanja harianmu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                height: 1.45,
                color: _kSlate,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          _row(rows[i]),
          if (i != rows.length - 1) const Divider(height: 1, color: _kBorder),
        ],
      ],
    );
  }

  Widget _row(Txn t) {
    final masuk = t.kat == 'masuk';
    final accent = masuk ? _kNavy : _kAmberDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: Neu.raised(r: 10, d: 3),
            child: Icon(
              masuk ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 15,
              color: accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.ket,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Hari ${t.hari} · ${t.kat}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    color: _kSlate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${masuk ? '+' : '−'}${rp(t.jml)}',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: () => st.delTxn(t.id),
            icon: const Icon(Icons.close_rounded, size: 15),
            color: _kSlate,
            tooltip: 'Hapus transaksi',
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _DayGrid extends StatelessWidget {
  const _DayGrid();

  @override
  Widget build(BuildContext context) {
    final st = AppState.I;
    final dim = st.daysInSelMonth();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _KSectionHead(
          eyebrow: 'Ritme harian',
          title: 'Sisa per hari',
          subtitle: 'Jatah Rp25.000 per tanggal · geser untuk melihat semua.',
          trailing: _KTag('Rp25 rb'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: dim,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (_, i) => _day(i + 1, st),
          ),
        ),
        const SizedBox(height: 12),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(top: 2, bottom: 4),
            iconColor: _kNavy,
            collapsedIconColor: _kSlate,
            title: const Text(
              'Grafik & tren 30 hari',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _kNavy,
              ),
            ),
            subtitle: const Text(
              'Batang amber = pengeluaran lewat jatah.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10.5,
                color: _kSlate,
              ),
            ),
            children: const [_Chart(), SizedBox(height: 10), _TrendLine()],
          ),
        ),
      ],
    );
  }

  Widget _day(int h, AppState st) {
    final out = st.txnByDay(h);
    final over = out > 25000;
    final today =
        DateTime.now().day == h &&
        st.calMonth == DateTime.now().month &&
        st.calYear == DateTime.now().year;
    final accent = over ? _kAmberDark : _kNavy;
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: today ? _kCyanPill : _kCanvas,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: today
              ? _kNavyFill
              : over
              ? _kAmberDark.withValues(alpha: 0.55)
              : _kBorder,
          width: today ? 1.4 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'H$h',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: _kSlate,
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              rp(out).replaceAll('Rp', ''),
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: out == 0 ? _kSlate : accent,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KTag extends StatelessWidget {
  final String text;
  const _KTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: Neu.raised(r: 999, d: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: _kSlate,
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart();
  @override
  Widget build(BuildContext context) {
    final st = AppState.I;
    return SizedBox(
      height: 84,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var h = 1; h <= st.daysInSelMonth(); h++)
            _bar(st.txnByDay(h), h),
        ],
      ),
    );
  }

  Widget _bar(int out, int h) {
    final hh = (out / 25000).clamp(0.0, 1.0);
    final color = out > 25000
        ? _kAmberDark
        : out > 0
        ? _kNavy
        : _kBorder;
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Tooltip(
          message: 'H$h: ${rp(out)}',
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 6 + 70 * hh,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendLine extends StatelessWidget {
  const _TrendLine();
  @override
  Widget build(BuildContext context) {
    final st = AppState.I;
    final dim = st.daysInSelMonth();
    var peak = 25000;
    final spots = <FlSpot>[];
    for (var h = 1; h <= dim; h++) {
      final out = st.txnByDay(h);
      if (out > peak) peak = out;
      spots.add(FlSpot(h.toDouble(), out.toDouble()));
    }
    final maxY = peak * 1.2;
    final step = maxY / 4;
    return Container(
      height: 210,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 12, 12, 8),
      decoration: Neu.raised(r: 12, d: 3),
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: dim.toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: step,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: _kBorder, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 25000,
                color: _kAmberDark,
                strokeWidth: 1.3,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 4, bottom: 4),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: _kAmberDark,
                  ),
                  labelResolver: (_) => 'jatah 25rb',
                ),
              ),
            ],
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 4,
                reservedSize: 24,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    'H${v.toInt()}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: _kSlate,
                    ),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: step,
                reservedSize: 34,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${(v / 1000).round()}rb',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: _kSlate,
                    ),
                  ),
                ),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) => touched
                  .map(
                    (s) => LineTooltipItem(
                      'H${s.x.toInt()}: ${rp(s.y.toInt())}',
                      const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Star.onAccent,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: _kNavy,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: _kNavy.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kalender di PALING BAWAH halaman Uang: tap tanggal -> ringkasan
/// pemasukan & pengeluaran + 3 opsional (paket, catatan menu, booster).
class _MoneyCalendar extends StatelessWidget {
  const _MoneyCalendar();
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (_, _) {
        final st = AppState.I;
        final dim = st.daysInSelMonth();
        final blanks = DateTime(st.calYear, st.calMonth, 1).weekday - 1;
        final now = DateTime.now();
        final isThis = st.calYear == now.year && st.calMonth == now.month;
        return _KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _KSectionHead(
                eyebrow: 'Kalender',
                title: 'Kalender Uang',
                subtitle:
                    'Tap tanggal untuk lihat pemasukan & pengeluaran hari itu.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _navButton(
                    Icons.chevron_left_rounded,
                    'Bulan lalu',
                    () => st.goMonth(st.calYear, st.calMonth - 1),
                  ),
                  Expanded(
                    child: Text(
                      '${BULAN_ID[st.calMonth]} ${st.calYear}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                  ),
                  _navButton(
                    Icons.chevron_right_rounded,
                    'Bulan depan',
                    () => st.goMonth(st.calYear, st.calMonth + 1),
                  ),
                  const SizedBox(width: 2),
                  TextButton(
                    onPressed: () => st.goToday(),
                    style: TextButton.styleFrom(
                      foregroundColor: _kNavy,
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Hari ini'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final d in const [
                    'Sen',
                    'Sel',
                    'Rab',
                    'Kam',
                    'Jum',
                    'Sab',
                    'Min',
                  ])
                    Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _kSlate,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 0.92,
                children: [
                  for (var i = 0; i < blanks; i++) const SizedBox.shrink(),
                  for (var d = 1; d <= dim; d++)
                    _MoneyDay(
                      day: d,
                      isToday: isThis && d == now.day,
                      hasIn: st.txnInByDay(d) > 0,
                      hasOut: st.txnByDay(d) > 0,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kNavyFill,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Masuk',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10.5,
                      color: _kSlate,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kAmberDark,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Keluar',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10.5,
                      color: _kSlate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navButton(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 19),
      color: _kNavy,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

class _MoneyDay extends StatelessWidget {
  final int day;
  final bool isToday, hasIn, hasOut;
  const _MoneyDay({
    required this.day,
    required this.isToday,
    required this.hasIn,
    required this.hasOut,
  });

  @override
  Widget build(BuildContext context) {
    return PopTap(
      onTap: () => showMoneyDay(context, day),
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isToday ? _kNavyFill : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: isToday ? Star.onAccent : _kNavy,
              ),
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasIn)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kNavyFill,
                    ),
                  ),
                if (hasOut)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kAmberDark,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sheet tanggal: WAJIB tampil pemasukan + pengeluaran + neto,
/// lalu 3 OPSIONAL (paket hari itu, catatan menu lain, booster).
void showMoneyDay(BuildContext context, int day) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: _kCanvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => ListenableBuilder(
        listenable: AppState.I,
        builder: (_, _) {
          final st = AppState.I;
          final inc = st.txnInByDay(day);
          final out = st.txnByDay(day);
          final bebas = day == 31;
          final k = bebas ? null : URUTAN[(day - 1) ~/ 2];
          final dayTxns = st.txnsSel.where((t) => t.hari == day).toList();
          return ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${HARI_ID[DateTime(st.calYear, st.calMonth, day).weekday]}, '
                '$day ${BULAN_ID[st.calMonth]} ${st.calYear}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.4,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 12),
              // WAJIB: ringkasan pemasukan + pengeluaran hari itu.
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: Neu.raised(r: 14, d: 4),
                child: Column(
                  children: [
                    _MoneyRow(
                      'Pemasukan',
                      '+${rp(inc)}',
                      _kNavyFill,
                      Icons.south_west_rounded,
                    ),
                    const SizedBox(height: 8),
                    _MoneyRow(
                      'Pengeluaran',
                      '−${rp(out)}',
                      _kAmberDark,
                      Icons.north_east_rounded,
                    ),
                    const Divider(height: 20, color: _kBorder),
                    _MoneyRow(
                      'Sisa hari itu',
                      rp(inc - out),
                      _kNavy,
                      Icons.account_balance_wallet_outlined,
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // CAL_DAY_INPUT: catat pemasukan/pengeluaran langsung di
              // tanggal terpilih (hari TERKUNCI, tak perlu isi manual).
              _MoneyDayInput(day: day),
              const SizedBox(height: 16),
              Text(
                'Transaksi hari ini (${dayTxns.length})',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 6),
              if (dayTxns.isEmpty)
                const Text(
                  'Belum ada — catat lewat form di atas.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    height: 1.5,
                    color: _kSlate,
                  ),
                )
              else
                for (final t in dayTxns) _DayTxnRow(t: t, st: st),
              const SizedBox(height: 14),
              // OPSIONAL 1: toggle paket makan hari itu.
              const Text(
                'Paket hari ini (opsional)',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bebas
                    ? 'Tanggal 31 = Hari Bebas (di luar template).'
                    : 'Paket ${(day - 1) ~/ 2 + 1} · ${POLA[k]!.t.replaceAll(' (otot)', '')}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  height: 1.5,
                  color: _kSlate,
                ),
              ),
              const SizedBox(height: 8),
              if (!bebas)
                for (var m = 1; m <= 3; m++)
                  _MoneyMealToggle(day: day, slot: m),
              // OPSIONAL 2: catatan menu lain di luar template (bebas >3).
              const SizedBox(height: 12),
              const Text(
                'Menu lain hari ini (opsional)',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Makanan di luar template? Catat di sini, boleh lebih dari 3.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  height: 1.5,
                  color: _kSlate,
                ),
              ),
              const SizedBox(height: 8),
              _MoneyNotes(day: day),
              // OPSIONAL 3: booster hari itu.
              const SizedBox(height: 12),
              _MoneyBooster(day: day),
            ],
          );
        },
      ),
    ),
  );
}

class _DayTxnRow extends StatelessWidget {
  final Txn t;
  final AppState st;
  const _DayTxnRow({required this.t, required this.st});

  @override
  Widget build(BuildContext context) {
    final masuk = t.kat == 'masuk';
    final accent = masuk ? _kNavy : _kAmberDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            masuk ? Icons.south_west_rounded : Icons.north_east_rounded,
            size: 15,
            color: accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.ket,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kNavy,
                  ),
                ),
                Text(
                  t.kat,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    color: _kSlate,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${masuk ? '+' : '−'}${rp(t.jml)}',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: () => st.delTxn(t.id),
            icon: const Icon(Icons.close_rounded, size: 15),
            color: _kSlate,
            tooltip: 'Hapus transaksi',
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

/// Form catat cepat di sheet tanggal (CAL_DAY_INPUT): hari TERKUNCI =
/// tanggal yang diketuk di kalender. Segmented Keluar/Masuk + keterangan
/// + jumlah + kategori (keluar saja). Pola sama seperti _TxnInput di atas.
class _MoneyDayInput extends StatefulWidget {
  final int day;
  const _MoneyDayInput({required this.day});
  @override
  State<_MoneyDayInput> createState() => _MoneyDayInputState();
}

class _MoneyDayInputState extends State<_MoneyDayInput> {
  final ket = TextEditingController();
  final jml = TextEditingController();
  String kat = 'lain';
  bool isMasuk = false;
  void add() {
    final jv = int.tryParse(jml.text.replaceAll('.', ''));
    if (jv == null || jv <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Isi jumlah Rp yang benar')));
      return;
    }
    if (jv > 1000000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal maksimal Rp 1.000.000.000')),
      );
      return;
    }
    final cleanKet = ket.text.trim().isEmpty
        ? (isMasuk ? 'pemasukan' : 'belanja')
        : (ket.text.trim().length > 60
              ? ket.text.trim().substring(0, 60)
              : ket.text.trim());
    AppState.I.addTxn(
      cleanKet,
      jv,
      hari: widget.day,
      kat: isMasuk ? 'masuk' : kat,
    );
    ket.clear();
    jml.clear();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String label, {String? prefix}) {
      return InputDecoration(
        labelText: label,
        prefixText: prefix,
        filled: true,
        fillColor: _kCanvas,
        labelStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          color: _kSlate,
        ),
        prefixStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          color: _kSlate,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kNavyFill, width: 1.4),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: Neu.raised(r: 14, d: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catat tgl ${widget.day}',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: isMasuk ? 1 : 0,
              backgroundColor: _kCanvas,
              thumbColor: Star.surface,
              padding: const EdgeInsets.all(4),
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Keluar',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kNavy,
                    ),
                  ),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kNavy,
                    ),
                  ),
                ),
              },
              onValueChanged: (v) => setState(() => isMasuk = (v ?? 0) == 1),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: ket, decoration: deco('Keterangan')),
          const SizedBox(height: 10),
          TextField(
            controller: jml,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
            decoration: deco('Jumlah Rp', prefix: 'Rp '),
          ),
          if (!isMasuk) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: kat,
              items: const [
                DropdownMenuItem(value: 'protein', child: Text('Protein')),
                DropdownMenuItem(value: 'sayur', child: Text('Sayur')),
                DropdownMenuItem(value: 'beras', child: Text('Beras')),
                DropdownMenuItem(value: 'lain', child: Text('Lainnya')),
              ],
              onChanged: (v) => setState(() => kat = v ?? 'lain'),
              decoration: deco('Kategori'),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: add,
              style: FilledButton.styleFrom(
                backgroundColor: _kNavyFill,
                foregroundColor: Star.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Simpan ke tgl ${widget.day}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  final bool bold;
  const _MoneyRow(
    this.label,
    this.value,
    this.color,
    this.icon, {
    this.bold = false,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12.5,
              color: _kNavy,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Toggle 1 slot paket (Pagi/Siang/Malam) — memakai key e{h}-{m} yang sama
/// dengan Planning/Minggu sehingga progres sinkron.
class _MoneyMealToggle extends StatelessWidget {
  final int day, slot;
  const _MoneyMealToggle({required this.day, required this.slot});
  @override
  Widget build(BuildContext context) {
    final id = 'e$day-$slot';
    final on = AppState.I.eaten[id] == true;
    const labels = ['', 'Pagi', 'Siang', 'Malam'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: PopTap(
        onTap: () => AppState.I.toggleEat(id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: on ? _kCyanPill : _kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: on ? _kNavyFill : _kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? _kAmber : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: on ? _kAmber : _kBorder,
                    width: 1.5,
                  ),
                ),
                child: on
                    ? const Icon(Icons.check_rounded, size: 14, color: _kNavy)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  labels[slot],
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _kNavy,
                  ),
                ),
              ),
              Text(
                on ? 'Tercatat' : 'Belum',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10.5,
                  color: _kSlate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Input + daftar catatan menu luar template (opsional, tanpa batas).
class _MoneyNotes extends StatefulWidget {
  final int day;
  const _MoneyNotes({required this.day});
  @override
  State<_MoneyNotes> createState() => _MoneyNotesState();
}

class _MoneyNotesState extends State<_MoneyNotes> {
  final note = TextEditingController();
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = AppState.I.notesByDay(widget.day);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: note,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: _kNavy,
                ),
                decoration: InputDecoration(
                  hintText: 'Mis. sate 5 tusuk, es teh...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.5,
                    color: _kSlate,
                  ),
                  filled: true,
                  fillColor: _kCanvas,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kNavyFill, width: 1.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: () {
                  AppState.I.addNote(widget.day, note.text);
                  note.clear();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _kNavyFill,
                  foregroundColor: Star.onAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Tambah'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (notes.isEmpty)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Belum ada catatan hari ini.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                height: 1.5,
                color: _kSlate,
              ),
            ),
          )
        else
          for (final n in notes)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
              decoration: Neu.raised(r: 10, d: 3),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_outlined,
                    size: 15,
                    color: _kSlate,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      n.text,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.5,
                        color: _kNavy,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 15),
                    color: _kSlate,
                    onPressed: () => AppState.I.delNote(n.id),
                    tooltip: 'Hapus catatan',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

/// Toggle booster harian (opsional): ON mencatat Rp10.900 ke hari itu,
/// OFF menghapusnya lagi.
class _MoneyBooster extends StatelessWidget {
  final int day;
  const _MoneyBooster({required this.day});
  @override
  Widget build(BuildContext context) {
    final on = AppState.I.hasBoosterDay(day);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: on ? _kCyanPill : _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: on ? _kNavyFill : _kBorder),
      ),
      child: Row(
        children: [
          Icon(
            on ? Icons.bolt_rounded : Icons.bolt_outlined,
            color: on ? _kCyan : _kSlate,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booster hari ini',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _kNavy,
                  ),
                ),
                Text(
                  '±1.110 kkal · Protein 33gr · ±Rp10.900',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    height: 1.45,
                    color: on ? _kNavy : _kSlate,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: on,
            activeTrackColor: _kNavy,
            onChanged: (_) => AppState.I.toggleBoosterDay(day),
          ),
        ],
      ),
    );
  }
}
