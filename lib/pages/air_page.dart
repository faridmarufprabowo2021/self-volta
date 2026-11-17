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
    final prevMl = _dailyWaterMl;
    setState(() {
      _dailyWaterMl = (_dailyWaterMl + ml).clamp(0, 5000);
    });
    final delta = _dailyWaterMl - prevMl;
    if (delta == 0 && ml != 0) return;
    final now = DateTime.now();
    final waterKey = 'water_${now.year}_${now.month}_${now.day}';

    if (_dailyWaterMl >= _targetWaterMl &&
        !(AppState.I.eaten[waterKey] ?? false)) {
      AppState.I.eaten[waterKey] = true;
      AppState.I.addXp(25);
      unawaited(AppState.I.save());
      triumphBuzz();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Star.onAccent, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Target hidrasi 2.500 ml tercapai hari ini! (+25 XP)',
                ),
              ),
            ],
          ),
          backgroundColor: Star.water,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'BATALKAN',
            textColor: Colors.white,
            onPressed: () => _addWater(-delta, label: 'Batal'),
          ),
        ),
      );
    } else {
      if (_dailyWaterMl < _targetWaterMl &&
          (AppState.I.eaten[waterKey] ?? false)) {
        AppState.I.eaten[waterKey] = false;
        unawaited(AppState.I.save());
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      final isAdd = delta > 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAdd
                ? 'Ditambahkan +$delta ml${label != null ? ' ($label)' : ''}!'
                : 'Dikurangi ${delta.abs()} ml${label != null ? ' ($label)' : ''}!',
          ),
          duration: const Duration(milliseconds: 2200),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'BATALKAN',
            textColor: Star.star,
            onPressed: () => _addWater(-delta, label: 'Batal'),
          ),
        ),
      );
    }
  }

  void _setWater(int exactMl) {
    final diff = exactMl - _dailyWaterMl;
    _addWater(diff, label: 'Atur Total');
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
              Icon(Icons.info_outline_rounded, color: Star.water),
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
              style: FilledButton.styleFrom(backgroundColor: Star.water),
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
            Icon(Icons.water_drop_rounded, color: Star.onAccent, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Galon Baru 19L Tercatat! Saldo hidrasi diperbarui (~8 hari sisa).',
              ),
            ),
          ],
        ),
        backgroundColor: Star.water,
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
          accentColor: Star.water,
        ),
        TutorialStepItem(
          title: 'Anti-Spam Log Isi Ulang Galon 19L',
          category: 'Ekonomi Galon Kost',
          featureTag: 'Satu Klaim per Hari',
          description: 'Mencatat tanggal isi ulang galon baru 19L. Dilengkapi proteksi anti-spam sehingga saldo galon tidak bisa digandakan berkali-kali dalam satu hari.',
          tip: 'Satu galon 19L rata-rata mencukupi kebutuhan 7-8 hari untuk satu anak kost.',
          icon: Icons.inventory_2_rounded,
          accentColor: Star.water,
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
                  Icon(Icons.water_drop_rounded, color: Star.water, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hidrasi Galon Kost',
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  TutorialPillButton(
                    onTap: () => _showAirTutorial(context),
                    label: 'Panduan',
                    color: Star.water,
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
                                  color: Star.water,
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
                              color: const Color(0xFFA5F3FC),
                              width: 2,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Star.waterSoft, Star.waterSoft],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Star.water.withValues(alpha: 0.12),
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
                                    waveColor: Star.water,
                                    highlightColor: Star.water,
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
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: progress >= 0.35
                                                ? Star.onAccent
                                                : Star.ink,
                                            shadows: progress >= 0.35
                                                ? null
                                                : const [
                                                    Shadow(
                                                      color: Colors.black26,
                                                      blurRadius: 2,
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
                                      : Star.water.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: percent >= 100
                                        ? Star.success
                                        : Star.water,
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
                                        : Star.water,
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
                              const SizedBox(height: 10),
                              SegmentTrack(
                                count: 10,
                                active: (progress * 10).round().clamp(0, 10),
                                color: Star.water,
                                gap: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Quick Log Buttons (Baris 1: Tambah)
                    Row(
                      children: [
                        Expanded(
                          child: _quickAddBtn(
                            ml: 250,
                            label: '+250ml',
                            sub: 'Gelas Kos',
                            icon: Icons.local_drink_rounded,
                            accentColor: Star.water,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickAddBtn(
                            ml: 600,
                            label: '+600ml',
                            sub: 'Tumbler',
                            icon: Icons.sports_gymnastics_rounded,
                            accentColor: Star.water,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickAddBtn(
                            ml: 1000,
                            label: '+1.000ml',
                            sub: 'Botol 1L',
                            icon: Icons.bolt_rounded,
                            accentColor: Star.water,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quick Log Buttons (Baris 2: Kurangi / Undo & Kustom)
                    Row(
                      children: [
                        Expanded(
                          child: _quickSubBtn(
                            ml: 250,
                            label: '-250ml',
                            sub: 'Undo Gelas',
                            icon: Icons.remove_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickSubBtn(
                            ml: 600,
                            label: '-600ml',
                            sub: 'Undo Tumbler',
                            icon: Icons.remove_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _customWaterBtn(),
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
                            color: Star.water.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.propane_tank_rounded,
                            color: Star.water,
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
                            color: Star.water.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sisa ~$_gallonDaysLeft Hari',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Star.water,
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
                                  : Star.water.withValues(alpha: 0.12),
                              foregroundColor: alreadyLoggedToday
                                  ? Star.success
                                  : Star.water,
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
                        Icon(
                          Icons.savings_rounded,
                          color: Star.water,
                          size: 18,
                        ),
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
                        color: Star.water.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Star.water,
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
                                color: Star.water,
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
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Star.water,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Jadwal Hidrasi Optimal Atlet',
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

  Widget _quickSubBtn({
    required int ml,
    required String label,
    required String sub,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _addWater(-ml, label: sub),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2).withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFDC2626), size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF991B1B),
              ),
            ),
            Text(
              sub,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                color: Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customWaterBtn() {
    return InkWell(
      onTap: _showCustomWaterSheet,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Star.water.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Star.water.withValues(alpha: 0.35)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, color: Star.water, size: 18),
            SizedBox(height: 4),
            Text(
              'Kustom ±',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Star.water,
              ),
            ),
            Text(
              'Atur Sendiri',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: Star.water,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomWaterSheet() {
    iosTapBuzz();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CustomWaterSheet(
        currentMl: _dailyWaterMl,
        targetMl: _targetWaterMl,
        onApplyDelta: (delta, label) => _addWater(delta, label: label),
        onApplyExact: (exact) => _setWater(exact),
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
        color: isWinner ? Star.water.withValues(alpha: 0.08) : Star.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? Star.water.withValues(alpha: 0.3) : Star.sunken,
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
                    color: isWinner ? Star.water : Star.ink,
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
              color: isWinner ? Star.water : Star.error,
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
              backgroundColor: Star.water,
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
                color: (checked ? Star.success : Star.water).withValues(
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
                  color: checked ? Star.success : Star.water,
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

// -----------------------------------------------------------------------------
// CUSTOM WATER ADJUSTMENT SHEET
// -----------------------------------------------------------------------------
class _CustomWaterSheet extends StatefulWidget {
  final int currentMl;
  final int targetMl;
  final void Function(int delta, String label) onApplyDelta;
  final void Function(int exact) onApplyExact;

  const _CustomWaterSheet({
    required this.currentMl,
    required this.targetMl,
    required this.onApplyDelta,
    required this.onApplyExact,
  });

  @override
  State<_CustomWaterSheet> createState() => _CustomWaterSheetState();
}

class _CustomWaterSheetState extends State<_CustomWaterSheet> {
  int _mode = 0; // 0: Tambah (+), 1: Kurangi (-), 2: Set Total (=)
  late final TextEditingController _inputController;
  int _amount = 250;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: '250');
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final parsed = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    setState(() => _amount = parsed);
  }

  void _selectPreset(int val) {
    iosTapBuzz();
    setState(() {
      _amount = val;
      _inputController.text = val.toString();
    });
  }

  int get _calculatedNewTotal {
    switch (_mode) {
      case 0:
        return (widget.currentMl + _amount).clamp(0, 5000);
      case 1:
        return (widget.currentMl - _amount).clamp(0, 5000);
      case 2:
        return _amount.clamp(0, 5000);
      default:
        return widget.currentMl;
    }
  }

  void _submit() {
    iosTapBuzz();
    Navigator.of(context).pop();
    if (_mode == 0) {
      widget.onApplyDelta(_amount, 'Kustom +${_amount}ml');
    } else if (_mode == 1) {
      widget.onApplyDelta(-_amount, 'Kustom -${_amount}ml');
    } else {
      widget.onApplyExact(_amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final newTotal = _calculatedNewTotal;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Star.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Star.sunken,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Star.water.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Star.water,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atur Catatan Hidrasi',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Star.ink,
                      ),
                    ),
                    Text(
                      'Tambah, kurangi, atau ubah total jika salah pencet.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10.5,
                        color: Star.mut,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20, color: Star.mut),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Current Water Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Star.sunken,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Catatan saat ini:',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: Star.mut,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.currentMl} ml / ${widget.targetMl} ml',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Star.water,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Mode Selector (Tambah, Kurangi, Set Total)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Star.sunken,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _modePill(
                    index: 0,
                    label: '+ Tambah',
                    activeColor: Star.water,
                  ),
                ),
                Expanded(
                  child: _modePill(
                    index: 1,
                    label: '- Kurangi',
                    activeColor: const Color(0xFFDC2626),
                  ),
                ),
                Expanded(
                  child: _modePill(
                    index: 2,
                    label: '= Set Total',
                    activeColor: Star.star,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Input field
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            onChanged: _onAmountChanged,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Star.ink,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Star.surface,
              labelText: _mode == 2 ? 'Total Hidrasi Hari Ini' : 'Jumlah Air',
              suffixText: 'ml',
              suffixStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Star.mut,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Star.lineSoft),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Star.lineSoft),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _mode == 1 ? const Color(0xFFDC2626) : Star.water,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Preset Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (_mode == 0) ...[
                _presetChip(100, '+100 ml'),
                _presetChip(200, '+200 ml'),
                _presetChip(300, '+300 ml'),
                _presetChip(500, '+500 ml'),
              ] else if (_mode == 1) ...[
                _presetChip(100, '-100 ml'),
                _presetChip(200, '-200 ml'),
                _presetChip(250, '-250 ml'),
                _presetChip(500, '-500 ml'),
              ] else ...[
                _presetChip(1000, '1.000 ml'),
                _presetChip(1500, '1.500 ml'),
                _presetChip(2000, '2.000 ml'),
                _presetChip(2500, '2.500 ml'),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Live Result Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _mode == 1
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _mode == 1
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFBBF7D0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hasil setelah perubahan:',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _mode == 1
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF166534),
                  ),
                ),
                Text(
                  '$newTotal ml',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _mode == 1
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _amount > 0 || _mode == 2 ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor:
                    _mode == 1 ? const Color(0xFFDC2626) : Star.water,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _mode == 0
                    ? 'Tambahkan $_amount ml'
                    : (_mode == 1
                        ? 'Kurangi $_amount ml'
                        : 'Set Total Menjadi $_amount ml'),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modePill({
    required int index,
    required String label,
    required Color activeColor,
  }) {
    final active = _mode == index;
    return InkWell(
      onTap: () {
        iosTapBuzz();
        setState(() {
          _mode = index;
          if (index == 2) {
            _amount = widget.currentMl;
            _inputController.text = _amount.toString();
          } else if (_amount == 0 || _amount > 1000) {
            _amount = 250;
            _inputController.text = '250';
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? activeColor : Star.mut,
            ),
          ),
        ),
      ),
    );
  }

  Widget _presetChip(int val, String label) {
    final selected = _amount == val;
    return InkWell(
      onTap: () => _selectPreset(val),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Star.water.withValues(alpha: 0.15) : Star.sunken,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Star.water : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? Star.water : Star.ink,
          ),
        ),
      ),
    );
  }
}
