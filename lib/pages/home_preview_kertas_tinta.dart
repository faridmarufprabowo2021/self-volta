import 'package:flutter/material.dart';

import '../data.dart';
import '../store.dart';
import '../widgets.dart';

/// Halaman Preview Beranda: Konsep "Kertas & Tinta" (Standalone Preview)
/// Tanpa menyentuh home_page.dart asli agar tidak bentrok dengan proses build lain.
class HomePreviewKertasTintaPage extends StatefulWidget {
  final ValueChanged<String>? onNavigate;

  const HomePreviewKertasTintaPage({super.key, this.onNavigate});

  @override
  State<HomePreviewKertasTintaPage> createState() =>
      _HomePreviewKertasTintaPageState();
}

class _HomePreviewKertasTintaPageState
    extends State<HomePreviewKertasTintaPage> {
  bool _showAllPrayers = false;

  // Palet Khusus Desain Kertas & Tinta
  static const Color kCanvas = Color(0xFFF8F9FA);
  static const Color kCardWhite = Color(0xFFFFFFFF);
  static const Color kBorder = Color(0xFFE8ECEF);
  static const Color kNavyAnchor = Color(0xFF143E48); // Deep Petrol Navy
  static const Color kNavyText = Color(0xFF143E48);
  static const Color kSlate = Color(0xFF6B7280);
  static const Color kAmber = Color(0xFFF5A623); // Progres / Energi
  static const Color kAmberDark = Color(
    0xFFB45309,
  ); // Jam/Terlewat kontras tinggi
  static const Color kCyanPill = Color(0xFFEBF5F8);
  static const Color kCyanActive = Color(0xFF0284C7);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        final now = DateTime.now();
        final hariName = (now.weekday >= 1 && now.weekday <= 7)
            ? HARI_ID[now.weekday]
            : '';
        final bulanName = (now.month >= 1 && now.month <= 12)
            ? BULAN_ID[now.month]
            : '';
        final dateKicker = '$hariName, ${now.day} $bulanName ${now.year}'
            .toUpperCase();

        final boosterKey = 'boost_${now.year}_${now.month}_${now.day}';
        final waterKey = 'water_${now.year}_${now.month}_${now.day}';
        final mealKey = 'pola_${now.year}_${now.month}_${now.day}';
        final bool isBoosterDone = AppState.I.eaten[boosterKey] ?? false;
        final bool isWaterDone = AppState.I.eaten[waterKey] ?? false;
        final bool isMealDone = AppState.I.eaten[mealKey] ?? false;

        final todos = AppState.I.todos;
        final int todoDone = todos.where((t) => t.done).length;
        const int totalHabits = 3;
        final int habitsDone =
            (isMealDone ? 1 : 0) +
            (isBoosterDone ? 1 : 0) +
            (isWaterDone ? 1 : 0);
        final int totalItems = totalHabits + todos.length;
        final int doneItems = habitsDone + todoDone;

        return Scaffold(
          backgroundColor: kCanvas,
          appBar: AppBar(
            backgroundColor: kCanvas,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: kNavyText),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'SELF VOLTA',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 1.5,
                color: kNavyText,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.bookmark_outline_rounded,
                  color: kNavyText,
                  size: 22,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: kNavyText,
                  size: 22,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // 1. HEADER (KOP): Label tanggal kapital + Greeting + Badge Level XP (Streak palsu dihilangkan)
              _buildHeader(dateKicker),
              const SizedBox(height: 16),

              // 2. KARTU JANGKAR SHOLAT (Navy #143E48)
              _buildPrayerAnchorCard(),
              const SizedBox(height: 16),

              // 3. KARTU HARI INI (Gabungan Target & To-Do, Single Style)
              _buildTodayUnifiedCard(
                totalItems: totalItems,
                doneItems: doneItems,
                isMealDone: isMealDone,
                isBoosterDone: isBoosterDone,
                isWaterDone: isWaterDone,
                mealKey: mealKey,
                boosterKey: boosterKey,
                waterKey: waterKey,
                todos: todos,
              ),
              const SizedBox(height: 16),

              // 4. PREVIEW BANNER KETERANGAN
              _buildInfoBanner(),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 1. HEADER (KOP)
  // ==========================================
  Widget _buildHeader(String dateKicker) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateKicker,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: kSlate,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Selamat Pagi',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: kNavyText,
              ),
            ),
            // Chip Level & XP (Border halus, tanpa emoji & streak palsu disembunyikan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kCardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
              ),
              child: Text(
                'Lv ${AppState.I.level} · ${AppState.I.xp} XP',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kSlate,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // 2. KARTU JANGKAR SHOLAT (Deep Petrol Navy)
  // ==========================================
  Widget _buildPrayerAnchorCard() {
    return Container(
      decoration: BoxDecoration(
        color: kNavyAnchor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kNavyAnchor.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Label Kicker & Lokasi/Cuaca
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BERIKUTNYA',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: const [
                  Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: Colors.white70,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Solo · 29° Cerah',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Waktu Sholat Utama & Hitung Mundur
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Dzuhur',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '11:23',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '3 j 9 m lagi',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bar Progres Tipis Sholat (Amber #F5A623)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(kAmber),
            ),
          ),
          const SizedBox(height: 16),

          // 5 Sholat Wajib Sejajar (Satu Baris)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _prayerTimeSlot('Subuh', '03:47', isActive: false),
              _prayerTimeSlot('Dzuhur', '11:23', isActive: true),
              _prayerTimeSlot('Ashar', '14:44', isActive: false),
              _prayerTimeSlot('Maghrib', '17:36', isActive: false),
              _prayerTimeSlot('Isya', '18:50', isActive: false),
            ],
          ),
          const SizedBox(height: 12),

          // Collapsible detail: Imsak, Terbit, Dhuha
          InkWell(
            onTap: () => setState(() => _showAllPrayers = !_showAllPrayers),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showAllPrayers
                        ? 'Tutup detail sholat'
                        : 'Imsak 03:37 · Terbit 05:07 · Dhuha 05:27',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showAllPrayers
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),

          if (_showAllPrayers) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _ExtraPrayerItem(label: 'Imsak', time: '03:37'),
                  _ExtraPrayerItem(label: 'Terbit', time: '05:07'),
                  _ExtraPrayerItem(label: 'Dhuha', time: '05:27'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _prayerTimeSlot(String name, String time, {required bool isActive}) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kNavyText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: kNavyText,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. KARTU HARI INI (Gabungan Target & To-Do)
  // ==========================================
  Widget _buildTodayUnifiedCard({
    required int totalItems,
    required int doneItems,
    required bool isMealDone,
    required bool isBoosterDone,
    required bool isWaterDone,
    required String mealKey,
    required String boosterKey,
    required String waterKey,
    required List<SvTask> todos,
  }) {
    final double ratio = totalItems > 0
        ? (doneItems / totalItems).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: kCardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kNavyText.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HARI INI',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: kSlate,
                  ),
                ),
                Text(
                  '$doneItems / $totalItems',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kNavyText,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4,
                backgroundColor: kBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(kAmber),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Sub-header 1: KEBIASAAN
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'KEBIASAAN',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                color: kSlate,
              ),
            ),
          ),

          _buildRowItem(
            title: 'Makan Teratur (Pola Hari Ini)',
            subtitle: 'Sarapan, makan siang & malam tuntas',
            isDone: isMealDone,
            timeBadge: null,
            isOverdue: false,
            onTap: () {
              iosTapBuzz();
              final next = !isMealDone;
              AppState.I.eaten[mealKey] = next;
              AppState.I.save();
            },
          ),
          _buildRowItem(
            title: 'Booster BB Naik (+1.110 kkal)',
            subtitle: 'Telur rebus / susu / pisang / madu harian',
            isDone: isBoosterDone,
            timeBadge: null,
            isOverdue: false,
            onTap: () {
              iosTapBuzz();
              final next = !isBoosterDone;
              AppState.I.eaten[boosterKey] = next;
              AppState.I.save();
            },
          ),
          _buildRowItem(
            title: 'Air Galon Minum (2.5L - 3L)',
            subtitle: 'Hidrasi hemat & bersih Rp5.000/galon',
            isDone: isWaterDone,
            timeBadge: null,
            isOverdue: false,
            onTap: () {
              iosTapBuzz();
              final next = !isWaterDone;
              AppState.I.eaten[waterKey] = next;
              AppState.I.save();
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 20, color: kBorder),
          ),

          // Sub-header 2: TUGAS
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'TUGAS & TO-DO',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                color: kSlate,
              ),
            ),
          ),

          if (todos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Belum ada tugas hari ini.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: kSlate,
                ),
              ),
            )
          else ...[
            for (final t in todos.take(4))
              _buildRowItem(
                title: t.title,
                subtitle: t.cat.isNotEmpty ? t.cat : 'Umum',
                isDone: t.done,
                timeBadge: t.timeMin > 0
                    ? '${(t.timeMin ~/ 60).toString().padLeft(2, '0')}.${(t.timeMin % 60).toString().padLeft(2, '0')}'
                    : null,
                isOverdue: !t.done && t.timeMin > 0,
                onTap: () {
                  iosTapBuzz();
                  AppState.I.toggleTodo(t.id);
                },
              ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Row tunggal konsisten untuk Kebiasaan & To-do
  Widget _buildRowItem({
    required String title,
    required String subtitle,
    required bool isDone,
    required String? timeBadge,
    required bool isOverdue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Lingkaran Centang 24dp (Navy border, Amber saat done)
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? kAmber : Colors.transparent,
                border: Border.all(
                  color: isDone ? kAmber : kNavyText.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: kNavyAnchor,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDone ? kSlate : kNavyText,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: kSlate,
                    ),
                  ),
                ],
              ),
            ),
            if (timeBadge != null) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeBadge,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kAmberDark,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (isOverdue)
                    const Text(
                      'Terlewat',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kAmberDark,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Banner keterangan preview
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCyanPill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCyanActive.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline_rounded, color: kCyanActive, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Halaman preview terpisah (Kertas & Tinta). Data asli (sholat, kebiasaan, todo) terhubung langsung tanpa mengganggu proses build utama.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF0369A1),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtraPrayerItem extends StatelessWidget {
  final String label;
  final String time;

  const _ExtraPrayerItem({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
