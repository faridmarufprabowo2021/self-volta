// Panduan Lengkap & Tutorial Aplikasi SELF VOLTA
// Mencakup SEMUA kategori: Latihan, Pola Makan, Keuangan, Booster, Profil & Gamifikasi

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class PanduanPage extends StatefulWidget {
  final void Function(String)? onNavigate;

  const PanduanPage({super.key, this.onNavigate});

  @override
  State<PanduanPage> createState() => _PanduanPageState();
}

class _PanduanPageState extends State<PanduanPage> {
  String _selectedCategory = 'all';

  final List<({String key, String label, IconData icon})> _categories = [
    (key: 'all', label: 'Semua Panduan', icon: Icons.apps_rounded),
    (
      key: 'latihan',
      label: 'Latihan & Choice Plan',
      icon: Icons.fitness_center_rounded,
    ),
    (
      key: 'makan',
      label: 'Pola Makan & Nutrisi',
      icon: Icons.soup_kitchen_rounded,
    ),
    (
      key: 'keuangan',
      label: 'Keuangan & Tabungan',
      icon: Icons.account_balance_wallet_rounded,
    ),
    (key: 'booster', label: 'Booster BB & Air Galon', icon: Icons.bolt_rounded),
    (
      key: 'profil',
      label: 'Profil, Level & Medali',
      icon: Icons.emoji_events_rounded,
    ),
    (
      key: 'navigasi',
      label: 'Navigasi & Alur Cepat',
      icon: Icons.explore_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              widget.onNavigate?.call('home');
            }
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panduan Aplikasi',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Star.ink,
              ),
            ),
            Text(
              'Tutorial Lengkap & Cara Pakai Fitur',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                color: Star.mut,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Star.sunken, height: 1),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Banner Hero Selamat Datang
          _buildHeroBanner(),
          const SizedBox(height: 16),

          // Horizontal Filter Kategori
          _buildCategoryFilter(),
          const SizedBox(height: 18),

          // Konten Panduan berdasarkan filter
          if (_selectedCategory == 'all' ||
              _selectedCategory == 'navigasi') ...[
            _buildNavigasiGuide(),
            const SizedBox(height: 16),
          ],
          if (_selectedCategory == 'all' || _selectedCategory == 'latihan') ...[
            _buildLatihanGuide(),
            const SizedBox(height: 16),
          ],
          if (_selectedCategory == 'all' || _selectedCategory == 'makan') ...[
            _buildMakanGuide(),
            const SizedBox(height: 16),
          ],
          if (_selectedCategory == 'all' ||
              _selectedCategory == 'keuangan') ...[
            _buildKeuanganGuide(),
            const SizedBox(height: 16),
          ],
          if (_selectedCategory == 'all' || _selectedCategory == 'booster') ...[
            _buildBoosterGuide(),
            const SizedBox(height: 16),
          ],
          if (_selectedCategory == 'all' || _selectedCategory == 'profil') ...[
            _buildProfilGuide(),
            const SizedBox(height: 16),
          ],

          // Footer Bantuan Tambahan
          _buildFooterHelpCard(),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // HERO BANNER
  // --------------------------------------------------------------------------
  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: Neu.raised(r: 22, d: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Paper.amberInk.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Paper.amberInk.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb_rounded, size: 14, color: Paper.amberInk),
                SizedBox(width: 5),
                Text(
                  'PUSAT PANDUAN & USER FLOW',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Paper.amberInk,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Selamat Datang di SELF VOLTA',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Star.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aplikasi pendamping disiplin harian untuk menaikkan berat badan, membangun massa otot kalistenik tanpa alat, dan mengelola keuangan hemat mahasiswa.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              color: Star.ink,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // CATEGORY FILTER
  // --------------------------------------------------------------------------
  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSel = _selectedCategory == cat.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat.label),
              selected: isSel,
              onSelected: (val) {
                if (val) {
                  iosTapBuzz();
                  setState(() => _selectedCategory = cat.key);
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 1. PANDUAN NAVIGASI & ALUR CEPAT
  // --------------------------------------------------------------------------
  Widget _buildNavigasiGuide() {
    return _buildSectionCard(
      title: 'Navigasi & Alur Cepat Aplikasi',
      subtitle: 'Memahami letak tombol dan navigasi agar tidak bingung',
      color: Star.star,
      steps: [
        (
          title: 'Menu Samping (Kiri Atas)',
          desc: 'Ikon garis tiga di pojok kiri atas membuka laci menu (Drawer) lengkap yang berisi semua halaman dan pengaturan.',
        ),
        (
          title: 'Profil & Level (Kanan Atas)',
          desc: 'Badge level (Lv.X) di pojok kanan atas membawa Anda langsung ke Ruang Medali, Progres Streak, dan kalkulator BMI.',
        ),
        (
          title: 'Navbar Bawah 5 Tombol',
          desc: '1. Latihan (Gym/Kalistenik)\n2. Makan (Menu 4 Waktu & Katalog)\n3. Beranda (Dashboard Utama)\n4. Uang (Catatan Keuangan & Kalkulator)\n5. Menu (Buka Drawer samping)',
        ),
        (
          title: 'Grid 8 Akses Cepat di Beranda',
          desc: 'Kotak ikon di beranda memudahkan Anda melompat langsung ke Cari Menu, Latihan, Keuangan, Tabung Piano, Air Galon, Booster BB, Tips Masak, dan Panduan ini.',
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 2. PANDUAN LATIHAN & CHOICE PLAN
  // --------------------------------------------------------------------------
  Widget _buildLatihanGuide() {
    return _buildSectionCard(
      title: 'Latihan Kalistenik & Fitur Choice Plan',
      subtitle: 'Pembentukan otot terukur tanpa alat & bebas cedera',
      color: Star.star,
      steps: [
        (
          title: 'Jadwal 3x Seminggu (Senin, Rabu, Jumat)',
          desc: 'Latihan sore jam 16.30 (minimal 2 jam setelah makan). Senin fokus Tarik Dekat & Dorong, Rabu Tarik Lebar & Kaki, Jumat Full Body. Hari lain adalah Rest Day untuk pemulihan sendi.',
        ),
        (
          title: 'Hero Card: Choice Plan (Kustom Hari Ini)',
          desc: 'Ketuk tombol "Choice Plan" di halaman Latihan jika ingin menentukan sendiri latihan hari ini. Anda bebas memilih split target (Push, Pull, Legs, Core, atau Rancang Sendiri).',
        ),
        (
          title: 'Kustomisasi Repetisi, Set & Durasi',
          desc: 'Setiap gerakan di Choice Plan memiliki stepper set (1-8 set) dan repetisi yang bisa diisi sendiri, target durasi jam/menit latihan, serta waktu jeda istirahat.',
        ),
        (
          title: 'Smart Rest Timer (+30s / Lewati)',
          desc: 'Saat latihan berjalan, selesai satu set akan memicu jeda istirahat visual. Anda bisa ketuk "+30s Tambah Rest" jika napas masih terengah, atau "Lanjut" untuk langsung ke gerakan berikutnya.',
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 3. PANDUAN POLA MAKAN & NUTRISI
  // --------------------------------------------------------------------------
  Widget _buildMakanGuide() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: Neu.raised(r: 16, d: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Star.star.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.soup_kitchen_rounded,
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
                      'Tips & Panduan Cara Masak Kilat Kost',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Star.ink,
                      ),
                    ),
                    Text(
                      'Trik 15 menit makan enak, hemat & tinggi protein di kamar kos',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        color: Star.mut,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3-Step Cooking Workflow Timeline
          const Text(
            'Alur 3 Langkah Memasak Praktis (15 Menit):',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Star.star,
            ),
          ),
          const SizedBox(height: 8),
          _stepTimelineRow(
            '1',
            'Cuci Beras & Siapkan Bumbu (3 Menit)',
            'Cuci 1-2 cup beras di panci magic com. Kupas bawang putih & cabai lalu geprek/iris halus.',
          ),
          _stepTimelineRow(
            '2',
            'Trik Magic Com 2-in-1 (10 Menit)',
            'Taruh wadah kukusan plastik di atas beras. Masukkan telur utuh & irisan tempe/wortel. Nasi dan lauk matang bersamaan tanpa kompor tambahan!',
          ),
          _stepTimelineRow(
            '3',
            'Tumis Cepat di Wajan / Panci (2 Menit)',
            'Gunakan 1 sendok teh minyak goreng di panci listrik. Tumis bawang hingga harum lalu masukkan sayur kangkung/bayam selama 90 detik agar tetap renyah.',
          ),
          const SizedBox(height: 14),

          // Kost Kitchen Lifehacks
          Container(
            padding: const EdgeInsets.all(12),
            decoration: Neu.well(r: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 16, color: Star.star),
                    SizedBox(width: 6),
                    Text(
                      '3 Lifehacks Dapur Kost Hemat:',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Star.star,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _hackItem(
                  'Anti-Njepret Listrik Kos',
                  'Panci listrik gunakan mode 300 Watt saat menumis. Jangan gunakan bersamaan dengan setrika agar saklar MCB tidak turun.',
                ),
                _hackItem(
                  'Simpan Telur Tanpa Kulkas',
                  'Telur ayam tahan 14 hari di suhu ruang. Letakkan di wadah berventilasi (jangan dicuci air sebelum dimasak agar lapisan pelindung cangkang utuh).',
                ),
                _hackItem(
                  'Segarkan Sayur dengan Air',
                  'Rendam batang kangkung/bayam dalam toples berisi 2 cm air seperti tanaman hias. Daun tetap segar dan renyah selama 3 hari tanpa kulkas!',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Shortcut Buka Timer Masak
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _showQuickCookingTimerModal(context),
              icon: const Icon(Icons.timer_rounded, size: 16),
              label: const Text(
                '⏱Buka Stopwatch & Timer Masak Presisi',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Star.star.withValues(alpha: 0.14),
                foregroundColor: Star.star,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepTimelineRow(String stepNum, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Star.star,
              shape: BoxShape.circle,
            ),
            child: Text(
              stepNum,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Star.onAccent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Star.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  desc,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
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

  Widget _hackItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Star.ink,
            ),
          ),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 9.5,
              color: Star.mut,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickCookingTimerModal(BuildContext context) {
    iosTapBuzz();
    int secondsRemaining = 360;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final mins = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
            final secs = (secondsRemaining % 60).toString().padLeft(2, '0');

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Star.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '⏱Timer Masak Presisi Anak Kost',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Star.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Preset waktu ideal agar masakan matang sempurna & bernutrisi tinggi',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: Star.mut,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Timer Digital Display
                  Text(
                    '$mins:$secs',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: Star.star,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Presets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActionChip(
                        label: const Text(
                          'Telur 1/2 Matang (6m)',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: Star.star.withValues(alpha: 0.1),
                        onPressed: () {
                          iosTapBuzz();
                          setModalState(() => secondsRemaining = 360);
                        },
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text(
                          'Telur Matang (9m)',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: Star.star.withValues(alpha: 0.15),
                        onPressed: () {
                          iosTapBuzz();
                          setModalState(() => secondsRemaining = 540);
                        },
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text(
                          'Sayur (3m)',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: Star.success.withValues(alpha: 0.1),
                        onPressed: () {
                          iosTapBuzz();
                          setModalState(() => secondsRemaining = 180);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      iosTapBuzz();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Timer masak $mins:$secs telah disetel!',
                          ),
                          backgroundColor: Star.star,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text(
                      'Gunakan Timer',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Star.star,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // 4. PANDUAN KEUANGAN & TABUNGAN PIANO
  // --------------------------------------------------------------------------
  Widget _buildKeuanganGuide() {
    return _buildSectionCard(
      title: 'Keuangan Harian & Tabungan Piano',
      subtitle: 'Disiplin anggaran Rp50.000/hari & mencapai impian Rp1.500.000',
      color: Star.success,
      steps: [
        (
          title: 'Tombol Kalkulator Melayang ()',
          desc: 'Di halaman Keuangan, ada tombol kalkulator mengambang di pojok layar. Ketuk untuk menghitung dan mencatat pengeluaran secara cepat.',
        ),
        (
          title: 'Laporan Keuangan & Batas Jatah Harian',
          desc: 'Bagian atas menampilkan sisa uang bulan ini dan grafik kepatuhan jatah harian (Rp 50.000/hari) agar tidak boncos di akhir bulan.',
        ),
        (
          title: 'Shortcut Tabungan Piano (Target Rp1.500.000)',
          desc: 'Box khusus piano di atas halaman keuangan memudahkan Anda menabung mingguan. Cukup ketuk "+ Tabung Rp50rb" untuk menambah progres tabungan.',
        ),
        (
          title: 'Kalender Multifungsi Keuangan',
          desc: 'Di bagian bawah, kalender menampilkan total pengeluaran per tanggal. Ketuk tanggal manapun untuk melihat detail atau mencatat transaksi baru.',
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 5. PANDUAN BOOSTER BB & AIR GALON
  // --------------------------------------------------------------------------
  Widget _buildBoosterGuide() {
    return _buildSectionCard(
      title: 'Booster Berat Badan & Air Galon',
      subtitle: 'Nutrisi ekstra pembangun massa tubuh dan hidrasi optimal',
      color: Star.star,
      steps: [
        (
          title: 'Kapan Waktu Terbaik Minum Booster?',
          desc: 'Konsumsi booster (1 telur rebus + pisang / susu) pada sore hari jam 16.30 (segera setelah selesai sesi latihan) agar nutrisi langsung diserap serat otot.',
        ),
        (
          title: 'Target Hidrasi Air Putih (8-10 Gelas/Hari)',
          desc: 'Gunakan fitur Air Galon untuk mencatat tiap gelas air yang Anda minum. Hidrasi cukup sangat penting untuk mencegah kram otot dan memperlancar metabolisme.',
        ),
        (
          title: 'Siklus Isi Ulang Galon (Rp 6.000 per 4-5 Hari)',
          desc: 'Aplikasi memantau estimasi sisa air galon Anda dan otomatis mengingatkan waktu isi ulang agar tidak kehabisan air minum di kost.',
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 6. PANDUAN PROFIL, LEVEL & GAMIFIKASI
  // --------------------------------------------------------------------------
  Widget _buildProfilGuide() {
    return _buildSectionCard(
      title: 'Profil, Level XP, Streak & Medali',
      subtitle: 'Semua gamifikasi terpusat rapi di Profil (Trophy Room)',
      color: Star.star,
      steps: [
        (
          title: 'Cara Naik Level (Sistem XP)',
          desc: 'Selesaikan latihan (+50 XP), Choice Plan (+60 XP), dan catat makan (+10 XP). Tiap 100 XP Anda akan naik ke Level berikutnya (Level 1 Pemula hingga Level 5 Titan).',
        ),
        (
          title: 'Streak Api Harian (Duolingo Style)',
          desc: 'Pertahankan api streak Anda dengan membuka dan menyelesaikan checklist setiap hari. Pada hari istirahat (Rest Day), streak Anda otomatis aman terlindungi!',
        ),
        (
          title: '9 Medali Prestasi (Hall of Fame)',
          desc: 'Kumpulkan medali pencapaian (Master Kalistenik, Disiplin Nutrisi, Raja Hemat, Penjaga Hidrasi, dll.) yang memiliki progress bar progresif.',
        ),
        (
          title: 'Pantauan BMI & Rentang Berat Ideal',
          desc: 'Lihat status BMI (Kurus, Ideal, Kelebihan) dan batas rentang berat ideal Anda (min - max kg) berdasarkan tinggi badan.',
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // BUILDER HELPER CARD
  // --------------------------------------------------------------------------
  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Color color,
    required List<({String title, String desc})> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Neu.raised(r: 20, d: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: color,
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
            ],
          ),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: Neu.raised(r: 14, d: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${idx + 1}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Star.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.desc,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11.5,
                            color: Star.mut,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooterHelpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Neu.well(r: 18),
      child: Row(
        children: [
          const Icon(Icons.support_agent_rounded, size: 28, color: Star.star),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kunci Sukses: Konsistensi Kecil',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Star.star,
                  ),
                ),
                Text(
                  'Fokus selesaikan 1 checklist tiap hari. Tubuh berotot dan tabungan terbentuk dari kebiasaan kecil yang konsisten.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: Star.ink,
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
}
