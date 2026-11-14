// Choice Plan Page: Custom Workout Builder, Biometrics, Nutrition & Smart Rest Timer
// Self Volta - Advanced Athletic Edition (Zero AI Slop)

import 'dart:async';

import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Model item latihan yang dapat dikustomisasi secara presisi oleh user
class ChoiceExercise {
  String id;
  String name;
  String targetMuscle;
  int sets;
  int reps;
  int workSeconds; // 0 = bebas hitung repetisi, >0 = target detik kerja
  int restSeconds; // durasi jeda istirahat antar set
  String tip;
  IconData icon;

  ChoiceExercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.sets,
    required this.reps,
    this.workSeconds = 0,
    this.restSeconds = 60,
    required this.tip,
    this.icon = Icons.fitness_center_rounded,
  });

  ChoiceExercise copyWith({
    String? name,
    String? targetMuscle,
    int? sets,
    int? reps,
    int? workSeconds,
    int? restSeconds,
    String? tip,
    IconData? icon,
  }) {
    return ChoiceExercise(
      id: id,
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      tip: tip ?? this.tip,
      icon: icon ?? this.icon,
    );
  }
}

class ChoicePlanPage extends StatefulWidget {
  final void Function(String)? onNavigate;

  const ChoicePlanPage({super.key, this.onNavigate});

  @override
  State<ChoicePlanPage> createState() => _ChoicePlanPageState();
}

class _ChoicePlanPageState extends State<ChoicePlanPage> {
  // Target durasi latihan hari ini (dalam menit)
  int _targetDurationMinutes = 45;

  // Preset kategori yang sedang aktif
  String _activePreset = 'push';

  // Daftar latihan aktif yang dapat diedit bebas
  late List<ChoiceExercise> _exercises;

  @override
  void initState() {
    super.initState();
    _loadPresetInternal('push');
  }

  void _loadPreset(String key) {
    setState(() {
      _loadPresetInternal(key);
    });
  }

  void _loadPresetInternal(String key) {
    _activePreset = key;
    switch (key) {
      case 'push':
        _exercises = [
          ChoiceExercise(
            id: 'push_std',
            name: 'Push Up Standar',
            targetMuscle: 'Dada & Trisep',
            sets: 3,
            reps: 12,
            workSeconds: 0,
            restSeconds: 60,
            tip: 'Jaga siku 45 derajat, tubuh lurus dari kepala hingga tumit.',
            icon: Icons.sports_gymnastics_rounded,
          ),
          ChoiceExercise(
            id: 'push_dia',
            name: 'Diamond Push Up',
            targetMuscle: 'Fokus Trisep',
            sets: 3,
            reps: 8,
            workSeconds: 0,
            restSeconds: 60,
            tip: 'Dekatkan kedua jempol dan telunjuk membentuk segitiga di dada.',
            icon: Icons.flash_on_rounded,
          ),
          ChoiceExercise(
            id: 'push_dec',
            name: 'Decline Push Up',
            targetMuscle: 'Dada Atas & Bahu Depan',
            sets: 3,
            reps: 10,
            workSeconds: 0,
            restSeconds: 60,
            tip: 'Kaki di atas kursi/kasur, turun perlahan kontrol 2-3 detik.',
            icon: Icons.vertical_align_top_rounded,
          ),
          ChoiceExercise(
            id: 'push_dips',
            name: 'Chair / Bench Dips',
            targetMuscle: 'Trisep & Bahu',
            sets: 3,
            reps: 12,
            workSeconds: 0,
            restSeconds: 45,
            tip: 'Dada tegap, turun hingga siku membentuk sudut 90 derajat.',
            icon: Icons.chair_rounded,
          ),
        ];
        break;
      case 'pull':
        _exercises = [
          ChoiceExercise(
            id: 'pull_close',
            name: 'Pull Up Close Grip',
            targetMuscle: 'Sayap (Lat) & Bisep',
            sets: 3,
            reps: 4,
            workSeconds: 0,
            restSeconds: 90,
            tip: 'Genggaman selebar bahu di kusen beton/bar, tarik dada menyentuh bar.',
            icon: Icons.vertical_align_bottom_rounded,
          ),
          ChoiceExercise(
            id: 'pull_aus',
            name: 'Australian Pull Up / Row Meja',
            targetMuscle: 'Punggung Tengah & Postur',
            sets: 3,
            reps: 10,
            workSeconds: 0,
            restSeconds: 60,
            tip: 'Pegang tepi meja kokoh, tarik dada mendekati meja dengan stabil.',
            icon: Icons.table_restaurant_rounded,
          ),
          ChoiceExercise(
            id: 'pull_chin',
            name: 'Chin Up (Telapak Hadap Muka)',
            targetMuscle: 'Puncak Bisep & Lat Bawah',
            sets: 3,
            reps: 5,
            workSeconds: 0,
            restSeconds: 90,
            tip: 'Fokus kontraksi bisep, turun penuh tanpa sentakan.',
            icon: Icons.fitness_center_rounded,
          ),
          ChoiceExercise(
            id: 'pull_shrug',
            name: 'Scapular Retraction Shrug',
            targetMuscle: 'Kesehatan Bahu & Belikat',
            sets: 3,
            reps: 10,
            workSeconds: 0,
            restSeconds: 45,
            tip: 'Hanya gerakkan belikat naik-turun tanpa menekuk siku.',
            icon: Icons.accessibility_new_rounded,
          ),
        ];
        break;
      case 'legs':
        _exercises = [
          ChoiceExercise(
            id: 'leg_squat',
            name: 'Bodyweight Squat',
            targetMuscle: 'Paha Depan & Bokong',
            sets: 3,
            reps: 15,
            workSeconds: 0,
            restSeconds: 60,
            tip: 'Kaki selebar bahu, pantat dorong ke belakang seperti duduk di kursi.',
            icon: Icons.airline_seat_legroom_extra_rounded,
          ),
          ChoiceExercise(
            id: 'leg_lunge',
            name: 'Walking / Static Lunges',
            targetMuscle: 'Keseimbangan & Glutes',
            sets: 3,
            reps: 10,
            workSeconds: 0,
            restSeconds: 60,
            tip: 'Lutut depan jangan melebihi jari kaki, turun tegak lurus.',
            icon: Icons.directions_walk_rounded,
          ),
          ChoiceExercise(
            id: 'leg_bridge',
            name: 'Glute Bridge',
            targetMuscle: 'Bokong & Hamstring',
            sets: 3,
            reps: 15,
            workSeconds: 0,
            restSeconds: 45,
            tip: 'Rapatkan tumit, dorong pinggul ke atas dan tahan 2 detik di puncak.',
            icon: Icons.wb_sunny_rounded,
          ),
          ChoiceExercise(
            id: 'leg_calf',
            name: 'Standing Calf Raises',
            targetMuscle: 'Otot Betis Kuat',
            sets: 3,
            reps: 20,
            workSeconds: 0,
            restSeconds: 30,
            tip: 'Jinjit maksimal di lantai/ujung tangga, turun perlahan.',
            icon: Icons.north_rounded,
          ),
        ];
        break;
      case 'core':
        _exercises = [
          ChoiceExercise(
            id: 'core_plank',
            name: 'Plank Tahan Solid',
            targetMuscle: 'Core & Stabilitas Tulang Belakang',
            sets: 3,
            reps: 30, // 30 detik
            workSeconds: 30,
            restSeconds: 45,
            tip: 'Kunci perut rapat, jangan biarkan pinggang melengkung turun.',
            icon: Icons.shield_rounded,
          ),
          ChoiceExercise(
            id: 'core_deadbug',
            name: 'Dead Bug Terkontrol',
            targetMuscle: 'Perut Bawah & Anti-Rotasi',
            sets: 3,
            reps: 8,
            workSeconds: 0,
            restSeconds: 45,
            tip: 'Punggung bawah menempel rapat ke lantai tanpa ada celah.',
            icon: Icons.bug_report_rounded,
          ),
          ChoiceExercise(
            id: 'core_raises',
            name: 'Lying Leg Raises',
            targetMuscle: 'Perut Bawah (Lower Abs)',
            sets: 3,
            reps: 10,
            workSeconds: 0,
            restSeconds: 60,
            tip: 'Angkat kaki lurus perlahan, jangan gunakan ayunan tubuh.',
            icon: Icons.vertical_align_top_rounded,
          ),
          ChoiceExercise(
            id: 'core_birddog',
            name: 'Bird Dog Sisi Bergantian',
            targetMuscle: 'Core Belakang & Keseimbangan',
            sets: 3,
            reps: 8,
            workSeconds: 0,
            restSeconds: 45,
            tip: 'Rentangkan tangan kanan dan kaki kiri secara sejajar garis tubuh.',
            icon: Icons.pets_rounded,
          ),
        ];
        break;
      case 'fullbody':
        _exercises = [
          ChoiceExercise(
            id: 'fb_pull',
            name: 'Pull Up Close Grip',
            targetMuscle: 'Punggung & Bisep',
            sets: 3,
            reps: 4,
            workSeconds: 0,
            restSeconds: 90,
            tip: 'Fokus gerakan menarik tubuh ke atas dengan rentang penuh.',
            icon: Icons.vertical_align_bottom_rounded,
          ),
          ChoiceExercise(
            id: 'fb_push',
            name: 'Push Up Standar',
            targetMuscle: 'Dada & Trisep',
            sets: 3,
            reps: 12,
            workSeconds: 0,
            restSeconds: 60,
            tip: 'Kontrol tempo gerakan: 2 detik turun, 1 detik dorong naik.',
            icon: Icons.sports_gymnastics_rounded,
          ),
          ChoiceExercise(
            id: 'fb_squat',
            name: 'Bodyweight Squat',
            targetMuscle: 'Kaki & Bokong',
            sets: 3,
            reps: 15,
            workSeconds: 0,
            restSeconds: 60,
            tip: 'Turun hingga paha sejajar lantai, dorong dari tumit.',
            icon: Icons.airline_seat_legroom_extra_rounded,
          ),
          ChoiceExercise(
            id: 'fb_plank',
            name: 'Plank Core',
            targetMuscle: 'Perut & Punggung Bawah',
            sets: 3,
            reps: 30,
            workSeconds: 30,
            restSeconds: 45,
            tip: 'Kencangkan bokong dan perut selama menahan posisi.',
            icon: Icons.shield_rounded,
          ),
        ];
        break;
      case 'custom':
        if (_exercises.isEmpty) {
          _exercises = [
            ChoiceExercise(
              id: 'custom_1',
              name: 'Gerakan Pilihan Anda',
              targetMuscle: 'Bebas Kustom',
              sets: 3,
              reps: 10,
              workSeconds: 0,
              restSeconds: 60,
              tip: 'Tentukan repetisi, set, dan jeda istirahat sesuai target Anda.',
              icon: Icons.tune_rounded,
            ),
          ];
        }
        break;
    }
  }

  // Menghitung estimasi kalori terbakar berdasarkan durasi & berat badan
  int _calculateCaloriesBurned(double weightKg) {
    final cal = (6.0 * 3.5 * weightKg / 200.0) * _targetDurationMinutes;
    return cal.round().clamp(100, 800);
  }

  int get _totalPlannedSets => _exercises.fold(0, (acc, e) => acc + e.sets);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        final st = AppState.I;
        final calBurned = _calculateCaloriesBurned(st.weightKg);
        final dailyCal = st.dailyCalories + (calBurned * 0.35).round();
        final dailyProtein = st.dailyProtein;
        final dailyWater =
            (st.dailyWaterMl / 1000.0) +
            (_targetDurationMinutes > 30 ? 0.4 : 0.2);

        return Scaffold(
          backgroundColor: Star.bg,
          appBar: AppBar(
            backgroundColor: Star.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Star.ink,
                size: 20,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  widget.onNavigate?.call('workout');
                }
              },
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choice Plan Latihan',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Star.ink,
                  ),
                ),
                Text(
                  'Kustom Gerakan, Reps, Waktu & Nutrisi',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: Star.mut,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TutorialPillButton(
                onTap: () => _showChoicePlanTutorial(context),
                label: 'Panduan',
                color: Star.star,
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Star.star.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Star.star.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 16, color: Star.star),
                    const SizedBox(width: 4),
                    Text(
                      'Lv.${st.level}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Star.star,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Star.sunken, height: 1),
            ),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // ============================================================
              // 1. KARTU BIOMETRIK (BMI) & KEBUTUHAN ASUPAN HARIAN TERINTEGRASI
              // ============================================================
              _buildBiometricsAndNutritionCard(
                st: st,
                dailyCal: dailyCal,
                dailyProtein: dailyProtein,
                dailyWater: dailyWater,
                calBurned: calBurned,
              ),
              const SizedBox(height: 16),

              // ============================================================
              // 2. TARGET DURASI LATIHAN HARI INI (MAU BERAPA JAM / MENIT)
              // ============================================================
              _buildWorkoutDurationPicker(calBurned),
              const SizedBox(height: 16),

              // ============================================================
              // 3. PEMILIH FOKUS LATIHAN (PRESET PLANS)
              // ============================================================
              _buildPlanPresetsSelector(),
              const SizedBox(height: 16),

              // ============================================================
              // 4. DAFTAR GERAKAN & KUSTOMISASI REPS / SET / WAKTU / REST
              // ============================================================
              _buildExercisesCustomizer(st),
              const SizedBox(height: 20),

              // ============================================================
              // 5. SHORTCUT PINDAH KE PROGRAM RUTIN 3X SEMINGGU
              // ============================================================
              _buildBackToRoutineProgramCard(context),
              const SizedBox(height: 100),
            ],
          ),
          // Floating Action Bottom Bar: Tombol Mulai Sesi Choice Plan
          bottomSheet: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Star.surface,
              border: const Border(top: BorderSide(color: Star.sunken)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_exercises.length} Gerakan • $_totalPlannedSets Total Set',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Star.mut,
                          ),
                        ),
                        Text(
                          'Estimasi $_targetDurationMinutes Menit (~$calBurned kkal)',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Star.star,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _exercises.isEmpty
                        ? null
                        : () => _launchActiveWorkoutSession(context, st),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text(
                      'Mulai Latihan',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Star.star,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackToRoutineProgramCard(BuildContext context) {
    return Container(
      decoration: Neu.raised(r: 16, d: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            iosTapBuzz();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              widget.onNavigate?.call('workout');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Star.star.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Star.star,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Program Rutin 3x Seminggu',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Star.ink,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Beralih ke program terstruktur Senin, Rabu & Jumat',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: Star.mut,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Star.mut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 1. KARTU BIOMETRIK (BMI) & KEBUTUHAN ASUPAN HARIAN
  // --------------------------------------------------------------------------
  Widget _buildBiometricsAndNutritionCard({
    required AppState st,
    required int dailyCal,
    required int dailyProtein,
    required double dailyWater,
    required int calBurned,
  }) {
    Color bmiBadgeColor;
    if (st.bmi < 18.5) {
      bmiBadgeColor = Star.star; // Amber Underweight
    } else if (st.bmi < 25.0) {
      bmiBadgeColor = Star.star; // Emerald Ideal
    } else {
      bmiBadgeColor = Star.error; // Rose Overweight
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: BMI & Tombol Edit Fisik (Anti-Jebol Overflow)
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Star.star.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.monitor_weight_rounded,
                        color: Star.star,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil Fisik & Nutrisi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Star.ink,
                            ),
                          ),
                          Text(
                            'Target latihan otomatis',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              color: Star.mut,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showEditBodyProfileSheet(st),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Star.star.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, size: 12, color: Star.star),
                      SizedBox(width: 4),
                      Text(
                        'Ubah BB/TB',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
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
          const SizedBox(height: 14),

          // Baris Metrik Fisik (BB, TB, BMI Score, Kategori)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: Neu.raised(r: 16, d: 5),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Berat & Tinggi',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Star.mut,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${st.weightKg.toStringAsFixed(1)} kg • ${st.heightCm.toInt()} cm',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Star.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: Star.sunken),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Skor BMI Anda',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Star.mut,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            st.bmi.toStringAsFixed(1),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: bmiBadgeColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: bmiBadgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                st.bmi < 18.5
                                    ? 'Kurus'
                                    : st.bmi < 25.0
                                    ? 'Ideal'
                                    : 'Kelebihan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: bmiBadgeColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4 Kolom Kebutuhan Asupan Harian Presisi (Sinkron Profil)
          Row(
            children: [
              Expanded(
                child: _buildNutritionPill(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: Star.star,
                  title: 'Target Kalori',
                  value: '$dailyCal kkal',
                  subtitle: '+$calBurned kkal bakar',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNutritionPill(
                  icon: Icons.egg_alt_rounded,
                  iconColor: Star.star,
                  title: 'Target Protein',
                  value: '$dailyProtein gram',
                  subtitle:
                      '${(st.dailyProtein / st.weightKg).toStringAsFixed(1)}g / kg BB',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNutritionPill(
                  icon: Icons.grain_rounded,
                  iconColor: Star.star,
                  title: 'Karbohidrat',
                  value: '${st.dailyCarbs} gram',
                  subtitle: 'Bahan Bakar Latihan',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNutritionPill(
                  icon: Icons.water_drop_rounded,
                  iconColor: Star.star,
                  title: 'Kebutuhan Air',
                  value: '${dailyWater.toStringAsFixed(1)} L',
                  subtitle: '±${(dailyWater * 4).round()} Gelas',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Panduan nutrisi pre & post workout — poin, bukan paragraf.
          FactList([
            'Pra-latihan: pisang atau oat.',
            'Pasca-latihan: ~${st.mealTargetProtein}g protein & ~${st.mealTargetCarbs}g karbohidrat untuk sintesis otot dan pemulihan energi.',
          ], label: 'Menu disarankan'),
        ],
      ),
    );
  }

  Widget _buildNutritionPill({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: Neu.raised(r: 14, d: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Star.mut,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Star.ink,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 9.5,
              color: iconColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 2. TARGET DURASI LATIHAN (MAU BERAPA JAM / MENIT)
  // --------------------------------------------------------------------------
  Widget _buildWorkoutDurationPicker(int calBurned) {
    final durations = [
      (mins: 20, label: '20 Mnt', sub: 'Kilat'),
      (mins: 35, label: '35 Mnt', sub: 'Fokus'),
      (mins: 45, label: '45 Mnt', sub: 'Standar'),
      (mins: 60, label: '1 Jam', sub: 'Volume'),
      (mins: 90, label: '1.5 Jam', sub: 'Beast'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: Star.star, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Target Durasi Hari Ini',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Star.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Star.star.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_targetDurationMinutes >= 60 ? (_targetDurationMinutes / 60.0).toStringAsFixed(1) : _targetDurationMinutes} ${_targetDurationMinutes >= 60 ? "Jam" : "Menit"}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Star.star,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pilihan Preset Cepat (20m, 35m, 45m, 1 Jam, 1.5 Jam)
          Row(
            children: durations.map((d) {
              final isSel = _targetDurationMinutes == d.mins;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: InkWell(
                    onTap: () {
                      iosTapBuzz();
                      setState(() => _targetDurationMinutes = d.mins);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: isSel
                          ? BoxDecoration(
                              color: Star.star,
                              borderRadius: BorderRadius.circular(12),
                            )
                          : Neu.raised(r: 12, d: 3),
                      child: Column(
                        children: [
                          Text(
                            d.label,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSel ? Star.onAccent : Star.ink,
                            ),
                          ),
                          Text(
                            d.sub,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isSel ? Star.onAccent70 : Star.mut,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Stepper Slider Halus
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _targetDurationMinutes <= 15
                    ? null
                    : () {
                        iosTapBuzz();
                        setState(() => _targetDurationMinutes -= 5);
                      },
                icon: const Icon(Icons.remove_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Star.bg,
                  foregroundColor: Star.ink,
                  minimumSize: const Size(36, 36),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: Star.star,
                    inactiveTrackColor: Star.sunken,
                    thumbColor: Star.star,
                    overlayColor: Star.star.withValues(alpha: 0.15),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: _targetDurationMinutes.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 21, // Kelipatan 5 menit
                    onChanged: (val) {
                      setState(() => _targetDurationMinutes = val.toInt());
                    },
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: _targetDurationMinutes >= 120
                    ? null
                    : () {
                        iosTapBuzz();
                        setState(() => _targetDurationMinutes += 5);
                      },
                icon: const Icon(Icons.add_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Star.bg,
                  foregroundColor: Star.ink,
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 3. PEMILIH RENCANA / PRESET WORKOUT SPLIT
  // --------------------------------------------------------------------------
  Widget _buildPlanPresetsSelector() {
    final presets = [
      (
        key: 'push',
        title: 'Push (Dada & Trisep)',
        icon: Icons.sports_gymnastics_rounded,
      ),
      (
        key: 'pull',
        title: 'Pull (Punggung & Bisep)',
        icon: Icons.vertical_align_bottom_rounded,
      ),
      (
        key: 'legs',
        title: 'Legs (Kaki & Bokong)',
        icon: Icons.airline_seat_legroom_extra_rounded,
      ),
      (key: 'core', title: 'Core (Perut & Abs)', icon: Icons.shield_rounded),
      (
        key: 'fullbody',
        title: 'Full Body Kalistenik',
        icon: Icons.bolt_rounded,
      ),
      (key: 'custom', title: 'Rancang Sendiri', icon: Icons.tune_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.category_rounded, size: 18, color: Star.star),
              SizedBox(width: 8),
              Text(
                'Pilih Fokus Rencana Latihan',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Star.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: presets.map((p) {
              final isSel = _activePreset == p.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        p.icon,
                        size: 15,
                        color: isSel ? Star.onAccent : Star.star,
                      ),
                      const SizedBox(width: 6),
                      Text(p.title),
                    ],
                  ),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) {
                      iosTapBuzz();
                      _loadPreset(p.key);
                    }
                  },
                  selectedColor: Star.star,
                  backgroundColor: Star.surface,
                  labelStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                    color: isSel ? Star.onAccent : Star.ink,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSel ? Star.star : Star.sunken),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 4. DAFTAR GERAKAN & KUSTOMISASI REPS / SET / WAKTU PER SET / REST
  // --------------------------------------------------------------------------
  Widget _buildExercisesCustomizer(AppState st) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Gerakan & Pengaturan Set',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Star.ink,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddExerciseModal(context),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: const Text(
                'Tambah Gerakan',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Star.star,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_exercises.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: Neu.raised(r: 18, d: 5),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.fitness_center_rounded,
                    size: 40,
                    color: Star.mut,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Belum ada gerakan yang dipilih',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      color: Star.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih salah satu preset di atas atau tambah gerakan manual.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11.5,
                      color: Star.mut,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _loadPreset('push'),
                    child: const Text('Muat Rekomendasi Push Up'),
                  ),
                ],
              ),
            ),
          )
        else
          ..._exercises.asMap().entries.map((entry) {
            final idx = entry.key;
            final ex = entry.value;
            return _buildSingleExerciseCard(idx, ex);
          }),
      ],
    );
  }

  Widget _buildSingleExerciseCard(int idx, ChoiceExercise ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: Neu.raised(r: 18, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Nomor, Nama Gerakan, Target Otot, & Hapus
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Star.star.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${idx + 1}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Star.star,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ex.name,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                    Text(
                      ex.targetMuscle,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Star.star,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Star.mut,
                ),
                onPressed: () {
                  iosTapBuzz();
                  setState(() {
                    _exercises.removeAt(idx);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Petunjuk Form Ringkas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Star.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Star.mut,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ex.tip,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10.5,
                      color: Star.mut,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Baris 2: Stepper Set, Stepper Reps, Waktu Kerja, & Waktu Istirahat
          Row(
            children: [
              // 1. Jumlah Set
              Expanded(
                child: _buildSettingStepper(
                  label: 'Jumlah Set',
                  valueText: '${ex.sets} Set',
                  onMinus: ex.sets <= 1
                      ? null
                      : () {
                          iosTapBuzz();
                          setState(() => ex.sets--);
                        },
                  onPlus: () {
                    iosTapBuzz();
                    if (ex.sets >= 3) {
                      _showMaxSetsNotice(context);
                    } else {
                      setState(() => ex.sets++);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // 2. Jumlah Repetisi (Bisa Dikustomisasi Penuh)
              Expanded(
                child: _buildSettingStepper(
                  label: 'Repetisi',
                  valueText: '${ex.reps} Reps',
                  onMinus: ex.reps <= 1
                      ? null
                      : () {
                          iosTapBuzz();
                          setState(() => ex.reps--);
                        },
                  onPlus: ex.reps >= 50
                      ? null
                      : () {
                          iosTapBuzz();
                          setState(() => ex.reps++);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Baris 3: Waktu Kerja per Set & Waktu Jeda Istirahat
          Row(
            children: [
              // Waktu per Set (Work time)
              Expanded(
                child: InkWell(
                  onTap: () => _pickWorkTimeDialog(idx, ex),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: Neu.raised(r: 12, d: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Waktu per Set',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 9.5,
                            color: Star.mut,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Star.star,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ex.workSeconds == 0
                                  ? 'Bebas Reps'
                                  : '${ex.workSeconds} Detik',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Star.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Waktu Istirahat per Set (Rest Duration)
              Expanded(
                child: InkWell(
                  onTap: () => _pickRestTimeDialog(idx, ex),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: Neu.raised(r: 12, d: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jeda Istirahat (Rest)',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 9.5,
                            color: Star.mut,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.hourglass_top_rounded,
                              size: 14,
                              color: Star.star,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${ex.restSeconds} Detik',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Star.star,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingStepper({
    required String label,
    required String valueText,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: Neu.raised(r: 12, d: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 9.5,
              color: Star.mut,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onMinus,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: onMinus == null ? Colors.transparent : Star.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Star.lineSoft),
                  ),
                  child: Icon(
                    Icons.remove_rounded,
                    size: 14,
                    color: onMinus == null
                        ? Star.mut.withValues(alpha: 0.3)
                        : Star.ink,
                  ),
                ),
              ),
              Text(
                valueText,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Star.ink,
                ),
              ),
              InkWell(
                onTap: onPlus,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: onPlus == null ? Colors.transparent : Star.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Star.lineSoft),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 14,
                    color: onPlus == null
                        ? Star.mut.withValues(alpha: 0.3)
                        : Star.ink,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog Pilih Waktu Kerja

  void _showMaxSetsNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Star.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Star.star, size: 24),
            SizedBox(width: 8),
            Text(
              'Batas Maksimal 3 Set',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Star.ink,
              ),
            ),
          ],
        ),
        content: const Text(
          'Lebih baik dibanyakin reps nya dan set nya udah tiga aja dalam satu gerakan ini',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            color: Star.mut,
            height: 1.45,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: Star.star,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Siap, Paham!'),
          ),
        ],
      ),
    );
  }

  void _showChoicePlanTutorial(BuildContext context) {
    showInteractiveSpotlightTutorial(
      context,
      tutorialTitle: 'Panduan Choice Plan',
      steps: const [
        TutorialStepItem(
          title: 'Preset Kalistenik & Fokus Otot',
          category: 'Kustomisasi Program Latihan',
          featureTag: 'Program Terarah',
          description: 'Pilih preset Push, Pull, Legs, Core, atau Fullbody untuk memuat daftar gerakan kalistenik standar yang seimbang untuk melatih otot tanpa alat berat.',
          tip: 'Kamu bisa memilih preset rekomendasi, lalu menambah atau menghapus gerakan sesuka hati.',
          icon: Icons.fitness_center_rounded,
          accentColor: Star.star,
        ),
        TutorialStepItem(
          title: 'Aturan Presisi: Maksimal 3 Set',
          category: 'Hypertrophy & Pemulihan Sendi',
          featureTag: 'Saran Sains Kalistenik',
          description: 'Setiap gerakan dibatasi maksimal 3 set. Mengapa? Dalam kalistenik intensif, 3 set berkualitas tinggi dengan repetisi penuh lebih efektif memicu hypertrophy tanpa membebani ligamen dan tendon siku/bahu.',
          tip: 'Saran pelatih: Lebih baik dibanyakin reps nya dan set nya udah tiga aja dalam satu gerakan ini.',
          icon: Icons.shield_rounded,
          accentColor: Star.star,
        ),
        TutorialStepItem(
          title: 'Input Gerakan Kustom Sendiri',
          category: 'Bebas Kustomisasi',
          featureTag: 'Repetisi & Target Bebas',
          description: 'Ingin latihan Handstand, Archer Push-up, atau L-Sit? Gunakan tombol Tambah Gerakan Kustom untuk memasukkan gerakan pilihanmu sendiri dengan repetisi bebas.',
          tip: 'Atur durasi istirahat antar set antara 45 hingga 90 detik agar ATP otot pulih maksimal sebelum set berikutnya.',
          icon: Icons.add_circle_outline_rounded,
          accentColor: Star.success,
        ),
        TutorialStepItem(
          title: 'Mode Live Sesi & Rest Timer Otomatis',
          category: 'Pelaksanaan Latihan',
          featureTag: 'Smart Rest Countdown',
          description: 'Tekan Mulai Sesi Sekarang untuk menjalankan panduan latihan layar penuh. Aplikasi akan memandu hitungan set demi set dan menghitung jeda istirahat otomatis dengan audio bip.',
          tip: 'Kamu bisa menambah 20 detik jika napas belum teratur atau lewati jeda jika sudah siap gas ke set berikutnya!',
          icon: Icons.play_circle_fill_rounded,
          accentColor: Star.star,
        ),
      ],
    );
  }

  void _showAddCustomExerciseModal(BuildContext context) {
    iosTapBuzz();
    final nameCtrl = TextEditingController();
    final muscleCtrl = TextEditingController(text: 'Dada & Trisep');
    final tipCtrl = TextEditingController();
    int customSets = 3;
    int customReps = 10;
    int customRest = 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Star.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.82,
              ),
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPadding),
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
                          color: Star.sunken,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Input Gerakan Kustom Sendiri',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                    const Text(
                      'Bebas tentukan nama, repetisi, dan otot target. Maksimal 3 set untuk hypertrophy aman.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: Star.mut,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Nama Gerakan
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Gerakan (Contoh: Archer Push Up)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Target Otot
                    TextField(
                      controller: muscleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Target Otot (Contoh: Bahu & Core)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Baris Stepper: Sets (Maksimal 3) & Reps (Bebas)
                    Row(
                      children: [
                        // Sets (Max 3)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: Neu.raised(r: 12, d: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jumlah Set (Maks 3)',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    color: Star.mut,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: customSets <= 1
                                          ? null
                                          : () => setModalState(
                                              () => customSets--,
                                            ),
                                      child: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                        size: 20,
                                        color: Star.ink,
                                      ),
                                    ),
                                    Text(
                                      '$customSets Set',
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Star.ink,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (customSets >= 3) {
                                          _showMaxSetsNotice(ctx);
                                        } else {
                                          setModalState(() => customSets++);
                                        }
                                      },
                                      child: const Icon(
                                        Icons.add_circle_outline_rounded,
                                        size: 20,
                                        color: Star.star,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Reps Bebas
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: Neu.raised(r: 12, d: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Repetisi Bebas',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    color: Star.mut,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: customReps <= 1
                                          ? null
                                          : () => setModalState(
                                              () => customReps--,
                                            ),
                                      child: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                        size: 20,
                                        color: Star.ink,
                                      ),
                                    ),
                                    Text(
                                      '$customReps Reps',
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Star.star,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: customReps >= 100
                                          ? null
                                          : () => setModalState(
                                              () => customReps++,
                                            ),
                                      child: const Icon(
                                        Icons.add_circle_outline_rounded,
                                        size: 20,
                                        color: Star.star,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Catatan Form / Tips Gerakan
                    TextField(
                      controller: tipCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Form (Opsional, contoh: Kunci core dan kontrol tempo)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Masukkan nama gerakan kustom terlebih dahulu!',
                                ),
                              ),
                            );
                            return;
                          }
                          final muscle = muscleCtrl.text.trim().isEmpty
                              ? 'Bebas Kustom'
                              : muscleCtrl.text.trim();
                          final tip = tipCtrl.text.trim().isEmpty
                              ? 'Fokus bentuk form sempurna dan kontrol repetisi.'
                              : tipCtrl.text.trim();

                          iosTapBuzz();
                          setState(() {
                            _exercises.add(
                              ChoiceExercise(
                                id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                name: name.length > 40
                                    ? name.substring(0, 40)
                                    : name,
                                targetMuscle: muscle.length > 30
                                    ? muscle.substring(0, 30)
                                    : muscle,
                                sets: customSets.clamp(1, 3),
                                reps: customReps.clamp(1, 100),
                                workSeconds: 0,
                                restSeconds: customRest,
                                tip: tip.length > 80
                                    ? tip.substring(0, 80)
                                    : tip,
                                icon: Icons.fitness_center_rounded,
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gerakan "$name" ($customSets Set x $customReps Reps) ditambahkan!',
                              ),
                              backgroundColor: Star.star,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          color: Star.onAccent,
                          size: 18,
                        ),
                        label: const Text(
                          'Simpan Gerakan Kustom',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            color: Star.onAccent,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Star.star,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _pickWorkTimeDialog(int idx, ChoiceExercise ex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Star.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final options = [
          (seconds: 0, label: 'Bebas Reps (Hitungan Manual)'),
          (seconds: 25, label: '25 Detik per Set (Tempo Cepat)'),
          (seconds: 35, label: '35 Detik per Set (Standar Kalistenik)'),
          (seconds: 45, label: '45 Detik per Set (Intensitas Tinggi)'),
          (seconds: 60, label: '60 Detik per Set (Endurance Penuh)'),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atur Waktu Kerja per Set',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Star.ink,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((opt) {
                  final isSel = ex.workSeconds == opt.seconds;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt.label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Star.star : Star.ink,
                      ),
                    ),
                    trailing: isSel
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Star.star,
                          )
                        : null,
                    onTap: () {
                      iosTapBuzz();
                      setState(() => ex.workSeconds = opt.seconds);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog Pilih Waktu Istirahat (Rest)
  void _pickRestTimeDialog(int idx, ChoiceExercise ex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Star.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final options = [
          (seconds: 30, label: '30 Detik (Jeda Pendek • Bakar Lemak)'),
          (seconds: 45, label: '45 Detik (Optimal Kalistenik)'),
          (seconds: 60, label: '60 Detik (Standar Hipertrofi)'),
          (seconds: 90, label: '90 Detik (Kekuatan Pull-Up/Dips)'),
          (seconds: 120, label: '120 Detik (Pemulihan Saraf Maksimal)'),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atur Jeda Istirahat (Rest Timer)',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Star.ink,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((opt) {
                  final isSel = ex.restSeconds == opt.seconds;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt.label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Star.star : Star.ink,
                      ),
                    ),
                    trailing: isSel
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Star.star,
                          )
                        : null,
                    onTap: () {
                      iosTapBuzz();
                      setState(() => ex.restSeconds = opt.seconds);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modal Tambah Gerakan Baru
  void _showAddExerciseModal(BuildContext context) {
    final availableLibrary = [
      (
        name: 'Push Up Standar',
        muscle: 'Dada & Trisep',
        reps: 12,
        tip: 'Siku 45 derajat, tubuh stabil lurus.',
      ),
      (
        name: 'Diamond Push Up',
        muscle: 'Trisep Dalam',
        reps: 8,
        tip: 'Tangan segitiga di bawah dada.',
      ),
      (
        name: 'Pike Push Up',
        muscle: 'Bahu Depan & Trapezius',
        reps: 8,
        tip: 'Pinggul dorong ke atas menyerupai piramida.',
      ),
      (
        name: 'Pull Up Close Grip',
        muscle: 'Punggung & Bisep',
        reps: 4,
        tip: 'Genggam kusen/bar, tarik dada ke atas.',
      ),
      (
        name: 'Australian Pull Up',
        muscle: 'Punggung Tengah',
        reps: 10,
        tip: 'Gunakan bawah meja atau bar rendah.',
      ),
      (
        name: 'Bodyweight Squat',
        muscle: 'Paha & Bokong',
        reps: 15,
        tip: 'Paha sejajar lantai, dada tegap.',
      ),
      (
        name: 'Walking Lunges',
        muscle: 'Kaki & Keseimbangan',
        reps: 10,
        tip: 'Langkah stabil, lutut 90 derajat.',
      ),
      (
        name: 'Plank Core',
        muscle: 'Perut & Tulang Belakang',
        reps: 30,
        tip: 'Kencangkan otot perut dan bokong.',
      ),
      (
        name: 'Dead Bug',
        muscle: 'Perut Bawah',
        reps: 8,
        tip: 'Punggung bawah menempel lantai.',
      ),
      (
        name: 'Chair / Bench Dips',
        muscle: 'Trisep & Bahu',
        reps: 12,
        tip: 'Turun siku 90 derajat dekat kursi.',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Star.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Star.sunken,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Koleksi Gerakan Kalistenik',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Star.ink,
                ),
              ),
              const Text(
                'Pilih gerakan standar atau buat gerakan kustom Anda sendiri',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: Star.mut,
                ),
              ),
              const SizedBox(height: 10),

              // Tombol Tambah Gerakan Kustom Sendiri
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddCustomExerciseModal(context);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Star.star,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: Star.onAccent,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '+ Buat Gerakan Kustom Sendiri',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Star.onAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: availableLibrary.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Star.sunken),
                  itemBuilder: (_, idx) {
                    final item = availableLibrary[idx];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Star.star.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Star.star,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Star.ink,
                        ),
                      ),
                      subtitle: Text(
                        '${item.muscle} • ${item.reps} Reps',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: Star.mut,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Star.star,
                      ),
                      onTap: () {
                        iosTapBuzz();
                        setState(() {
                          _exercises.add(
                            ChoiceExercise(
                              id: 'custom_${DateTime.now().millisecondsSinceEpoch}_$idx',
                              name: item.name,
                              targetMuscle: item.muscle,
                              sets: 3,
                              reps: item.reps,
                              workSeconds: 0,
                              restSeconds: 60,
                              tip: item.tip,
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // BottomSheet Ubah Berat & Tinggi Badan
  void _showEditBodyProfileSheet(AppState st) {
    double tempWeight = st.weightKg;
    double tempHeight = st.heightCm;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Star.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final tempBmi = (tempHeight > 0)
                ? tempWeight / ((tempHeight / 100.0) * (tempHeight / 100.0))
                : 0.0;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Star.sunken,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Ubah Profil Fisik (BB & TB)',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                    const Text(
                      'Kebutuhan kalori dan target protein harian akan disesuaikan otomatis.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: Star.mut,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Pengaturan Berat Badan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Berat Badan (kg)',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () {
                                setModalState(
                                  () => tempWeight = (tempWeight - 0.5).clamp(
                                    35.0,
                                    160.0,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.remove_rounded, size: 16),
                            ),
                            Container(
                              width: 65,
                              alignment: Alignment.center,
                              child: Text(
                                '${tempWeight.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () {
                                setModalState(
                                  () => tempWeight = (tempWeight + 0.5).clamp(
                                    35.0,
                                    160.0,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_rounded, size: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Pengaturan Tinggi Badan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tinggi Badan (cm)',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () {
                                setModalState(
                                  () => tempHeight = (tempHeight - 1).clamp(
                                    120.0,
                                    220.0,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.remove_rounded, size: 16),
                            ),
                            Container(
                              width: 65,
                              alignment: Alignment.center,
                              child: Text(
                                '${tempHeight.toInt()} cm',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () {
                                setModalState(
                                  () => tempHeight = (tempHeight + 1).clamp(
                                    120.0,
                                    220.0,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_rounded, size: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Preview Skor BMI Baru
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Star.bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kalkulasi BMI Baru:',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Star.mut,
                            ),
                          ),
                          Text(
                            tempBmi.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Star.star,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: () {
                          triumphBuzz();
                          st.updateBodyProfile(tempWeight, tempHeight);
                          Navigator.pop(ctx);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Star.star,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Simpan Perubahan Fisik',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // 5. ENGINE SESI LATIHAN INTERAKTIF (WORKOUT PLAYER + SMART REST TIMER)
  // --------------------------------------------------------------------------
  void _launchActiveWorkoutSession(BuildContext context, AppState st) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LiveChoiceWorkoutModal(
        exercises: _exercises,
        targetDurationMinutes: _targetDurationMinutes,
        onFinishWorkout: (completedSets, totalSets) {
          // Anti-grinding: klaim lewat buku besar XP harian (1x per
          // hari, ikut direset pukul 00.00; bypass reset manual centang).
          final ok = st.claimXp('choice_plan', 60);
          if (ok) {
            showEpicCelebrationDialog(
              context: context,
              title: 'Sesi Choice Plan Tuntas!',
              message: 'Target gerakan selesai maksimal. Segera minum air dan konsumsi protein untuk pemulihan otot.',
              xpReward: 60,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Bonus Choice Plan hari ini sudah diklaim sebelumnya (+60 XP) — kuota kembali setelah reset pukul 00.00.',
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Star.star,
              ),
            );
          }
        },
      ),
    );
  }
}

// ============================================================================
// LIVE MODAL PLAYER: MODE LATIHAN BERJALAN & JEDA ISTIRAHAT FLEKSIBEL
// ============================================================================
class _LiveChoiceWorkoutModal extends StatefulWidget {
  final List<ChoiceExercise> exercises;
  final int targetDurationMinutes;
  final void Function(int completedSets, int totalSets) onFinishWorkout;

  const _LiveChoiceWorkoutModal({
    required this.exercises,
    required this.targetDurationMinutes,
    required this.onFinishWorkout,
  });

  @override
  State<_LiveChoiceWorkoutModal> createState() =>
      _LiveChoiceWorkoutModalState();
}

class _LiveChoiceWorkoutModalState extends State<_LiveChoiceWorkoutModal> {
  int _currentExIdx = 0;
  int _currentSetNum = 1;

  // Status Latihan (Work vs Rest)
  bool _isResting = false;
  int _restSecondsLeft = 0;
  int _initialRestSeconds = 60;
  Timer? _restTimer;

  // Stopwatch Durasi Sesi
  int _elapsedSessionSeconds = 0;
  Timer? _sessionTimer;

  // Checklist set yang telah selesai
  late List<List<bool>> _completedMatrix;

  @override
  void initState() {
    super.initState();
    _completedMatrix = widget.exercises
        .map((e) => List.filled(e.sets, false))
        .toList();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _elapsedSessionSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }

  int get _totalSets => widget.exercises.fold(0, (acc, e) => acc + e.sets);
  int get _completedSets => _completedMatrix.fold(
    0,
    (acc, list) => acc + list.where((b) => b).length,
  );

  // Menyelesaikan set saat ini dan berpindah ke rest mode
  void _completeCurrentSet() {
    iosTapBuzz();
    final ex = widget.exercises[_currentExIdx];
    setState(() {
      _completedMatrix[_currentExIdx][_currentSetNum - 1] = true;
    });

    // Cek apakah seluruh latihan sudah tuntas
    if (_completedSets >= _totalSets) {
      _finishEntireWorkout();
      return;
    }

    // Mulai jeda istirahat (Rest Mode)
    _startRestTimer(ex.restSeconds);
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _restSecondsLeft = seconds;
      _initialRestSeconds = seconds > 0 ? seconds : 60;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSecondsLeft <= 1) {
        t.cancel();
        triumphBuzz();
        _advanceToNextSetOrExercise();
      } else {
        if (mounted) {
          setState(() => _restSecondsLeft--);
        }
      }
    });
  }

  // Tambah Rest (+30 Detik)
  void _addRestTime(int extraSeconds) {
    iosTapBuzz();
    setState(() {
      _restSecondsLeft += extraSeconds;
      if (_restSecondsLeft > _initialRestSeconds) {
        _initialRestSeconds = _restSecondsLeft;
      }
    });
  }

  // Kurangi Rest (-15 Detik)
  void _reduceRestTime(int reduceSeconds) {
    iosTapBuzz();
    if (_restSecondsLeft <= reduceSeconds) {
      _skipRestAndAdvance();
    } else {
      setState(() {
        _restSecondsLeft -= reduceSeconds;
      });
    }
  }

  // Lewati istirahat dan lanjut ke gerakan / set berikutnya langsung
  void _skipRestAndAdvance() {
    iosTapBuzz();
    _restTimer?.cancel();
    _advanceToNextSetOrExercise();
  }

  void _advanceToNextSetOrExercise() {
    final ex = widget.exercises[_currentExIdx];
    if (_currentSetNum < ex.sets) {
      // Masih ada set di gerakan ini
      setState(() {
        _isResting = false;
        _currentSetNum++;
      });
    } else {
      // Gerakan ini selesai, pindah ke gerakan berikutnya jika masih ada
      if (_currentExIdx < widget.exercises.length - 1) {
        setState(() {
          _isResting = false;
          _currentExIdx++;
          _currentSetNum = 1;
        });
      } else {
        // Semua gerakan tuntas
        _finishEntireWorkout();
      }
    }
  }

  void _finishEntireWorkout() {
    _restTimer?.cancel();
    _sessionTimer?.cancel();
    triumphBuzz();
    Navigator.pop(context);
    widget.onFinishWorkout(_completedSets, _totalSets);
  }

  String _formatSeconds(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercises[_currentExIdx];
    final double overallProgress = _totalSets > 0
        ? (_completedSets / _totalSets).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Star.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Indicator
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Star.sunken,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Header Sesi: Stopwatch & Tombol Tutup
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Star.star.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer_rounded,
                            size: 14,
                            color: Star.star,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatSeconds(_elapsedSessionSeconds),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Star.star,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Gerakan ${_currentExIdx + 1} dari ${widget.exercises.length}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.5,
                        color: Star.mut,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Star.mut),
                ),
              ],
            ),
          ),

          // Progress Bar Keseluruhan Set
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progres Sesi: $_completedSets / $_totalSets Set Tuntas',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Star.mut,
                      ),
                    ),
                    Text(
                      '${(overallProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Star.star,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 6,
                    backgroundColor: Star.sunken,
                    valueColor: const AlwaysStoppedAnimation(Star.star),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Star.sunken),

          // BODY: TAMPILAN SESI LATIHAN ATAU JEDA ISTIRAHAT (REST SCREEN)
          Expanded(
            child: _isResting
                ? _buildActiveRestScreen(ex)
                : _buildActiveWorkScreen(ex),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAMPILAN FASE KERJA (WORK PHASE)
  // --------------------------------------------------------------------------
  Widget _buildActiveWorkScreen(ChoiceExercise ex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Badge Target Otot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Star.star.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              ex.targetMuscle,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Star.star,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nama Gerakan
          Text(
            ex.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Star.ink,
            ),
          ),
          const SizedBox(height: 16),

          // Card Set & Target Repetisi Besar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: Neu.raised(r: 16, d: 5),
            child: Column(
              children: [
                Text(
                  'SET $_currentSetNum DARI ${ex.sets}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Star.star,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${ex.reps}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Star.ink,
                  ),
                ),
                const Text(
                  'TARGET REPETISI',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Star.mut,
                    letterSpacing: 0.8,
                  ),
                ),
                if (ex.workSeconds > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Star.star.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Waktu: ${ex.workSeconds} Detik / Set',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Star.star,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Petunjuk Form Gerakan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: Neu.raised(r: 14, d: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, size: 18, color: Star.star),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ex.tip,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11.5,
                      color: Star.ink,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Tombol Selesai Set Ini
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _completeCurrentSet,
              icon: const Icon(Icons.check_circle_rounded, size: 22),
              label: Text(
                'Selesai Set $_currentSetNum (Mulai Rest)',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Star.star,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAMPILAN FASE ISTIRAHAT (SMART REST SCREEN DENGAN TAMBAH / LEWATI REST)
  // --------------------------------------------------------------------------
  Widget _buildActiveRestScreen(ChoiceExercise ex) {
    final double restProgress = _initialRestSeconds > 0
        ? (_restSecondsLeft / _initialRestSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Banner Jeda Istirahat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Star.star.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_top_rounded, size: 16, color: Star.star),
                SizedBox(width: 6),
                Text(
                  'Jeda Pemulihan Otot (Rest)',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Star.star,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lingkaran Countdown Rest Timer Elegan
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: restProgress,
                  strokeWidth: 10,
                  backgroundColor: Star.sunken,
                  valueColor: const AlwaysStoppedAnimation(Star.star),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_restSecondsLeft',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: Star.ink,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'DETIK',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Star.mut,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tombol Kontrol Tambah / Kurangi Rest Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _reduceRestTime(15),
                icon: const Icon(Icons.remove_rounded, size: 16),
                label: const Text('-15s Rest'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Star.mut,
                  side: const BorderSide(color: Star.sunken),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: () => _addRestTime(30),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  '+30s Tambah Rest',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Star.star.withValues(alpha: 0.15),
                  foregroundColor: Star.star,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Petunjuk Pemulihan & Gerakan Selanjutnya
          Container(
            padding: const EdgeInsets.all(12),
            decoration: Neu.raised(r: 14, d: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.air_rounded, size: 16, color: Star.star),
                    SizedBox(width: 6),
                    Text(
                      'Tips Recovery:',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Star.star,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tarik napas dalam dari hidung 4 detik, hembuskan perlahan dari mulut. Minum seteguk air jika haus.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: Star.ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentSetNum < ex.sets
                      ? 'Berikutnya: Set ${_currentSetNum + 1} ${ex.name} (${ex.reps} Reps)'
                      : _currentExIdx < widget.exercises.length - 1
                      ? 'Berikutnya: ${widget.exercises[_currentExIdx + 1].name}'
                      : 'Berikutnya: Sesi Selesai (Pendinginan)',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Star.mut,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Tombol Lanjut ke Gerakan / Set Berikutnya (Skip Rest)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _skipRestAndAdvance,
              icon: const Icon(Icons.fast_forward_rounded, size: 20),
              label: Text(
                _currentSetNum < ex.sets
                    ? 'Lanjut ke Set ${_currentSetNum + 1}'
                    : 'Lanjut ke Gerakan Berikutnya',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Star.star,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
