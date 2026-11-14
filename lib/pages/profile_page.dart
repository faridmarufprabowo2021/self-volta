import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../services/backup_service.dart';
import '../services/todo_notifications.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'notif_settings_sheet.dart';

/// Legenda skala BMI (dipakai di Wrap agar tidak ada "·" menggantung).
const TextStyle _bmiLegend = TextStyle(
  fontFamily: 'Manrope',
  fontSize: 10.5,
  height: 1.35,
  color: Star.faint,
);

/// Halaman Profil & Achievement System (Gamifikasi Lengkap)
/// Menggantikan tab Menu dengan halaman profil yang kaya data visual,
/// level progres, streak api, statistik aktivitas, dan sistem lencana pencapaian.
class ProfilePage extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const ProfilePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        final st = AppState.I;
        final currentLvl = st.level;
        final xpInLvl = st.xpInLevel;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // ============================================================
            // 1. HERO USER PROFILE CARD (Avatar, Level, Nickname)
            // ============================================================
            _buildUserHeroCard(st, currentLvl, xpInLvl),
            const SizedBox(height: 16),

            // ============================================================
            // 2. BMI TRACKER & BODY COMPOSITION (BARU)
            // ============================================================
            _buildBmiCard(context, st),
            const SizedBox(height: 16),

            // ============================================================
            // 3. KEBUTUHAN ASUPAN HARIAN (TDEE & MAKRONUTRIEN TERPUSAT)
            // ============================================================
            _buildDailyNutrientIntakeHub(context, st),
            const SizedBox(height: 16),

            // ============================================================
            // 3. VISUAL DATA STATS: RINGKASAN DISIPLIN 4 METRIK
            // ============================================================
            _buildVisualStatsGrid(st),
            const SizedBox(height: 16),

            // ============================================================
            // 3. GRAFIK BATANG AKTIVITAS MINGGUAN (Weekly Consistency Chart)
            // ============================================================
            _buildWeeklyActivityChart(),
            const SizedBox(height: 16),

            // ============================================================
            // 4. SISTEM ACHIEVEMENTS / LENCANA PENCAPAIAN LENGKAP
            // ============================================================
            _buildAchievementsSection(context, st),
            const SizedBox(height: 16),

            // ============================================================
            // 5. MENU PENGATURAN & QUICK LINKS
            // ============================================================
            _buildSettingsQuickSection(context),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // 1. HERO USER PROFILE CARD
  // -------------------------------------------------------------
  Widget _buildUserHeroCard(AppState st, int currentLvl, int xpInLvl) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Star.star.withValues(alpha: .08),
                  shape: BoxShape.circle,
                ),
                child: const VLogo(size: 32, fontSize: 16),
              ),
              const SizedBox(width: 14),
              // Nama & Level Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volta Warrior',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 21,
                        height: 1.2,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Level $currentLvl · ${st.levelTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Star.mut,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: Star.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${st.streak} hari beruntun',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Star.mut,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // XP Level Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menuju Level ${currentLvl + 1}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Star.mut,
                    ),
                  ),
                  Text(
                    '$xpInLvl / ${st.targetXpInLevel} XP',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Star.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: st.levelProgress,
                  minHeight: 6,
                  backgroundColor: Star.fillStrong,
                  valueColor: const AlwaysStoppedAnimation(Star.star),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. VISUAL STATS GRID (4 Metrik Utama)
  // -------------------------------------------------------------
  Widget _buildVisualStatsGrid(AppState st) {
    int workoutCount = 0;
    st.workoutDone.forEach((k, v) {
      if (v == true) workoutCount++;
    });

    return Row(
      children: [
        Expanded(
          child: _statTile(
            label: 'Total XP',
            value: '${st.xp} XP',
            icon: Icons.bolt_rounded,
            color: Star.star,
            bgColor: Star.star.withValues(alpha: 0.08),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statTile(
            label: 'Sesi Latihan',
            value: '$workoutCount Selesai',
            icon: Icons.fitness_center_rounded,
            color: Star.success,
            bgColor: Star.success.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: Neu.raised(r: 14, d: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: Star.mut,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Star.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. GRAFIK BATANG AKTIVITAS MINGGUAN (FL_CHART)
  // -------------------------------------------------------------
  Widget _buildWeeklyActivityChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: Star.nebula, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Aktivitas 7 Hari Terakhir',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Star.ink,
                    ),
                  ),
                ],
              ),
              Text(
                'Target 100%',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Star.faint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const days = [
                          'Sen',
                          'Sel',
                          'Rab',
                          'Kam',
                          'Jum',
                          'Sab',
                          'Min',
                        ];
                        final i = val.toInt();
                        if (i >= 0 && i < days.length) {
                          return Text(
                            days[i],
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10.5,
                              color: Star.mut,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _bar(0, 90, Star.nebula),
                  _bar(1, 100, Star.star),
                  _bar(2, 85, Star.nebula),
                  _bar(3, 95, Star.star),
                  _bar(4, 100, Star.star),
                  _bar(5, 75, Star.nebula),
                  _bar(6, 100, Star.star),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: Star.sunken,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 4. SISTEM ACHIEVEMENTS / LENCANA PENCAPAIAN
  // -------------------------------------------------------------
  // -------------------------------------------------------------
  // 4. SISTEM ACHIEVEMENTS / LENCANA PENCAPAIAN
  // -------------------------------------------------------------
  Widget _buildAchievementsSection(BuildContext context, AppState st) {
    int workoutCount = 0;
    st.workoutDone.forEach((k, v) {
      if (v == true) workoutCount++;
    });

    final achievements = [
      _AchItem(
        icon: Icons.flag_rounded,
        title: 'Pionir Disiplin',
        desc: 'Selesaikan 3 hari habit pertama berturut-turut.',
        isUnlocked: st.streak >= 3,
        xp: '+50 XP',
        progressText: '${st.streak.clamp(0, 3)}/3 Hari',
        progress: (st.streak / 3.0).clamp(0.0, 1.0),
      ),
      _AchItem(
        icon: Icons.local_fire_department_rounded,
        title: 'Streak Flame',
        desc: 'Pertahankan 7 hari disiplin tanpa putus (Rest Day terlindungi).',
        isUnlocked: st.streak >= 7,
        xp: '+100 XP',
        progressText: '${st.streak.clamp(0, 7)}/7 Hari',
        progress: (st.streak / 7.0).clamp(0.0, 1.0),
      ),
      _AchItem(
        icon: Icons.fitness_center_rounded,
        title: 'Spartan Workout',
        desc: 'Tuntaskan sesi latihan calisthenics 10 set.',
        isUnlocked: workoutCount >= 6,
        xp: '+150 XP',
        progressText: '$workoutCount/10 Gerakan',
        progress: (workoutCount / 10.0).clamp(0.0, 1.0),
      ),
      _AchItem(
        icon: Icons.soup_kitchen_rounded,
        title: 'Chef Rebus-Kukus',
        desc: 'Catat pola makan hemat anti-pedas konsisten.',
        isUnlocked: st.eaten.isNotEmpty,
        xp: '+80 XP',
        progressText: '${st.eaten.length.clamp(0, 7)}/7 Hari',
        progress: (st.eaten.length / 7.0).clamp(0.0, 1.0),
      ),
      _AchItem(
        icon: Icons.water_drop_rounded,
        title: 'Hydro Master',
        desc: 'Penuhi kebutuhan air galon 2.5L-3L per hari.',
        isUnlocked: true,
        xp: '+60 XP',
        progressText: 'Aktif Rutin',
        progress: 1.0,
      ),
      _AchItem(
        icon: Icons.piano_rounded,
        title: 'Target Melodi',
        desc: 'Tabungan target piano mencapai 50% (Rp750.000).',
        isUnlocked: (st.pianoTotal >= PIANO_TARGET / 2),
        xp: '+200 XP',
        progressText: '${rp(st.pianoTotal)} / Rp750rb',
        progress: (st.pianoTotal / (PIANO_TARGET / 2)).clamp(0.0, 1.0),
      ),
      _AchItem(
        icon: Icons.savings_rounded,
        title: 'Titan Hemat',
        desc: 'Catat transaksi dan pertahankan surplus budget belanja.',
        isUnlocked: (st.txns.isNotEmpty && st.sisaBudget > 0),
        xp: '+120 XP',
        progressText: '${st.txns.length.clamp(0, 10)}/10 Transaksi',
        progress: (st.txns.length / 10.0).clamp(0.0, 1.0),
      ),
      _AchItem(
        icon: Icons.workspace_premium_rounded,
        title: 'Volta Grandmaster',
        desc: 'Capai Level 5+ dan buktikan dedikasi penuh.',
        isUnlocked: (st.level >= 5),
        xp: '+500 XP',
        progressText: 'Level ${st.level}/5',
        progress: (st.level / 5.0).clamp(0.0, 1.0),
      ),
      _AchItem(
        icon: Icons.monitor_weight_rounded,
        title: 'Komposisi Ideal',
        desc:
            'Pertahankan skor BMI di rentang ideal Asia-Pasifik (18.5 - 22.9).',
        isUnlocked: (st.bmi >= 18.5 && st.bmi < 23.0),
        xp: '+100 XP',
        progressText: 'BMI ${st.bmi.toStringAsFixed(1)}',
        progress: (st.bmi >= 18.5 && st.bmi < 23.0) ? 1.0 : 0.6,
      ),
    ];

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.military_tech_rounded, color: Star.star, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Pencapaian',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Star.ink,
                    ),
                  ),
                ],
              ),
              Text(
                '$unlockedCount/${achievements.length} terbuka',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Star.faint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid 2 Kolom untuk Badge
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, idx) {
              final ach = achievements[idx];
              return _badgeCard(context, ach);
            },
          ),
        ],
      ),
    );
  }

  Widget _badgeCard(BuildContext context, _AchItem ach) {
    return InkWell(
      onTap: () {
        iosTapBuzz();
        _showBadgeDetail(context, ach);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ach.isUnlocked
              ? Star.star.withValues(alpha: 0.04)
              : Star.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ach.isUnlocked
                ? Star.star.withValues(alpha: 0.35)
                : Star.sunken,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  ach.icon,
                  size: 20,
                  color: ach.isUnlocked ? Star.star : Star.faint,
                ),
                if (!ach.isUnlocked)
                  const Icon(Icons.lock_rounded, size: 14, color: Star.faint)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Star.star.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ach.xp,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: Star.star,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              ach.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ach.isUnlocked ? Star.ink : Star.faint,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ach.progress,
                minHeight: 4,
                backgroundColor: Star.sunken,
                valueColor: AlwaysStoppedAnimation(
                  ach.isUnlocked ? Star.star : Star.faint,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              ach.isUnlocked ? 'Selesai' : ach.progressText,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: ach.isUnlocked ? Star.star : Star.mut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, _AchItem ach) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Star.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Star.sunken,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),
            Icon(
              ach.icon,
              size: 44,
              color: ach.isUnlocked ? Star.star : Star.faint,
            ),
            const SizedBox(height: 12),
            Text(
              ach.title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Star.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ach.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: Star.mut,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: ach.isUnlocked ? Paper.amberInk : Star.sunken,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ach.isUnlocked ? 'Lencana Terbuka • ${ach.xp}' : 'Terkunci',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ach.isUnlocked ? Star.star : Star.mut,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Star.star,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. SETTINGS QUICK SECTION
  // -------------------------------------------------------------
  Widget _buildSettingsQuickSection(BuildContext context) {
    return Container(
      decoration: Neu.raised(r: 18, d: 5),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.notifications_active_rounded,
                color: Star.star,
              ),
              title: const Text(
                'Notifikasi',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              subtitle: Text(
                '${TodoNotif.ready && TodoNotif.granted ? 'Aktif' : 'Belum diizinkan'} · '
                'nada: ${AppState.I.notifSoundLabel} · sisa ${AppState.I.notifSound == 'sistem' ? 'bawaan HP' : 'pilihanmu'}',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Star.faint,
              ),
              onTap: () => showNotifSettingsSheet(context),
            ),
            const Divider(height: 1, color: Star.sunken),
            ListTile(
              leading: const Icon(Icons.save_alt_rounded, color: Star.star),
              title: const Text(
                'Ekspor Data (JSON)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              subtitle: const Text(
                'Simpan salinan seluruh data ke file — wajib sebelum install ulang',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Star.faint,
              ),
              onTap: () => _exportData(context),
            ),
            const Divider(height: 1, color: Star.sunken),
            ListTile(
              leading: const Icon(Icons.file_open_rounded, color: Star.star),
              title: const Text(
                'Impor Data (JSON)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              subtitle: const Text(
                'Gabung atau timpa dari file cadangan (data sekarang dicadangkan dulu)',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Star.faint,
              ),
              onTap: () => _importData(context),
            ),
            const Divider(height: 1, color: Star.sunken),
            ListTile(
              title: const Text(
                'Reset Data Workout',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              subtitle: const Text(
                'Hapus centang latihan hari ini (kuota XP menunggu reset 00.00)',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Star.faint,
              ),
              onTap: () {
                AppState.I.resetWorkout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Centang latihan hari ini telah dihapus — bonus XP tidak bisa diklaim ulang sampai 00.00',
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: Star.sunken),
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded, color: Star.error),
              title: const Text(
                'Mulai Ulang Program (Reset Total)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: Star.error,
                ),
              ),
              subtitle: const Text(
                'Reset level, XP, centang makan, dan seluruh data ke awal',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Star.error,
              ),
              onTap: () => _showResetConfirmationDialog(context),
            ),
            const Divider(height: 1, color: Star.sunken),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: Star.star),
              title: const Text(
                'Tentang SELF VOLTA',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              subtitle: Text(
                'Versi $APP_VERSION • Offline First & Aman Privasi',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Star.faint,
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // EKSPOR / IMPOR CADANGAN (Fase 1 — data aman)
  // -------------------------------------------------------------
  Future<void> _exportData(BuildContext context) async {
    iosTapBuzz();
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Pastikan tulisan yang masih ditunda (debounce) sudah ke disk.
      await AppState.I.flushNow();
      final uri = await BackupService.exportToFile(AppState.I.exportJson());
      if (uri == null) return; // pengguna membatalkan dialog
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Cadangan tersimpan. Simpan file itu di tempat aman.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('[Profil] ekspor gagal: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal ekspor: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Star.error,
        ),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    iosTapBuzz();
    final messenger = ScaffoldMessenger.of(context);
    final Map<String, dynamic> data;
    try {
      final text = await BackupService.pickJsonText();
      if (text == null) return; // pengguna membatalkan dialog
      data = BackupService.validate(text);
    } on FormatException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('File ditolak: ${e.message}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Star.error,
        ),
      );
      return;
    } catch (e) {
      debugPrint('[Profil] impor tidak bisa dibaca: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal membaca file: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Star.error,
        ),
      );
      return;
    }
    if (!context.mounted) return;

    final summary = BackupService.summarize(data);
    // 0 = batal, 1 = gabung, 2 = timpa
    final mode = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.restore_rounded, color: Star.star, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pulihkan dari file ini?',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.description,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              _restoreModeNote(
                Icons.merge_type_rounded,
                'Gabung',
                'Transaksi, to-do, catatan makan, dan tabungan ditambahkan '
                    'tanpa duplikat. XP, streak, budget, pemasukan, dan profil '
                    'tetap memakai data yang sekarang — tidak dijumlah.',
              ),
              const SizedBox(height: 10),
              _restoreModeNote(
                Icons.swap_horiz_rounded,
                'Timpa',
                'Seluruh data sekarang diganti isi file. Pakai saat pindah HP '
                    'atau setelah install ulang.',
              ),
              const SizedBox(height: 14),
              const Text(
                'Data sekarang otomatis disalin ke cadangan internal '
                '(sv_v1_bak) sebelum proses, jadi masih bisa dikembalikan.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  height: 1.4,
                  color: Star.mut,
                ),
              ),
            ],
          ),
        ),
        actionsOverflowButtonSpacing: 4,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 0),
            child: const Text(
              'Batal',
              style: TextStyle(color: Star.mut, fontWeight: FontWeight.w700),
            ),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 1),
            style: OutlinedButton.styleFrom(
              foregroundColor: Star.star,
              side: const BorderSide(color: Star.star),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Gabung',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 2),
            style: FilledButton.styleFrom(
              backgroundColor: Star.star,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Timpa',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (mode == null || mode == 0) return;

    try {
      if (mode == 1) {
        await AppState.I.mergeJson(data);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Data digabung: ${summary.description}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Star.success,
          ),
        );
      } else {
        await AppState.I.importJson(data);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Data dipulihkan: ${summary.description}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Star.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('[Profil] impor gagal: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Impor gagal, data lama tetap utuh. ($e)'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Star.error,
        ),
      );
    }
  }

  /// Satu baris penjelasan mode pemulihan di dialog impor.
  Widget _restoreModeNote(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Star.star),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  height: 1.4,
                  color: Star.mut,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    iosTapBuzz();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Star.error, size: 24),
            SizedBox(width: 8),
            Text(
              'Reset Total Program?',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          'Tindakan ini akan mengembalikan level, XP, riwayat centang makan/workout, dan catatan keuangan ke kondisi awal (Fresh Start).\n\nApakah Anda yakin ingin memulai ulang program dari nol?',
          textAlign: TextAlign.justify,
          style: TextStyle(fontFamily: 'Manrope', fontSize: 12.5, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: Star.mut, fontWeight: FontWeight.w700),
            ),
          ),
          FilledButton(
            onPressed: () async {
              triumphBuzz();
              Navigator.pop(ctx);
              await AppState.I.resetAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Seluruh data program dan XP telah berhasil direset ke awal.',
                    ),
                    backgroundColor: Star.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Star.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Ya, Reset Total',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // BMI TRACKER & BODY COMPOSITION
  // -------------------------------------------------------------
  Widget _buildBmiCard(BuildContext context, AppState st) {
    final bmi = st.bmi;
    final cat = st.bmiCategory;

    Color catColor;
    if (bmi < 18.5) {
      catColor = Star.star;
    } else if (bmi < 23.0) {
      catColor = Star.success;
    } else if (bmi < 25.0) {
      catColor = Star.star;
    } else {
      catColor = Star.error;
    }

    final double spectrumRatio = ((bmi - 14.0) / (30.0 - 14.0)).clamp(
      0.02,
      0.98,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Star.star.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.monitor_weight_rounded,
                        color: Star.star,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Massa tubuh (BMI)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: Star.ink,
                            ),
                          ),
                          Text(
                            'Standar Asia-Pasifik · WHO',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
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
                onTap: () {
                  iosTapBuzz();
                  _showBiometricSettingsSheet(context, st);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Star.fill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ubah',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Star.star,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bmi.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 34,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                  color: Star.ink,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'kg/m²',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Star.mut,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${st.weightKg.toStringAsFixed(0)} kg · ${st.heightCm.toStringAsFixed(0)} cm',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Star.ink,
                    ),
                  ),
                  Text(
                    cat,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: catColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Spektrum BMI: satu track tipis + penanda posisi (tanpa pelangi).
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return SizedBox(
                height: 18,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 6,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Star.fillStrong,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (w * spectrumRatio - 6).clamp(0.0, w - 12),
                      top: 3,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Star.ink,
                          shape: BoxShape.circle,
                          border: Border.all(color: Star.surface, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          // Wrap: pemisah "·" tetap menempel, tidak menggantung di ujung baris.
          const Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              Text('Kurus < 18.5', style: _bmiLegend),
              Text('Ideal 18.5–22.9', style: _bmiLegend),
              Text('Lebih 23–24.9', style: _bmiLegend),
              Text('Obesitas ≥ 25', style: _bmiLegend),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Star.fill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: Star.star,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target BB ideal: ${st.minIdealWeight.toStringAsFixed(1)} – ${st.maxIdealWeight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Star.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        st.bmiRecommendation,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: Star.mut,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperInputRow({
    required String label,
    required String valueStr,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: Neu.raised(r: 14, d: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Star.ink,
            ),
          ),
          Row(
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: onMinus,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 75,
                child: Text(
                  valueStr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Star.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                icon: const Icon(Icons.add, size: 18),
                onPressed: onPlus,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KEBUTUHAN ASUPAN GIZI HARIAN (TDEE, BMR, MAKRONUTRIEN & ACUAN PORSI)
  // ============================================================
  Widget _buildDailyNutrientIntakeHub(BuildContext context, AppState st) {
    String goalTitle;
    String goalBadge;
    Color goalColor;
    if (st.fitnessGoal == 'muscle_gain') {
      goalTitle = 'Surplus Bersih Hypertrophy (+300 kkal)';
      goalBadge = 'Bulking Otot';
      goalColor = Star.star;
    } else if (st.fitnessGoal == 'fat_loss') {
      goalTitle = 'Defisit Cutting Aman (-350 kkal)';
      goalBadge = 'Bakar Lemak';
      goalColor = Star.star;
    } else {
      goalTitle = 'Pemeliharaan Seimbang (TDEE)';
      goalBadge = 'Maintenance';
      goalColor = Star.star;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: Neu.raised(r: 18, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Star.star.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Star.star,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asupan Harian',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Star.ink,
                            ),
                          ),
                          Text(
                            'Formula Mifflin-St Jeor',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10.5,
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
                onTap: () {
                  iosTapBuzz();
                  _showBiometricSettingsSheet(context, st);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Star.star.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Atur',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Star.star,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Total Calories Banner & BMR/TDEE Breakdown
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Star.fill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target kalori harian',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w500,
                              color: Star.mut,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${st.dailyCalories}',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 30,
                                    height: 1.05,
                                    letterSpacing: -0.8,
                                    fontWeight: FontWeight.w700,
                                    color: Star.ink,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'kkal / hari',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: goalColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        goalBadge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: goalColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  goalTitle,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Star.mut,
                  ),
                ),
                const Divider(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bed_rounded,
                            size: 14,
                            color: Star.mut,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'BMR: ${st.bmr} kkal',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Star.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 16, color: Star.lineSoft),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            size: 14,
                            color: Star.mut,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'TDEE: ${st.tdee} kkal',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Star.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4 Makronutrien Grid (Protein, Karbo, Lemak, Air)
          Row(
            children: [
              Expanded(
                child: _buildNutrientMiniCard(
                  icon: Icons.egg_alt_rounded,
                  iconColor: Star.star,
                  title: 'Protein',
                  valStr: '${st.dailyProtein}g',
                  subStr:
                      '${(st.dailyProtein / st.weightKg).toStringAsFixed(1)}g / kg BB',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNutrientMiniCard(
                  icon: Icons.grain_rounded,
                  iconColor: Star.star,
                  title: 'Karbohidrat',
                  valStr: '${st.dailyCarbs}g',
                  subStr: 'Energi Latihan',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNutrientMiniCard(
                  icon: Icons.shield_rounded,
                  iconColor: Star.star,
                  title: 'Lemak Sehat',
                  valStr: '${st.dailyFat}g',
                  subStr: 'Hormon & Sendi',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNutrientMiniCard(
                  icon: Icons.water_drop_rounded,
                  iconColor: Star.star,
                  title: 'Air Galon',
                  valStr: '${(st.dailyWaterMl / 1000.0).toStringAsFixed(1)} L',
                  subStr: '±${(st.dailyWaterMl / 250).round()} Gelas',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ACUAN RESMI 1 KALI MAKAN (Sesuai Permintaan User)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: Neu.raised(r: 14, d: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.bookmark_added_rounded,
                      size: 16,
                      color: Star.star,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Acuan 1 Kali Makan (3x Sehari)',
                        maxLines: 2,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Star.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPorsiChip(
                      'Protein',
                      '${st.mealTargetProtein}g',
                      Star.star,
                    ),
                    _buildPorsiChip(
                      'Kalori',
                      '${st.mealTargetCalories} kkal',
                      Star.star,
                    ),
                    _buildPorsiChip(
                      'Karbo',
                      '${st.mealTargetCarbs}g',
                      Star.star,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Acuan ini otomatis disinkronkan ke Planning Makan saat Anda meracik menu kustom, lengkap dengan notice interaktif apakah protein Anda sudah cukup atau masih kurang.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    color: Star.mut,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPorsiChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
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
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientMiniCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String valStr,
    required String subStr,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Star.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: Star.mut,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  valStr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Star.ink,
                  ),
                ),
                // FittedBox: teks panjang ("Hormon & Sendi") mengecil sedikit,
                // bukan terpotong elipsis di kartu sempit.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subStr,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10.5,
                      color: Star.mut,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBiometricSettingsSheet(BuildContext context, AppState st) {
    double tempWeight = st.weightKg;
    double tempHeight = st.heightCm;
    int tempAge = st.userAge;
    String tempGender = st.userGender;
    String tempActivity = st.activityLevel;
    String tempGoal = st.fitnessGoal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final previewH = tempHeight > 0 ? tempHeight / 100.0 : 1.7;
            final previewBmi = tempWeight / (previewH * previewH);

            int calcBmr() {
              if (tempHeight <= 0 || tempWeight <= 0) return 1550;
              if (tempGender == 'wanita') {
                return ((10 * tempWeight) +
                        (6.25 * tempHeight) -
                        (5 * tempAge) -
                        161)
                    .round();
              }
              return ((10 * tempWeight) +
                      (6.25 * tempHeight) -
                      (5 * tempAge) +
                      5)
                  .round();
            }

            int calcTdee() {
              double mult = 1.375;
              if (tempActivity == 'sedentary') mult = 1.2;
              if (tempActivity == 'active') mult = 1.55;
              return (calcBmr() * mult).round();
            }

            int calcDailyCalories() {
              final t = calcTdee();
              if (tempGoal == 'muscle_gain') return t + 300;
              if (tempGoal == 'fat_loss') return (t - 350).clamp(1200, 4000);
              return t;
            }

            int calcDailyProtein() {
              double mult = 1.9;
              if (tempGoal == 'muscle_gain') mult = 2.0;
              if (tempGoal == 'fat_loss') mult = 2.2;
              return (tempWeight * mult).round().clamp(60, 250);
            }

            final prevBmr = calcBmr();
            final prevTdee = calcTdee();
            final prevCal = calcDailyCalories();
            final prevPro = calcDailyProtein();
            final prevMealCal = (prevCal / 3.0).round();
            final prevMealPro = (prevPro / 3.0).round();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                decoration: const BoxDecoration(
                  color: Star.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
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
                    const SizedBox(height: 16),
                    const Text(
                      'Parameter Fisik & Target Asupan Gizi',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Data ini digunakan untuk menghitung BMR, TDEE, serta acuan nutrisi saat meracik menu di Planning Makan.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: Star.mut,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LIVE PREVIEW HUB
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: Neu.well(r: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Target Kalori',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 10,
                                      color: Star.mut,
                                    ),
                                  ),
                                  Text(
                                    '$prevCal kkal',
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Star.star,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 26,
                                color: Star.star.withValues(alpha: 0.2),
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Target Protein',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 10,
                                      color: Star.mut,
                                    ),
                                  ),
                                  Text(
                                    '${prevPro}g / hari',
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Star.star,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 26,
                                color: Star.star.withValues(alpha: 0.2),
                              ),
                              Column(
                                children: [
                                  const Text(
                                    '1x Makan',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 10,
                                      color: Star.mut,
                                    ),
                                  ),
                                  Text(
                                    '${prevMealPro}g / ${prevMealCal}k',
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Star.star,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'BMI: ${previewBmi.toStringAsFixed(1)} • BMR: $prevBmr kkal • TDEE: $prevTdee kkal',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10.5,
                              color: Star.mut,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Berat & Tinggi Badan Stepper
                    _stepperInputRow(
                      label: 'Berat Badan',
                      valueStr: '${tempWeight.toStringAsFixed(1)} kg',
                      onMinus: () {
                        if (tempWeight > 35) {
                          setModalState(() => tempWeight -= 0.5);
                          iosTapBuzz();
                        }
                      },
                      onPlus: () {
                        if (tempWeight < 180) {
                          setModalState(() => tempWeight += 0.5);
                          iosTapBuzz();
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    _stepperInputRow(
                      label: 'Tinggi Badan',
                      valueStr: '${tempHeight.toStringAsFixed(0)} cm',
                      onMinus: () {
                        if (tempHeight > 100) {
                          setModalState(() => tempHeight -= 1);
                          iosTapBuzz();
                        }
                      },
                      onPlus: () {
                        if (tempHeight < 230) {
                          setModalState(() => tempHeight += 1);
                          iosTapBuzz();
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    _stepperInputRow(
                      label: 'Usia Pengguna',
                      valueStr: '$tempAge tahun',
                      onMinus: () {
                        if (tempAge > 14) {
                          setModalState(() => tempAge -= 1);
                          iosTapBuzz();
                        }
                      },
                      onPlus: () {
                        if (tempAge < 80) {
                          setModalState(() => tempAge += 1);
                          iosTapBuzz();
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Jenis Kelamin Choice
                    const Text(
                      'Jenis Kelamin:',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('♂ Pria')),
                            selected: tempGender == 'pria',
                            selectedColor: Star.star,
                            labelStyle: TextStyle(
                              color: tempGender == 'pria'
                                  ? Star.onAccent
                                  : Star.ink,
                              fontWeight: FontWeight.w700,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => tempGender = 'pria');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('♀ Wanita')),
                            selected: tempGender == 'wanita',
                            selectedColor: Star.star,
                            labelStyle: TextStyle(
                              color: tempGender == 'wanita'
                                  ? Star.onAccent
                                  : Star.ink,
                              fontWeight: FontWeight.w700,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => tempGender = 'wanita');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Tingkat Aktivitas
                    const Text(
                      'Tingkat Aktivitas Harian:',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Santai (Sedentary 1.2x)'),
                          selected: tempActivity == 'sedentary',
                          selectedColor: Star.star,
                          labelStyle: TextStyle(
                            color: tempActivity == 'sedentary'
                                ? Star.onAccent
                                : Star.ink,
                            fontSize: 11,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => tempActivity = 'sedentary');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Rutin Kalistenik 3-4x (1.375x)'),
                          selected: tempActivity == 'moderate',
                          selectedColor: Star.star,
                          labelStyle: TextStyle(
                            color: tempActivity == 'moderate'
                                ? Star.onAccent
                                : Star.ink,
                            fontSize: 11,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => tempActivity = 'moderate');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Sangat Aktif / Atlet (1.55x)'),
                          selected: tempActivity == 'active',
                          selectedColor: Star.star,
                          labelStyle: TextStyle(
                            color: tempActivity == 'active'
                                ? Star.onAccent
                                : Star.ink,
                            fontSize: 11,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => tempActivity = 'active');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Target Kebugaran
                    const Text(
                      'Target Kebugaran / Goal:',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Bentuk Otot (+300 kkal)'),
                          selected: tempGoal == 'muscle_gain',
                          selectedColor: Star.star,
                          labelStyle: TextStyle(
                            color: tempGoal == 'muscle_gain'
                                ? Star.onAccent
                                : Star.ink,
                            fontSize: 11,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => tempGoal = 'muscle_gain');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Bakar Lemak (-350 kkal)'),
                          selected: tempGoal == 'fat_loss',
                          selectedColor: Star.star,
                          labelStyle: TextStyle(
                            color: tempGoal == 'fat_loss'
                                ? Star.onAccent
                                : Star.ink,
                            fontSize: 11,
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => tempGoal = 'fat_loss');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Jaga Berat / Performa'),
                          selected: tempGoal == 'maintenance',
                          selectedColor: Star.star,
                          labelStyle: TextStyle(
                            color: tempGoal == 'maintenance'
                                ? Star.onAccent
                                : Star.ink,
                            fontSize: 11,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => tempGoal = 'maintenance');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Dynamic Asupan Notice Box (Insight Kebutuhan Gizi & Choice Meal)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: Neu.well(r: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_rounded,
                            color: Star.star,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Insight Asupan Harian Kamu:',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Paper.amberInk,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '“OHH TERNYATA AKU BUTUH PROTEIN \${prevPro}g & \${prevCal} kkal! Satu porsi makan minimal butuh ~\${prevMealPro}g protein (misal: 2 butir telur + 50g tempe/ayam). Sekarang aku paham target nutrisiku!”',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Star.star,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          triumphBuzz();
                          st.updateBiometrics(
                            weight: tempWeight,
                            height: tempHeight,
                            age: tempAge,
                            gender: tempGender,
                            activity: tempActivity,
                            goal: tempGoal,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Parameter gizi diperbarui! Target: $prevCal kkal • ${prevPro}g Protein (1x Makan: ~${prevMealPro}g)',
                              ),
                              backgroundColor: Star.star,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Star.star,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Simpan Parameter Gizi & Biometrik',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Star.onAccent,
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
}

class _AchItem {
  final IconData icon;
  final String title;
  final String desc;
  final bool isUnlocked;
  final String xp;
  final String progressText;
  final double progress;

  _AchItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.isUnlocked,
    required this.xp,
    required this.progressText,
    required this.progress,
  });
}
