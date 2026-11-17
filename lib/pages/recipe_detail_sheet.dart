// Recipe Detail Sheet: Panduan Masak Urut & Sistematis dari Beranda
// Self Volta - Advanced Athletic Edition (Hero Image, Live Timer, Interactive Steps)

import 'dart:async';
import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class RecipeDetailSheet extends StatefulWidget {
  final String polaKey;
  final Pola pola;
  final Macro? macro;

  const RecipeDetailSheet({
    super.key,
    required this.polaKey,
    required this.pola,
    this.macro,
  });

  @override
  State<RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<RecipeDetailSheet> {
  int _activeTab = 0; // 0: Langkah Masak, 1: Bahan & Belanja, 2: Nutrisi

  // Live Cooking Timer State
  Timer? _timer;
  int _timerSeconds = 0;
  int _timerTotalSeconds = 900; // 15 menit default
  bool _isTimerRunning = false;
  bool _isTimerFinished = false;

  // Checklist belanja
  final Set<int> _checkedIngredients = {};

  int get _cookingMinutes {
    final match =
        RegExp(r'(\d+)\s*(?:mnt|menit)', caseSensitive: false)
            .firstMatch(widget.pola.cara);
    if (match != null) {
      final parsed = int.tryParse(match.group(1) ?? '');
      if (parsed != null && parsed >= 5 && parsed <= 45) return parsed;
    }
    return 15;
  }

  @override
  void initState() {
    super.initState();
    _timerTotalSeconds = _cookingMinutes * 60;
    _timerSeconds = _timerTotalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer([int? totalSec]) {
    iosTapBuzz();
    if (totalSec != null) {
      _timerTotalSeconds = totalSec;
      _timerSeconds = totalSec;
    }
    _timer?.cancel();
    setState(() {
      _isTimerRunning = true;
      _isTimerFinished = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_timerSeconds > 1) {
        setState(() => _timerSeconds--);
      } else {
        t.cancel();
        setState(() {
          _timerSeconds = 0;
          _isTimerRunning = false;
          _isTimerFinished = true;
        });
        triumphBuzz();
      }
    });
  }

  void _pauseTimer() {
    iosTapBuzz();
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resetTimer() {
    iosTapBuzz();
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _isTimerFinished = false;
      _timerTotalSeconds = _cookingMinutes * 60;
      _timerSeconds = _timerTotalSeconds;
    });
  }

  void _addTimerMinute(int minutes) {
    iosTapBuzz();
    setState(() {
      _timerSeconds += minutes * 60;
      if (_timerSeconds > _timerTotalSeconds) {
        _timerTotalSeconds = _timerSeconds;
      }
    });
  }

  String _formatTimer(int totalSec) {
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _cleanTitle(String raw) {
    var t = raw;
    final pipe = t.indexOf('|');
    if (pipe >= 0 && pipe < t.length - 1) {
      t = t.substring(pipe + 1).trim();
    }
    t = t.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
    return t.isEmpty ? raw : t;
  }

  String _formatRupiah(int val) {
    final s = val.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join();
  }

  List<String> _parseIngredients(String raw) {
    if (raw.trim().isEmpty) return [];
    return raw
        .split('+')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = _cleanTitle(widget.pola.t);
    final macro = widget.macro;
    final kcal = macro?.k ?? 630;
    final protein = macro?.p ?? 58;
    final waktu = _cookingMinutes;
    final budget = widget.pola.b;
    final packageKey = widget.polaKey.toUpperCase();
    final imageAsset = 'assets/images/paket_${widget.polaKey.toLowerCase()}.png';

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Star.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Column(
          children: [
            // Handle bar drag indicator
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Star.sunken,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // 1. HERO BANNER WITH FOOD ILLUSTRATION
                  _buildHeroHeader(imageAsset, packageKey),

                  // 2. RECIPE SUMMARY & METRICS
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category pill
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: Star.star.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'MENU HARI INI • PAKET $packageKey',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                  color: Star.star,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: Star.workoutSoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Rp${_formatRupiah(budget)}',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.2,
                            color: Star.ink,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'Menu tinggi protein hemat anak kost. Praktis dieksekusi dalam $waktu menit dengan alat kost tanpa ribet.',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            height: 1.45,
                            color: Star.mut,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Metric Badges (Waktu, Protein, Kalori, Budget)
                        Row(
                          children: [
                            Expanded(
                              child: _metricBadge(
                                icon: Icons.timer_outlined,
                                label: '$waktu mnt',
                                sub: 'Waktu',
                                accent: Star.star,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _metricBadge(
                                icon: Icons.fitness_center_rounded,
                                label: '${protein}g',
                                sub: 'Protein',
                                accent: const Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _metricBadge(
                                icon: Icons.local_fire_department_rounded,
                                label: '$kcal',
                                sub: 'Kalori',
                                accent: const Color(0xFFE11D48),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _metricBadge(
                                icon: Icons.payments_outlined,
                                label: 'Rp${(budget / 1000).toStringAsFixed(0)}k',
                                sub: 'Budget',
                                accent: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 3. ACTION BUTTON: MULAI MEMASAK / LIVE TIMER
                        _buildCookingTimerSection(waktu),
                        const SizedBox(height: 18),

                        // 4. SEGMENTED TABS: [ Langkah Masak ] [ Bahan & Belanja ] [ Nutrisi ]
                        _buildSegmentedTabs(),
                        const SizedBox(height: 14),

                        // 5. TAB CONTENT
                        if (_activeTab == 0)
                          _buildCookingStepsTab()
                        else if (_activeTab == 1)
                          _buildIngredientsTab(budget)
                        else
                          _buildNutritionTab(macro),

                        const SizedBox(height: 20),

                        // 6. WELLNESS / MOTIVATION CARD
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            children: [
                              Text('🌱', style: TextStyle(fontSize: 24)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Masak sendiri di kost menjamin kebersihan, menjaga disiplin protein harian, dan menghemat jutaan rupiah setiap bulan.',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11.5,
                                    height: 1.45,
                                    color: Color(0xFF065F46),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
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

  // ---------------------------------------------------------------------------
  // 1. HERO HEADER WITH ORGANIC CURVE & FOOD IMAGE
  // ---------------------------------------------------------------------------
  Widget _buildHeroHeader(String imageAsset, String packageKey) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4E6D8),
            const Color(0xFFE8F2EC),
            Star.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Background soft hill decoration
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 110,
            child: CustomPaint(
              painter: _HeroCurvePainter(),
            ),
          ),

          // Central Food Dish Illustration
          Center(
            child: Hero(
              tag: 'meal_photo_$packageKey',
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Star.workoutSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          packageKey,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top action buttons: Back / Close button
          Positioned(
            top: 12,
            left: 16,
            child: InkWell(
              onTap: () {
                iosTapBuzz();
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Star.ink,
                ),
              ),
            ),
          ),

          // Top right package badge
          Positioned(
            top: 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restaurant_menu_rounded,
                      size: 15, color: Star.star),
                  const SizedBox(width: 5),
                  Text(
                    'Paket $packageKey',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Star.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // METRIC BADGE
  // ---------------------------------------------------------------------------
  Widget _metricBadge({
    required IconData icon,
    required String label,
    required String sub,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Star.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Star.lineSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Star.ink,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 9,
              color: Star.mut,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. COOKING TIMER SECTION (CTA BUTTON / ACTIVE TIMER)
  // ---------------------------------------------------------------------------
  Widget _buildCookingTimerSection(int waktu) {
    if (!_isTimerRunning && _timerSeconds == _timerTotalSeconds && !_isTimerFinished) {
      // Big Prominent Start Button (Matching reference green CTA)
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: () => _startTimer(waktu * 60),
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: Text(
            'Mulai Memasak (Timer $waktu Menit)',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2E6B56),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
        ),
      );
    }

    // Active Timer Card
    final progress = _timerTotalSeconds > 0
        ? (1.0 - (_timerSeconds / _timerTotalSeconds)).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isTimerFinished
            ? const Color(0xFFECFDF5)
            : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isTimerFinished
              ? const Color(0xFF10B981)
              : const Color(0xFF86EFAC),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isTimerFinished
                      ? const Color(0xFF10B981)
                      : const Color(0xFF2E6B56),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isTimerFinished
                      ? Icons.check_circle_rounded
                      : Icons.timer_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isTimerFinished
                          ? 'Waktu Masak Selesai!'
                          : (_isTimerRunning ? 'Timer Sedang Berjalan' : 'Timer Dijeda'),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isTimerFinished
                            ? const Color(0xFF065F46)
                            : const Color(0xFF166534),
                      ),
                    ),
                    Text(
                      _formatTimer(_timerSeconds),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Star.ink,
                      ),
                    ),
                  ],
                ),
              ),

              // Timer action buttons
              if (!_isTimerFinished) ...[
                IconButton(
                  onPressed: _isTimerRunning ? _pauseTimer : () => _startTimer(),
                  icon: Icon(
                    _isTimerRunning
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: const Color(0xFF2E6B56),
                    size: 34,
                  ),
                ),
                IconButton(
                  onPressed: () => _addTimerMinute(2),
                  tooltip: '+2 Menit',
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      color: Star.mut, size: 26),
                ),
                IconButton(
                  onPressed: _resetTimer,
                  tooltip: 'Reset',
                  icon: const Icon(Icons.refresh_rounded,
                      color: Star.mut, size: 24),
                ),
              ] else ...[
                FilledButton.tonal(
                  onPressed: _resetTimer,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Masak Lagi'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFDCFCE7),
              valueColor: AlwaysStoppedAnimation<Color>(
                _isTimerFinished
                    ? const Color(0xFF10B981)
                    : const Color(0xFF2E6B56),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. SEGMENTED TABS
  // ---------------------------------------------------------------------------
  Widget _buildSegmentedTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Star.sunken,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              index: 0,
              label: 'Langkah Masak',
              icon: Icons.format_list_numbered_rounded,
            ),
          ),
          Expanded(
            child: _tabButton(
              index: 1,
              label: 'Bahan & Belanja',
              icon: Icons.shopping_basket_outlined,
            ),
          ),
          Expanded(
            child: _tabButton(
              index: 2,
              label: 'Nutrisi Lengkap',
              icon: Icons.pie_chart_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final active = _activeTab == index;
    return InkWell(
      onTap: () {
        iosTapBuzz();
        setState(() => _activeTab = index);
      },
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Star.star : Star.mut,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active ? Star.ink : Star.mut,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 0: LANGKAH MASAK (URUT & SISTEMATIS)
  // ---------------------------------------------------------------------------
  Widget _buildCookingStepsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.kitchen_rounded, size: 16, color: Star.star),
            const SizedBox(width: 6),
            const Text(
              'Panduan Eksekusi Sistematis:',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Star.ink,
              ),
            ),
            const Spacer(),
            Text(
              'Alat: Panci + Magic Com',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Star.star.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Steps rendered via RecipeSteps from widgets.dart
        RecipeSteps(widget.pola.cara, label: null),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: BAHAN & BELANJA
  // ---------------------------------------------------------------------------
  Widget _buildIngredientsTab(int budget) {
    final ingredients = _parseIngredients(widget.pola.belanja);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 16, color: Star.star),
            const SizedBox(width: 6),
            const Text(
              'Bahan & Estimasi Belanja:',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Star.ink,
              ),
            ),
            const Spacer(),
            Text(
              'Total: Rp${_formatRupiah(budget)}',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Star.star,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (ingredients.isEmpty)
          const Text(
            'Bahan belanja standar paket harian kost.',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 12),
          )
        else
          for (var i = 0; i < ingredients.length; i++) ...[
            InkWell(
              onTap: () {
                iosTapBuzz();
                setState(() {
                  if (_checkedIngredients.contains(i)) {
                    _checkedIngredients.remove(i);
                  } else {
                    _checkedIngredients.add(i);
                  }
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _checkedIngredients.contains(i)
                      ? Star.sunken.withValues(alpha: 0.5)
                      : Star.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _checkedIngredients.contains(i)
                        ? Colors.transparent
                        : Star.lineSoft,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _checkedIngredients.contains(i)
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: _checkedIngredients.contains(i)
                          ? Star.star
                          : Star.mut,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ingredients[i],
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _checkedIngredients.contains(i)
                              ? Star.mut
                              : Star.ink,
                          decoration: _checkedIngredients.contains(i)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: NUTRISI LENGKAP
  // ---------------------------------------------------------------------------
  Widget _buildNutritionTab(Macro? macro) {
    final k = macro?.k ?? 630;
    final p = macro?.p ?? 58;
    final c = macro?.c ?? 40;
    final l = macro?.l ?? 32;
    final s = macro?.s ?? 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.bar_chart_rounded, size: 16, color: Star.star),
            SizedBox(width: 6),
            Text(
              'Rincian Makronutrisi:',
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
        Row(
          children: [
            Expanded(
              child: _nutriTile('Protein', '${p}g', 'Recovery Otot',
                  const Color(0xFFD97706)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _nutriTile('Karbohidrat', '${c}g', 'Energi Harian',
                  const Color(0xFF2563EB)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _nutriTile(
                  'Lemak', '${l}g', 'Hormon Sehat', const Color(0xFF7C3AED)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _nutriTile(
                  'Serat', '${s}g', 'Pencernaan', const Color(0xFF059669)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Star.sunken,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Kalori Harian:',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Star.ink,
                ),
              ),
              Text(
                '$k kkal',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Star.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nutriTile(String title, String value, String role, Color accent) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Star.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Star.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Star.mut,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Star.ink,
            ),
          ),
          Text(
            role,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 9.5,
              color: Star.faint,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SMOOTH CURVE PAINTER FOR HERO HEADER
// -----------------------------------------------------------------------------
class _HeroCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Star.surface
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.15,
        size.width * 0.5,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.55,
        size.width,
        size.height * 0.25,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
