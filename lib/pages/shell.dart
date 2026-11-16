import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../services/backup_service.dart';
import '../services/todo_notifications.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'air_page.dart';
import 'booster_page.dart';
import 'buat_page.dart';
import 'home_page.dart';
import 'ingin_page.dart';
import 'jadwal_page.dart';
import 'keuangan_page.dart';
import 'minggu_page.dart';
import 'planning_page.dart';
import 'profile_page.dart';
import 'sharp_v_nav_bar.dart';
import 'study_page.dart';
import 'tips_page.dart';
import 'workout_page.dart';
import 'choice_plan_page.dart';
import 'panduan_page.dart';
import 'todo_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  String _page = 'home';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _history = [];
  DateTime? _lastBackPressTime;
  Timer? _midnightTicker;
  late final AppLifecycleListener _lifecycle;

  // Nav order:
  // 0: workout ('Latihan')
  // 1: planning ('Makan')
  // 2: home ('Beranda') -> Center tab!
  // 3: keuangan ('Uang')
  // 4: menu ('Menu' -> Drawer)
  int _lastNav = 2;

  // ---- timer global: rollover tengah malam + fallback banner to-do ----
  bool _todoBannerOpen = false;

  @override
  void initState() {
    super.initState();
    _midnightTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkMidnightAndReminders();
    });
    // Fase 1.2: saat aplikasi ditinggalkan/ditutup OS, tulis data yang masih
    // tertahan debounce supaya tidak ada perubahan yang hilang.
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive ||
            state == AppLifecycleState.detached) {
          unawaited(AppState.I.flushNow());
        }
      },
    );
    // Fase 1.3: beri tahu pengguna bila data rusak/pulih saat load.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showLoadRecoveryDialog(),
    );
  }

  /// Dialog sekali-tampil setelah `load()` menemukan data rusak.
  void _showLoadRecoveryDialog() {
    final rec = AppState.I.loadRecovery;
    if (rec == null || !mounted) return;
    AppState.I.loadRecovery = null;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              rec.recoveredFromBackup
                  ? Icons.restore_rounded
                  : Icons.report_problem_rounded,
              color: rec.recoveredFromBackup ? Star.star : Star.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Data sempat rusak',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          rec.recoveredFromBackup
              ? 'Data utama tidak bisa dibaca, tetapi berhasil dipulihkan dari '
                    'cadangan otomatis (sv_v1_bak).\n\n'
                    'Salinan data rusak disimpan sebagai "${rec.corruptKey}". '
                    'Sebaiknya lakukan Ekspor Data sekarang dari halaman Profil.'
              : 'Data utama rusak DAN cadangan otomatis juga tidak bisa dibaca. '
                    'Aplikasi dimulai dengan data kosong; data lama tidak ditimpa.\n\n'
                    'Salinan data rusak disimpan sebagai "${rec.corruptKey}". '
                    'Segera pulihkan dari file cadangan terakhir lewat '
                    'Profil → Impor Data.',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Mengerti',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () => _exportFromRecovery(ctx),
            icon: const Icon(Icons.save_alt_rounded, size: 18),
            label: const Text(
              'Ekspor sekarang',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Star.star,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ekspor langsung dari dialog pemulihan: pengguna tidak perlu mencari
  /// halaman Profil saat data baru saja bermasalah.
  Future<void> _exportFromRecovery(BuildContext dialogCtx) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppState.I.flushNow();
      final uri = await BackupService.exportToFile(AppState.I.exportJson());
      if (uri == null) return; // dialog simpan dibatalkan, biarkan dialog tetap
      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Cadangan tersimpan. Simpan file itu di tempat aman.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('[Shell] ekspor darurat gagal: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal ekspor: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Star.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _midnightTicker?.cancel();
    super.dispose();
  }

  void _checkMidnightAndReminders() {
    if (!mounted) return;
    if (AppState.I.rolloverIfNewDay()) {
      _todoBannerOpen = false;
      ScaffoldMessenger.of(context).clearMaterialBanners();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Tengah malam — progres latihan direset otomatis dan bonus XP harian terbuka lagi.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Star.star,
          ),
        );
    }
    _maybeShowTodoBanner();
  }

  /// Banner in-app hanya berlaku sebagai FALLBACK: bila plugin
  /// notifikasi tidak tersedia (web/desktop) atau izin belum diberikan,
  /// pengingat muncul di dalam aplikasi dengan aksi Selesai & Tunda.
  void _maybeShowTodoBanner() {
    if (!mounted) return;
    if (TodoNotif.ready && TodoNotif.granted) return; // jalur utama: OS
    if (_todoBannerOpen) return;
    final t = AppState.I.popDueTodoReminder();
    if (t == null) return;
    _todoBannerOpen = true;
    void close() {
      ScaffoldMessenger.of(context).clearMaterialBanners();
      _todoBannerOpen = false;
    }

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: Star.bg,
        surfaceTintColor: Colors.transparent,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: Star.success,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengingat tugas',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Star.mut,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              close();
              await AppState.I.toggleTodo(t.id);
              // ignore: use_build_context_synchronously
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      t.xp > 0
                          ? 'Tugas selesai (+${t.xp} XP)'
                          : 'Tugas selesai',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Star.success,
                  ),
                );
              }
            },
            child: const Text(
              'Selesai',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                color: Star.success,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              close();
              AppState.I.snoozeTodo(t.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengingat ditunda 10 menit'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Tunda 10 menit',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _set(String p, {bool addToHistory = true}) {
    if (_page == p) return;
    if (addToHistory) {
      _history.add(_page);
      if (_history.length > 25) _history.removeAt(0);
    }
    const map = ['workout', 'planning', 'home', 'keuangan', 'profile'];
    final i = map.indexOf(p);
    setState(() {
      _page = p;
      if (i != -1) _lastNav = i;
    });
  }

  void _handleBackPress() {
    // 1. Tutup drawer jika sedang terbuka
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
      return;
    }

    // 2. Navigasi mundur sesuai riwayat
    if (_history.isNotEmpty) {
      final prev = _history.removeLast();
      _set(prev, addToHistory: false);
      return;
    }

    // 3. Jika bukan di beranda dan riwayat kosong, kembali ke beranda
    if (_page != 'home') {
      _set('home', addToHistory: false);
      return;
    }

    // 4. Double-tap to exit jika sudah berada di beranda
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.touch_app_rounded, color: Star.star, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tekan sekali lagi untuk keluar dari SELF VOLTA',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Star.surface2,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      );
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Beranda, To-Do, dan Study memakai kanvas kertas hangat; app bar ikut
    // kanvas itu agar tidak ada sambungan dua nada abu-krem di bagian atas.
    final isPaperPage =
        _page == 'home' ||
        _page == 'todo' ||
        _page == 'jadwal' ||
        _page == 'study';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: isPaperPage ? Paper.canvas : null,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu Utama',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          // Gaya iOS: judul kecil di tengah, aksi berupa ikon tanpa pil warna.
          title: const Text(
            'SELF VOLTA',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: 'Panduan',
              icon: const Icon(Icons.menu_book_outlined),
              onPressed: () {
                iosTapBuzz();
                _set('panduan');
              },
            ),
            ListenableBuilder(
              listenable: AppState.I,
              builder: (context, _) {
                final isProfile = _page == 'profile';
                return IconButton(
                  tooltip: 'Profil · Level ${AppState.I.level}',
                  onPressed: () {
                    iosTapBuzz();
                    _set('profile');
                  },
                  icon: Icon(
                    isProfile
                        ? Icons.person_rounded
                        : Icons.person_outline_rounded,
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        drawer: _drawer(theme),
        body: _buildBody(),
        bottomNavigationBar: SharpVBottomNavBar(
          selectedIndex: _lastNav,
          onItemSelected: (i) {
            if (i == 4) {
              _scaffoldKey.currentState?.openDrawer();
            } else {
              const map = [
                'workout',
                'planning',
                'home',
                'keuangan',
                'profile',
              ];
              if (i < map.length) {
                _set(map[i]);
                _scaffoldKey.currentState?.closeDrawer();
              }
            }
          },
          items: const [
            SharpVNavItem(icon: Icons.fitness_center_rounded, label: 'Latihan'),
            SharpVNavItem(icon: Icons.soup_kitchen_rounded, label: 'Makan'),
            SharpVNavItem(icon: Icons.home_rounded, label: 'Beranda'),
            SharpVNavItem(icon: Icons.savings_rounded, label: 'Uang'),
            SharpVNavItem(icon: Icons.menu_rounded, label: 'Menu'),
          ],
        ),
      ),
    );
  }

  Widget _drawer(ThemeData theme) {
    Widget group(String label, List<(String, String, IconData, String)> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: CustomColors.textSecondary,
              ),
            ),
          ),
          ...[
            for (final (k, title, icon, sub) in items)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                child: ListTile(
                  leading: Icon(
                    icon,
                    color: _page == k ? Star.star : Star.faint,
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      color: _page == k ? Star.ink : Star.mut,
                      fontWeight: _page == k
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    sub,
                    style: const TextStyle(color: Star.faint, fontSize: 12),
                  ),
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: _page == k
                      ? CustomColors.bgGrey
                      : Colors.transparent,
                  selected: _page == k,
                  onTap: () {
                    _set(k);
                    _scaffoldKey.currentState?.closeDrawer();
                  },
                ),
              ),
          ],
        ],
      );
    }

    return Drawer(
      backgroundColor: Star.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      VLogo(size: 42, fontSize: 24),
                      SizedBox(width: 12),
                      Text(
                        'SELF VOLTA',
                        style: TextStyle(
                          color: Star.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                group('Utama', const [
                  ('home', 'Beranda', Icons.home_rounded, 'Dashboard harian'),
                  (
                    'todo',
                    'To-Do Harian',
                    Icons.checklist_rounded,
                    'Tugas, pengingat & bonus XP',
                  ),
                  (
                    'jadwal',
                    'Jadwal Harian',
                    Icons.calendar_view_day_rounded,
                    'Baca timeline tugas hari ini',
                  ),
                  (
                    'study',
                    'Study & Fokus',
                    Icons.school_rounded,
                    'Timer fokus & target belajar',
                  ),
                ]),
                group('Workout', const [
                  (
                    'workout',
                    'Latihan Utama',
                    Icons.fitness_center_rounded,
                    '3x seminggu • Program terstruktur',
                  ),
                  (
                    'choice_plan',
                    'Choice Plan',
                    Icons.tune_rounded,
                    'Kustom gerakan, reps & rest timer',
                  ),
                ]),
                group('Pola Makan & Nutrisi', const [
                  (
                    'planning',
                    'Jadwal Makan & Resep',
                    Icons.soup_kitchen_rounded,
                    'Menu 4 waktu & 7 paket hemat',
                  ),
                  (
                    'booster',
                    'Booster BB',
                    Icons.bolt_rounded,
                    'Nutrisi ekstra pasca-latihan',
                  ),
                  (
                    'tips',
                    'Tips Masak Cepat',
                    Icons.restaurant_menu_rounded,
                    'Masak hemat 15 menit',
                  ),
                  (
                    'air',
                    'Air Galon',
                    Icons.water_drop_rounded,
                    'Target 8–10 gelas/hari',
                  ),
                ]),
                group('Keuangan', const [
                  (
                    'keuangan',
                    'Keuangan',
                    Icons.savings_rounded,
                    'Kalkulator & catat',
                  ),
                  ('ingin', 'Piano', Icons.piano_rounded, 'Target Rp1,5 jt'),
                ]),
                group('Kombinasi', const [
                  (
                    'buat',
                    'Buat Baru',
                    Icons.add_circle_rounded,
                    'Halaman kombinasi',
                  ),
                ]),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Data tersimpan lokal otomatis di perangkatmu.\nSELF VOLTA v$APP_VERSION',
                    style: const TextStyle(
                      color: Star.faint,
                      fontSize: 12,
                      height: 1.65,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey<String>(_page),
        child: _getPageWidget(_page),
      ),
    );
  }

  Widget _getPageWidget(String p) {
    switch (p) {
      case 'home':
        return HomePage(onNavigate: _set);
      case 'todo':
        return TodoPage(onNavigate: _set);
      case 'jadwal':
        return JadwalPage(onNavigate: _set);
      case 'study':
        return const StudyPage();
      case 'workout':
        return WorkoutPage(onNavigate: _set);
      case 'choice_plan':
        return ChoicePlanPage(onNavigate: _set);
      case 'panduan':
        return PanduanPage(onNavigate: _set);
      case 'planning':
        return PlanningPage(onGo: _set);
      case 'keuangan':
        return const KeuanganPage();
      case 'profile':
        return ProfilePage(onNavigate: _set);
      case 'booster':
        return const BoosterPage();
      case 'minggu1':
        return MingguPage(m1: true, onGo: _set);
      case 'minggu2':
        return MingguPage(m1: false, onGo: _set);
      case 'tips':
        return const TipsPage();
      case 'air':
        return const AirPage();
      case 'ingin':
        return const InginPage();
      case 'buat':
        return const BuatPage();
      default:
        return HomePage(onNavigate: _set);
    }
  }
}
