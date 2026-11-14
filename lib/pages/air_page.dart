// Air Galon Page: Hidrasi Optimal, Visual Liquid Dispenser & Analisis Finansial Galon Kost
// Self Volta - Advanced Athletic & Kost Economy Edition

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class AirPage extends StatefulWidget {
  const AirPage({super.key});

  @override
  State<AirPage> createState() => _AirPageState();
}

class _AirPageState extends State<AirPage> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  int _dailyWaterMl = 1500;
  static const int _targetWaterMl = 2500;
  int _gallonDaysLeft = 6;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _addWater(int ml, {String? label}) {
    iosTapBuzz();
    setState(() {
      _dailyWaterMl = (_dailyWaterMl + ml).clamp(0, 5000);
    });
    final now = DateTime.now();
    final waterKey = 'water_${now.year}_${now.month}_${now.day}';
    if (_dailyWaterMl >= _targetWaterMl &&
        !(AppState.I.eaten[waterKey] ?? false)) {
      AppState.I.eaten[waterKey] = true;
      AppState.I.addXp(25);
      unawaited(AppState.I.save());
      triumphBuzz();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Star.star, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Target hidrasi 2.500 ml tercapai hari ini! (+25 XP)',
                ),
              ),
            ],
          ),
          backgroundColor: Star.star,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ditambahkan +$ml ml${label != null ? ' ($label)' : ''}!',
          ),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _resetWater() {
    iosTapBuzz();
    setState(() => _dailyWaterMl = 0);
  }

  void _logNewGallon() {
    final now = DateTime.now();
    final todayStr = '${now.year}_${now.month}_${now.day}';
    final gallonKey = 'gallon_logged_$todayStr';
    final alreadyLoggedToday = AppState.I.eaten[gallonKey] == true;

    if (alreadyLoggedToday) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Star.star),
              SizedBox(width: 8),
              Text(
                'Galon Sudah Tercatat',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          content: const Text(
            'Anda sudah mencatat pengisian galon baru 19L untuk hari ini (~8 hari sisa). Tetap ingin mereset ulang status galon?',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 12.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _executeGallonRefill(gallonKey);
              },
              style: FilledButton.styleFrom(backgroundColor: Star.star),
              child: const Text('Reset Ulang'),
            ),
          ],
        ),
      );
      return;
    }

    _executeGallonRefill(gallonKey);
  }

  void _executeGallonRefill(String gallonKey) {
    triumphBuzz();
    AppState.I.eaten[gallonKey] = true;
    unawaited(AppState.I.save());
    setState(() => _gallonDaysLeft = 8);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.water_drop_rounded, color: Star.star, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Galon Baru 19L Tercatat! Saldo hidrasi diperbarui (~8 hari sisa).',
              ),
            ),
          ],
        ),
        backgroundColor: Star.star,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAirTutorial(BuildContext context) {
    showInteractiveSpotlightTutorial(
      context,
      tutorialTitle: 'Panduan Hidrasi Galon',
      steps: const [
        TutorialStepItem(
          title: 'Visual Liquid Dispenser & Target 2.5L',
          category: 'Hidrasi Atlet Harian',
          featureTag: 'Animasi Gelombang Cairan',
          description: 'Setiap teguk air penting untuk performa kalistenik. Animasi cairan dispenser naik secara dinamis seiring kamu mencatat air minum (target 2.500ml per hari).',
          tip: 'Gunakan tombol +250ml (1 Gelas) atau +600ml (Botol Tumbler) untuk mencatat hidrasi seketika.',
          icon: Icons.water_drop_rounded,
          accentColor: Star.star,
        ),
        TutorialStepItem(
          title: 'Anti-Spam Log Isi Ulang Galon 19L',
          category: 'Ekonomi Galon Kost',
          featureTag: 'Satu Klaim per Hari',
          description: 'Mencatat tanggal isi ulang galon baru 19L. Dilengkapi proteksi anti-spam sehingga saldo galon tidak bisa digandakan berkali-kali dalam satu hari.',
          tip: 'Satu galon 19L rata-rata mencukupi kebutuhan 7-8 hari untuk satu anak kost.',
          icon: Icons.inventory_2_rounded,
          accentColor: Star.star,
        ),
        TutorialStepItem(
          title: 'Checklist Sirkadian 8 Waktu Minum',
          category: 'Ritme Biologis Tubuh',
          featureTag: 'Waktu Minum Terjadwal',
          description: 'Minum air terbagi ke dalam 8 momen penting: bangun tidur, sebelum sarapan, jam kerja fokus, pra-workout, pasca-latihan, hingga menjelang tidur.',
          tip: 'Minum segelas air hangat saat bangun pagi langsung mengaktifkan metabolisme dan melumasi persendian tubuh.',
          icon: Icons.schedule_rounded,
          accentColor: Star.success,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_dailyWaterMl / _targetWaterMl).clamp(0.0, 1.0);
    final int percent = (progress * 100).round();

    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Star.bg,
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
            children: [
              // Top Bar Header & Tutorial Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        color: Star.star,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Hidrasi Galon Kost',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Star.ink,
                        ),
                      ),
                    ],
                  ),
                  TutorialPillButton(
                    onTap: () => _showAirTutorial(context),
                    label: 'Panduan',
                    color: Star.star,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --------------------------------------------------------------
              // 1. HERO ANIMATED WATER DISPENSER & LIQUID CYLINDER
              // --------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(18),
                decoration: Neu.raised(r: 22, d: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Star.ink.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.water_drop_rounded,
                                  size: 14,
                                  color: Star.star,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Hidrasi Harian Atlet Kost',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Star.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _resetWater,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Star.ink.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Reset Hari Ini',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Star.mut,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Liquid Dispenser & Stats Row
                    Row(
                      children: [
                        // Visual Animated Wave Water Bottle / Cylinder
                        Container(
                          width: 84,
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Star.ink.withValues(alpha: 0.07),
                              width: 2,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Star.ink.withValues(alpha: 0.07),
                                Star.ink.withValues(alpha: 0.07),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Star.star.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, _) {
                                return CustomPaint(
                                  painter: _LiquidWavePainter(
                                    progress: progress,
                                    wavePhase: _waveController.value * 2 * pi,
                                    waveColor: Star.star,
                                    highlightColor: Star.star,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.water_drop_rounded,
                                          color: Star.ink,
                                          size: 20,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$percent%',
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Star.ink,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black45,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Stats & Motivational Metrics
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${(_dailyWaterMl / 1000).toStringAsFixed(1)}L',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 34,
                                        fontWeight: FontWeight.w700,
                                        color: Star.ink,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Flexible(
                                    child: Text(
                                      '/ 2.5L Target',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Star.mut,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: percent >= 100
                                      ? Star.success.withValues(alpha: 0.25)
                                      : Star.star.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: percent >= 100
                                        ? Star.success
                                        : Star.star,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  percent >= 100
                                      ? 'Target Tercapai! Tubuh Prima'
                                      : 'Kurang ${((_targetWaterMl - _dailyWaterMl) / 1000).clamp(0.0, 2.5).toStringAsFixed(1)}L lagi',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: percent >= 100
                                        ? Star.success
                                        : Paper.amberInk,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Otot mengandung 75% air. Hidrasi optimal menjaga kekuatan repetisi push-up dan mencegah nyeri sendi.',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Star.mut,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 4 Quick Log Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _quickAddBtn(
                            ml: 250,
                            label: '+250ml',
                            sub: 'Gelas Kos',
                            icon: Icons.local_drink_rounded,
                            accentColor: Star.star,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickAddBtn(
                            ml: 600,
                            label: '+600ml',
                            sub: 'Tumbler',
                            icon: Icons.sports_gymnastics_rounded,
                            accentColor: Star.star,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickAddBtn(
                            ml: 1000,
                            label: '+1.000ml',
                            sub: 'Botol 1L',
                            icon: Icons.bolt_rounded,
                            accentColor: Star.star,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --------------------------------------------------------------
              // 2. STATUS SALDO GALON KOST (19 LITER) & TRACKER ISI ULANG
              // --------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: Neu.raised(r: 20, d: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Star.star.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.propane_tank_rounded,
                            color: Star.star,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Status Galon Kost',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Star.ink,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Star.star.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sisa ~$_gallonDaysLeft Hari',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Star.star,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Satu galon isi ulang 19L mencukupi kebutuhan hidrasi atlet kost selama 7-8 hari penuh.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: Star.mut,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Builder(
                        builder: (context) {
                          final now = DateTime.now();
                          final todayStr =
                              '${now.year}_${now.month}_${now.day}';
                          final gallonKey = 'gallon_logged_$todayStr';
                          final bool alreadyLoggedToday =
                              AppState.I.eaten[gallonKey] == true;

                          return FilledButton.tonalIcon(
                            onPressed: _logNewGallon,
                            icon: Icon(
                              alreadyLoggedToday
                                  ? Icons.check_circle_rounded
                                  : Icons.refresh_rounded,
                              size: 16,
                            ),
                            label: Text(
                              alreadyLoggedToday
                                  ? '✓ Galon Sudah Diisi Hari Ini'
                                  : 'Beli / Isi Ulang Galon Baru (+19L)',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: alreadyLoggedToday
                                  ? Star.success.withValues(alpha: 0.15)
                                  : Star.star.withValues(alpha: 0.12),
                              foregroundColor: alreadyLoggedToday
                                  ? Star.success
                                  : Star.star,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --------------------------------------------------------------
              // 3. ANALISIS EKONOMI GALON KOST (HEMAT HINGGA RP 180.000/BULAN)
              // --------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: Neu.raised(r: 20, d: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.savings_rounded, color: Star.star, size: 18),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Analisis Finansial Galon Kost vs Botolan',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Star.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Perbandingan pengeluaran riil per bulan untuk kebutuhan hidrasi 75 liter (2,5L/hari):',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: Star.mut,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _costComparisonRow(
                      type: 'Isi Ulang Galon Kost',
                      formula: '4 Galon x Rp 5.000',
                      cost: 'Rp 20.000 / bln',
                      desc: 'Rp 260 per liter (Sangat Hemat)',
                      isWinner: true,
                    ),
                    const SizedBox(height: 8),
                    _costComparisonRow(
                      type: 'Beli Botol Mineral 600ml',
                      formula: '125 Botol x Rp 3.500',
                      cost: 'Rp 437.500 / bln',
                      desc: 'Rp 5.830 per liter (Pemborosan)',
                      isWinner: false,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Star.star.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Star.star,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hemat Rp 417.500/bulan! Cukup untuk 8 papan telur (240 butir protein).',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                height: 1.45,
                                color: Star.star,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --------------------------------------------------------------
              // 4. JADWAL HIDRASI SIRKADIAN (WAKTU MINUM TERBAIK)
              // --------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: Neu.raised(r: 20, d: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: Star.star,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Jadwal Hidrasi Optimal Atlet',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Star.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _timelineTile(
                      '05:00',
                      'Subuh / Bangun Tidur (500 ml)',
                      'Bilas asam lambung & rehidrasi setelah 8 jam puasa tidur.',
                      'subuh',
                    ),
                    _timelineTile(
                      '07:30',
                      'Sebelum Latihan Kalistenik (400 ml)',
                      'Cegah dehidrasi sel otot & kram saat repetisi berat.',
                      'pra_workout',
                    ),
                    _timelineTile(
                      '12:30',
                      'Makan Siang & Siang Hari (600 ml)',
                      'Bantu enzim pencernaan mencerna protein makanan.',
                      'siang',
                    ),
                    _timelineTile(
                      '17:00',
                      'Sore Hari / Pasca-Aktivitas (500 ml)',
                      'Mengganti cairan keringat sore & lancarkan peredaran darah.',
                      'sore',
                    ),
                    _timelineTile(
                      '21:00',
                      'Sebelum Tidur Malam (500 ml)',
                      'Mendukung sintesis pemulihan jaringan otot saat istirahat.',
                      'malam',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickAddBtn({
    required int ml,
    required String label,
    required String sub,
    required IconData icon,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: () => _addWater(ml, label: sub),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: Star.ink.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Star.line.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Star.ink,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                color: Star.mut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _costComparisonRow({
    required String type,
    required String formula,
    required String cost,
    required String desc,
    required bool isWinner,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isWinner ? Star.star.withValues(alpha: 0.08) : Star.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? Star.star.withValues(alpha: 0.3) : Star.sunken,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isWinner ? Star.star : Star.ink,
                  ),
                ),
                Text(
                  '$formula • $desc',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 9.5,
                    color: Star.mut,
                  ),
                ),
              ],
            ),
          ),
          Text(
            cost,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isWinner ? Star.star : Star.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineTile(String time, String title, String desc, String key) {
    final now = DateTime.now();
    final todayStr = '${now.year}_${now.month}_${now.day}';
    final storageKey = 'water_timeline_${key}_$todayStr';
    final bool checked = AppState.I.eaten[storageKey] == true;

    return InkWell(
      onTap: () {
        iosTapBuzz();
        final nextVal = !checked;
        AppState.I.eaten[storageKey] = nextVal;
        unawaited(AppState.I.save());
        setState(() {});
        if (nextVal) {
          AppState.I.addXp(5);
          triumphBuzz();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title selesai diminum! (+5 XP)'),
              duration: const Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Star.star,
            ),
          );
        } else {
          AppState.I.removeXp(5);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Jadwal $title dibatalkan (-5 XP)'),
              duration: const Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              checked
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: checked ? Star.success : Star.mut,
              size: 18,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (checked ? Star.success : Star.star).withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: checked ? Star.success : Star.star,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: checked ? Star.success : Star.ink,
                            decoration: checked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (checked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: Star.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Sudah Minum ✓',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: Star.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: Star.ink.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// CUSTOM PAINTER: LIQUID WAVE DYNAMICS (ANTI-LAG 60-120 FPS)
// ----------------------------------------------------------------------------
class _LiquidWavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final Color waveColor;
  final Color highlightColor;

  _LiquidWavePainter({
    required this.progress,
    required this.wavePhase,
    required this.waveColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final fillHeight = size.height * progress;
    final waveBaseY = size.height - fillHeight;
    const waveAmplitude = 4.0;

    final path = Path();
    path.moveTo(0, waveBaseY);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveBaseY +
          sin((x / size.width * 2 * pi) + wavePhase) * waveAmplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [highlightColor, waveColor],
          ).createShader(
            Rect.fromLTWH(
              0,
              waveBaseY - waveAmplitude,
              size.width,
              fillHeight + waveAmplitude,
            ),
          );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase;
  }
}
