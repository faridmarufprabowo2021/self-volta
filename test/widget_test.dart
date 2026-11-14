import 'package:self_volta/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:self_volta/main.dart';
import 'package:self_volta/store.dart';
import 'package:self_volta/data.dart';
import 'package:self_volta/services/prayer_service.dart';
import 'package:flutter/services.dart';

void main() {
  setUpAll(() async {
    // Panaskan singleton PrayerService (timer detik) di luar FakeAsync agar
    // tidak tersisa sebagai pending timer pada test widget pertama.
    PrayerService.instance;
    // Muat font asli (Inter) seperti di HP; font bawaan test (Ahem) membuat
    // semua glyph kotak penuh sehingga memunculkan overflow palsu.
    final loader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-Variable.ttf'));
    await loader.load();
  });

  test('centang makan format e{h}-{m} masuk hitungan paket', () async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    st.eaten.clear();
    expect(st.eatIn(0), 0);
    st.toggleEat('e1-1');
    st.toggleEat('e1-2');
    expect(st.eatIn(0), 2);
    expect(st.eatenCount, 2);
    expect(st.eatIn(1), 0);
    st.eaten.clear();
  });

  test('kalender: tiap bulan lembaran baru (bucket yyyy-MM)', () async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    final oy = st.calYear, om = st.calMonth;
    st.eaten.clear();
    st.toggleEat('e1-1');
    expect(st.eatenCount, 1);
    // Pindah bulan lain -> kosong (lembaran baru), balik -> utuh lagi.
    st.calYear = 1999;
    st.calMonth = 1;
    expect(st.eatenCount, 0);
    st.toggleEat('e5-2');
    expect(st.eatenCount, 1);
    st.calYear = oy;
    st.calMonth = om;
    expect(st.eatenCount, 1);
    expect(st.eatDay(1), 1);
    st.eaten.clear();
  });

  test('kalender: panjang bulan beneran (kabisat otomatis)', () {
    expect(AppState.daysIn(2024, 2), 29);
    expect(AppState.daysIn(2023, 2), 28);
    expect(AppState.daysIn(2026, 2), 28);
    expect(AppState.daysIn(2026, 10), 31);
    expect(AppState.daysIn(2026, 4), 30);
    expect(BULAN_ID[10], 'Oktober');
    expect(HARI_ID[DateTime(2026, 10, 11).weekday], 'Minggu');
  });

  test('keuangan: transaksi ikut bulan tampil', () async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    final oy = st.calYear, om = st.calMonth;
    st.txns.clear();
    await st.addTxn('tes bulan', 25000, hari: 5);
    expect(st.txnByDay(5), 25000);
    expect(st.txnsSel.length, 1);
    st.calYear = 1999;
    st.calMonth = 1;
    expect(st.txnByDay(5), 0);
    expect(st.txnsSel, isEmpty);
    st.calYear = oy;
    st.calMonth = om;
    expect(st.txnByDay(5), 25000);
    st.txns.clear();
    await st.save();
  });

  test('keuangan: pemasukan terpisah dari pengeluaran', () async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    st.txns.clear();
    await st.addTxn('gaji', 500000, hari: 1, kat: 'masuk');
    await st.addTxn('belanja', 25000, hari: 1, kat: 'protein');
    expect(st.totalIn, 500000);
    expect(st.totalOut, 25000);
    expect(st.txnByDay(1), 25000);
    expect(st.txnInByDay(1), 500000);
    expect(st.sisa, st.income + 500000 - 25000);
    st.txns.clear();
    await st.save();
  });

  test('ORPHAN_LATCH: hapus riwayat bumbu/beras mereset status', () async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    st.txns.clear();
    st.bumbuStock = false;
    st.bumbuBeras = false;
    st.bumbuFin = false;
    st.berasFin = false;
    st.bumbuTxnId = -1;
    st.berasTxnId = -1;
    // Beli -> tercatat + status true.
    await st.buyBumbu();
    expect(st.bumbuStock, true);
    expect(st.bumbuFin, true);
    expect(st.txns.length, 1);
    final bid = st.bumbuTxnId;
    expect(bid != -1, true);
    // Hapus riwayatnya -> status ikut reset (tidak yatim).
    await st.delTxn(bid);
    expect(st.txns, isEmpty);
    expect(st.bumbuStock, false);
    expect(st.bumbuFin, false);
    expect(st.bumbuTxnId, -1);
    // Beli ulang tercatat lagi (latch terbuka kembali).
    await st.buyBumbu();
    expect(st.txns.length, 1);
    expect(st.bumbuFin, true);
    // Varian beras.
    await st.buyBeras();
    expect(st.bumbuBeras, true);
    await st.delTxn(st.berasTxnId);
    expect(st.bumbuBeras, false);
    expect(st.berasFin, false);
    // Hapus semua mereset semuanya.
    await st.buyBumbu();
    await st.buyBeras();
    await st.clearTxns();
    expect(st.txns, isEmpty);
    expect(st.bumbuStock, false);
    expect(st.bumbuBeras, false);
    expect(st.bumbuFin, false);
    expect(st.berasFin, false);
    await st.save();
  });

  test('ORPHAN_LATCH: repair saat load + lompat ke bulan record', () async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    // Skenario yatim total: flag true tanpa record -> reset saat load.
    st.txns.clear();
    st.bumbuStock = true;
    st.bumbuFin = true;
    st.bumbuTxnId = -1;
    st.bumbuBeras = true;
    st.berasFin = true;
    st.berasTxnId = -1;
    await st.save();
    await st.load();
    expect(st.bumbuStock, false);
    expect(st.bumbuFin, false);
    expect(st.bumbuBeras, false);
    expect(st.berasFin, false);
    // Adopsi: record lama tanpa id -> id diadopsi, resolve ke bulannya.
    await st.addTxn(
      'Stok bumbu lengkap (garam+gula+bawang)',
      31000,
      kat: 'lain',
    );
    st.bumbuStock = true;
    st.bumbuFin = true;
    st.bumbuTxnId = -1;
    await st.save();
    await st.load();
    expect(st.bumbuFin, true);
    expect(st.bumbuTxnId != -1, true);
    final m = await st.resolveBumbuMonth(true);
    expect(m, st.selKey);
    // Bersih-bersih.
    st.txns.clear();
    st.bumbuStock = false;
    st.bumbuFin = false;
    st.bumbuTxnId = -1;
    st.bumbuBeras = false;
    st.berasFin = false;
    st.berasTxnId = -1;
    await st.save();
  });

  test('workout: reset manual mengosongkan checklist', () async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    st.workoutDone.clear();
    st.toggleWork('senin-0');
    st.toggleWork('rabu-1');
    expect(st.workoutDone.length, 2);
    await st.resetWorkout();
    expect(st.workoutDone, isEmpty);
    await st.save();
  });

  test(
    'ORPHAN_SHORTCUT: hapus txn bumbu lalu beli ulang muncul di Riwayat',
    () async {
      SharedPreferences.setMockInitialValues({});
      final st = AppState.I;
      st.txns.clear();
      st.bumbuStock = false;
      st.bumbuFin = false;
      st.bumbuTxnId = -1;
      st.bumbuBeras = false;
      st.berasFin = false;
      st.berasTxnId = -1;
      // 1. Beli bumbu -> tercatat di Riwayat bulan tampil.
      await st.buyBumbu();
      expect(st.txnsSel.any((t) => t.id == st.bumbuTxnId), true);
      // 2. Shortcut (+) resolve ke bulan record.
      expect(await st.resolveBumbuMonth(true), st.selKey);
      // 3. Hapus dari Riwayat -> shortcut yatim: resolve null + status reset.
      final goneId = st.bumbuTxnId;
      await st.delTxn(goneId);
      expect(st.txnsSel.any((t) => t.id == goneId), false);
      expect(st.bumbuStock, false);
      expect(st.bumbuFin, false);
      expect(await st.resolveBumbuMonth(true), isNull);
      // 4. Beli ulang -> muncul lagi di Riwayat (Riwayat berfungsi).
      await st.buyBumbu();
      expect(st.bumbuFin, true);
      expect(st.txnsSel.any((t) => t.id == st.bumbuTxnId), true);
      // Bersih-bersih.
      await st.clearTxns();
    },
  );

  testWidgets('UNGUARDED_RESET: reset latihan minta konfirmasi dulu', (
    WidgetTester tester,
  ) async {
    final st = AppState.I;
    st.workoutDone
      ..clear()
      ..['senin-0'] = true;
    await st.flushNow(); // save() kini berdebounce; flushNow = tulis sekarang
    await tester.pumpWidget(const SelfVoltaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Latihan').last);
    await tester.pumpAndSettle();
    // Scroll sampai tombol reset terlihat (pola drag-loop file ini).
    final list = find.byType(ListView).first;
    final resetBtn = find.text('Hapus Progres Centang');
    for (var i = 0; i < 30 && resetBtn.hitTestable().evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    // Tap tombol: yang muncul dialog, BUKAN langsung reset.
    await tester.tap(resetBtn);
    await tester.pumpAndSettle();
    expect(find.text('Hapus progres centang?'), findsOneWidget);
    expect(st.workoutDone.containsKey('senin-0'), true);
    // Batal: progres utuh.
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus progres centang?'), findsNothing);
    expect(st.workoutDone.containsKey('senin-0'), true);
    // Konfirmasi Reset: baru benar-benar terhapus.
    await tester.tap(resetBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya, Hapus Progres'));
    await tester.pumpAndSettle();
    expect(st.workoutDone, isEmpty);
    expect(find.text('Hapus progres centang?'), findsNothing);
    await st.flushNow(); // save() kini berdebounce; flushNow = tulis sekarang
  });

  testWidgets('CAL_DAY_INPUT: sheet tanggal bisa catat masuk & keluar', (
    WidgetTester tester,
  ) async {
    final st = AppState.I;
    const day = 15;
    final outBefore = st.txnByDay(day);
    final inBefore = st.txnInByDay(day);
    await tester.pumpWidget(const SelfVoltaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uang').last);
    await tester.pumpAndSettle();
    // Scroll sampai sel kalender tgl 15 terlihat (DayGrid pakai label H15,
    // jadi teks '15' unik milik sel kalender).
    final list = find.byType(ListView).first;
    final cell = find.text('15');
    for (var i = 0; i < 25 && cell.hitTestable().evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    await tester.tap(cell);
    await tester.pumpAndSettle();
    // Sheet tanggal terbuka dengan form terkunci tgl 15.
    final sheet = find.byType(DraggableScrollableSheet);
    expect(
      find.descendant(of: sheet, matching: find.text('Catat tgl 15')),
      findsOneWidget,
    );
    Finder sheetField(String label) => find.descendant(
      of: sheet,
      matching: find.widgetWithText(TextField, label),
    );
    // Jalur keluar (default segmen): catat belanja 12000.
    await tester.enterText(sheetField('Keterangan'), 'Jajan sheet');
    await tester.enterText(sheetField('Jumlah Rp'), '12000');
    await tester.tap(
      find.descendant(of: sheet, matching: find.text('Simpan ke tgl 15')),
    );
    await tester.pumpAndSettle();
    expect(st.txnByDay(day), outBefore + 12000);
    // List sheet malas (lazy): scroll sampai baris tercatat tampil.
    final sheetList = find.descendant(
      of: sheet,
      matching: find.byType(ListView),
    );
    Finder sheetRow(String ket) =>
        find.descendant(of: sheet, matching: find.text(ket));
    final segMasuk = find.descendant(of: sheet, matching: find.text('Masuk'));
    for (
      var i = 0;
      i < 20 && sheetRow('Jajan sheet').hitTestable().evaluate().isEmpty;
      i++
    ) {
      await tester.drag(sheetList, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    expect(sheetRow('Jajan sheet'), findsOneWidget);
    // Scroll balik ke form, pindah segmen Masuk, catat 50000.
    for (var i = 0; i < 20 && segMasuk.hitTestable().evaluate().isEmpty; i++) {
      await tester.drag(sheetList, const Offset(0, 400));
      await tester.pumpAndSettle();
    }
    await tester.tap(segMasuk);
    await tester.pumpAndSettle();
    await tester.enterText(sheetField('Keterangan'), 'Gaji sheet');
    await tester.enterText(sheetField('Jumlah Rp'), '50000');
    await tester.tap(
      find.descendant(of: sheet, matching: find.text('Simpan ke tgl 15')),
    );
    await tester.pumpAndSettle();
    expect(st.txnInByDay(day), inBefore + 50000);
    // Baris terbaru di paling atas list: pastikan tampil.
    for (
      var i = 0;
      i < 20 && sheetRow('Gaji sheet').hitTestable().evaluate().isEmpty;
      i++
    ) {
      await tester.drag(sheetList, const Offset(0, 400));
      await tester.pumpAndSettle();
    }
    expect(sheetRow('Gaji sheet'), findsOneWidget);
    // Bersih-bersih agar tidak mengotori test lain.
    for (final t
        in st.txns
            .where((t) => t.ket == 'Jajan sheet' || t.ket == 'Gaji sheet')
            .toList()) {
      await st.delTxn(t.id);
    }
  });

  testWidgets('kalender uang tampil di halaman Uang', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SelfVoltaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uang').last);
    await tester.pumpAndSettle();
    expect(find.text('Laporan & Keuangan'), findsOneWidget);
    // Kalender ada di paling bawah (sliver malas: scroll sampai label bulan).
    final monthLabel = '${BULAN_ID[AppState.I.calMonth]} ${AppState.I.calYear}';
    final list = find.byType(ListView).first;
    for (var i = 0; i < 25 && find.text(monthLabel).evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    expect(find.text('Kalender Uang'), findsOneWidget);
    expect(find.text(monthLabel), findsWidgets);
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Keluar'), findsWidgets);
  });

  testWidgets('SELF VOLTA boots to Beranda', (WidgetTester tester) async {
    await tester.pumpWidget(const SelfVoltaApp());
    await tester.pumpAndSettle();
    expect(find.text('SELF VOLTA'), findsWidgets);
    expect(find.text('HARI INI'), findsOneWidget);
  });

  testWidgets('semua halaman ke-render tanpa exception', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SelfVoltaApp());
    await tester.pumpAndSettle();

    Future<void> viaNav(String label, String judul) async {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.text(judul), findsOneWidget);
    }

    await viaNav('Latihan', 'Latihan & Pembentukan Otot');
    await viaNav('Beranda', 'HARI INI');
    await viaNav('Uang', 'Laporan & Keuangan');
    await viaNav('Makan', 'Planning Makan Kost');

    Finder drawerItem(String label) =>
        find.descendant(of: find.byType(Drawer), matching: find.text(label));

    Future<void> openDrawer() async {
      await tester.tap(find.byIcon(Icons.menu_rounded).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> viaDrawer(
      String item,
      String judul, {
      bool mayRepeat = false,
    }) async {
      await openDrawer();
      final scrollable = find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        drawerItem(item).last,
        200,
        scrollable: scrollable,
      );
      await tester.tap(drawerItem(item).last);
      // Halaman seperti Air Galon punya animasi gelombang terus-menerus,
      // jadi pumpAndSettle tidak akan pernah selesai.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text(judul), mayRepeat ? findsWidgets : findsOneWidget);
    }

    await viaDrawer('Beranda', 'HARI INI');
    await viaDrawer('To-Do Harian', 'Hari ini', mayRepeat: true);
    await viaDrawer('Study & Fokus', 'Study & fokus');
    await viaDrawer('Latihan Utama', 'Latihan & Pembentukan Otot');
    await viaDrawer('Choice Plan', 'Choice Plan Latihan');
    await viaDrawer('Jadwal Makan & Resep', 'Planning Makan Kost');
    await viaDrawer('Booster BB', 'Kenapa Perlu Booster?');
    await viaDrawer('Tips Masak Cepat', 'Tips Masak Hemat Waktu');
    await viaDrawer('Air Galon', 'Hidrasi Galon Kost');
    await viaDrawer('Keuangan', 'Laporan & Keuangan');
    await viaDrawer('Piano', 'Target Piano Rp1.500.000');
    await viaDrawer('Buat Baru', 'Buat Kombinasi Baru');
  });

  testWidgets('panduan masak planning bisa dibuka', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SelfVoltaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Makan').last);
    await tester.pumpAndSettle();
    final btn = find.text('Panduan Detail & Langkah');
    final list = find.byType(ListView).first;
    for (var i = 0; i < 30 && btn.hitTestable().evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    await tester.tap(btn.hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('Panduan Masak 15 Menit'), findsOneWidget);
  });

  testWidgets('shortcut Booster tidak menghancurkan shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SelfVoltaApp());
    await tester.pumpAndSettle();
    expect(find.text('HARI INI'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu_rounded).first);
    await tester.pumpAndSettle();
    final scrollable = find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    );
    final item = find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Booster BB'),
    );
    await tester.scrollUntilVisible(item, 200, scrollable: scrollable);
    await tester.tap(item);
    await tester.pumpAndSettle();

    // halaman Booster tampil...
    expect(find.text('Kenapa Perlu Booster?'), findsOneWidget);
    // ...DAN shell tetap hidup: bottom nav + tombol drawer masih ada.
    expect(find.text('Uang'), findsOneWidget);
    expect(find.byIcon(Icons.menu_rounded).first, findsOneWidget);
  });

  testWidgets('tab bawah Planning <-> Beranda tetap di shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SelfVoltaApp());
    await tester.pumpAndSettle();
    expect(find.text('HARI INI'), findsOneWidget);

    // Beranda -> Planning via tab bawah.
    await tester.tap(find.text('Makan').last);
    await tester.pumpAndSettle();
    expect(find.text('Planning Makan Kost'), findsOneWidget);

    // Planning -> Beranda via tab bawah.
    await tester.tap(find.text('Beranda').last);
    await tester.pumpAndSettle();
    expect(find.text('HARI INI'), findsOneWidget);

    // Shell tetap hidup.
    expect(find.text('Uang'), findsOneWidget);
    expect(find.byIcon(Icons.menu_rounded).first, findsOneWidget);
  });

  testWidgets('jadwal pengingat latihan bisa diatur dari halaman Latihan', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final st = AppState.I;
    st.workoutReminderOn = true;
    st.workoutReminderDays = {1, 3, 5};
    st.workoutReminderMin = 16 * 60 + 30;

    await tester.pumpWidget(const SelfVoltaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Latihan').last);
    await tester.pumpAndSettle();

    // Pil di header menampilkan jam pengingat dan bisa diketuk.
    final btn = find.byKey(const Key('workout-reminder-btn'));
    expect(btn, findsOneWidget);
    expect(find.text('16.30'), findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle();

    // Sheet pengaturan: hari + jam + switch.
    expect(find.text('Pengingat latihan'), findsOneWidget);
    expect(find.text('Hari latihan'), findsOneWidget);
    expect(find.text('Jam pengingat'), findsOneWidget);

    // User menambah hari Selasa: jadwal langsung tersimpan.
    await tester.tap(find.text('Sel'));
    await tester.pumpAndSettle();
    expect(st.workoutReminderDays.contains(2), true);

    // Mematikan pengingat -> pil header jadi "Notif mati".
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(st.workoutReminderOn, false);

    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(find.text('Hari latihan'), findsNothing);
    expect(find.text('Notif mati'), findsOneWidget);

    // Kembalikan default agar test lain tidak terpengaruh.
    st.workoutReminderOn = true;
    st.workoutReminderDays = {1, 3, 5};
    st.workoutReminderMin = 16 * 60 + 30;
  });

  test(
    'ThousandsSeparatorInputFormatter: format angka dengan titik ribuan',
    () {
      expect(ThousandsSeparatorInputFormatter.format('50000'), '50.000');
      expect(ThousandsSeparatorInputFormatter.format('1500000'), '1.500.000');
      expect(ThousandsSeparatorInputFormatter.format('250'), '250');
      expect(ThousandsSeparatorInputFormatter.format(''), '');
      expect(ThousandsSeparatorInputFormatter.format('abc12345xyz'), '12.345');
    },
  );
}
