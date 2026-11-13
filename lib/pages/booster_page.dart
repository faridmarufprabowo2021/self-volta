// Booster Berat Badan & Kalori Surplus Page
// Self Volta - Advanced Athletic & Kost Economy Edition

import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class BoosterPage extends StatelessWidget {
  const BoosterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        final st = AppState.I;
        final now = DateTime.now();
        final currentDay = now.day;
        final bool hasBoosterLogged = st.hasBoosterDay(currentDay);

        return Scaffold(
          backgroundColor: Star.bg,
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
            children: [
              // --------------------------------------------------------------
              // 1. HERO HEADER: SAINS BOOSTER BERAT BADAN & MACRO SURPLUS
              // --------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xffEA580C),
                  borderRadius: BorderRadius.circular(16),
                ),
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
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 15,
                                  color: Color(0xffFDE047),
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Strategi Bulking Kost',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            iosTapBuzz();
                            st.toggleBoosterDay(currentDay);
                            if (!hasBoosterLogged) {
                              st.addXp(20);
                              triumphBuzz();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Booster hari ini dicatat! (+20 XP)',
                                  ),
                                  backgroundColor: Color(0xffEA580C),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: hasBoosterLogged
                                  ? const Color(0xff10B981)
                                  : Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasBoosterLogged
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasBoosterLogged
                                      ? 'Tercatat Hari Ini'
                                      : 'Catat Booster',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Kenapa Perlu Booster?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pola makan pokok kost hanya memberi ~1.260 kkal. Untuk menaikkan berat badan dan membentuk otot kalistenik tebal, tubuh wajib surplus hingga ~2.370 kkal & 75-80g protein murni.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Macro Surplus Metrics Display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '+1.110 kkal',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xffFDE047),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Surplus Kalori',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '|',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '+33g Protein',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Massa Otot',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '|',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Rp 10.900',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff86EFAC),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Biaya per Hari',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9.5,
                                    color: Colors.white70,
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
              ),
              const SizedBox(height: 16),

              // --------------------------------------------------------------
              // 2. STREAK BULKING 7 HARI MINGGUAN
              // --------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Star.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Star.lineSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: Color(0xffEA580C),
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Konsistensi Bulking 7 Hari',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffEA580C)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '+50 XP / 3 Hari',
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEA580C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final d = i + 1;
                        final isDone = st.hasBoosterDay(d);
                        final isTodayDay = currentDay == d;
                        return InkWell(
                          onTap: () {
                            iosTapBuzz();
                            st.toggleBoosterDay(d);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 40,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? const Color(0xffEA580C)
                                  : isTodayDay
                                  ? const Color(0xffEA580C)
                                        .withValues(alpha: 0.12)
                                  : Star.bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDone || isTodayDay
                                    ? const Color(0xffEA580C)
                                    : Star.sunken,
                                width: isTodayDay ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'][i],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDone ? Colors.white70 : Star.mut,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  isDone
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: 14,
                                  color: isDone ? Colors.white : Star.mut,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --------------------------------------------------------------
              // 3. 3 RESEP BOOSTER PRAKTIS KOST (DENGAN 1-TAP TAMBAH KE BELANJA)
              // --------------------------------------------------------------
              const Row(
                children: [
                  Icon(
                    Icons.restaurant_rounded,
                    color: Color(0xffEA580C),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '3 Menu Booster Praktis Anak Kost',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Star.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _boosterRecipeCard(
                context: context,
                st: st,
                title: 'Mass Gainer Smoothie Kost',
                cal: '520 kkal',
                protein: '22g Protein',
                cost: 'Rp 5.500',
                desc: 'Blender atau haluskan 2 pisang sunpride dengan garpu. Campur 1 kotak susu kedelai/UHT dingin & 2 sdm oatmeal instan. Cepat diserap pasca latihan!',
                ingredients: [
                  '2 Pisang Sunpride',
                  'Susu UHT / Kedelai',
                  'Oatmeal Instan',
                ],
                accentColor: const Color(0xff0D9488),
                groceryKey: 'gro_booster_shake',
              ),
              const SizedBox(height: 10),

              _boosterRecipeCard(
                context: context,
                st: st,
                title: 'Double Boiled Egg & Banana Power',
                cal: '320 kkal',
                protein: '14g Protein',
                cost: 'Rp 4.500',
                desc: 'Rebus 2 butir telur ayam di panci listrik selama 8 menit. Makan bersama 2 pisang sebagai camilan sore sebelum jam 5.',
                ingredients: ['2 Butir Telur Ayam', '2 Buah Pisang'],
                accentColor: const Color(0xffE5A910),
                groceryKey: 'gro_booster_egg_banana',
              ),
              const SizedBox(height: 10),

              _boosterRecipeCard(
                context: context,
                st: st,
                title: 'Tempe Kukus Magic Com Extra Rice',
                cal: '450 kkal',
                protein: '18g Protein',
                cost: 'Rp 3.500',
                desc: 'Potong dadu 1 papan tempe (100g). Taruh di atas wadah kukus magic com saat masak nasi. Siram kecap manis saat matang.',
                ingredients: [
                  '1 Papan Tempe',
                  'Kecap Manis',
                  'Nasi Tambahan +150g',
                ],
                accentColor: const Color(0xff004E71),
                groceryKey: 'gro_booster_tempe_rice',
              ),
              const SizedBox(height: 16),

              // --------------------------------------------------------------
              // 4. ATURAN SAINS SURPLUS TANPA BEGAH
              // --------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Star.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Star.lineSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xffF59E0B),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tips Anti-Begah Makan Surplus Kalori',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Star.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _scienceTipItem(
                      '1. Jangan Sekali Makan Porsi Raksasa',
                      'Bagi kalori tambahan ke 4 sesi makan terpisah agar lambung tidak kembung atau begah.',
                    ),
                    _scienceTipItem(
                      '2. Minum Air 30 Menit Setelah Makan',
                      'Hindari minum banyak air dingin bersamaan dengan nasi agar asam lambung bekerja optimal mencerna protein.',
                    ),
                    _scienceTipItem(
                      '3. Manfaatkan Pisang & Telur Murah',
                      'Pisang menyediakan karbohidrat fruktosa padat energi, sedangkan telur memberi asam amino rantai cabang (BCAA) terbaik untuk pemulihan otot.',
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

  Widget _boosterRecipeCard({
    required BuildContext context,
    required AppState st,
    required String title,
    required String cal,
    required String protein,
    required String cost,
    required String desc,
    required List<String> ingredients,
    required Color accentColor,
    required String groceryKey,
  }) {
    final bool isAdded = st.bought[groceryKey] ?? false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Star.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Star.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cost,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffFDE047).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '🔥 $cal',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff854D0E),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '💪 $protein',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5,
              color: Star.ink,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () {
                iosTapBuzz();
                st.toggleBought(groceryKey);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAdded
                          ? 'Bahan dilepas dari Belanja.'
                          : 'Bahan "$title" ditambahkan ke Daftar Belanja!',
                    ),
                    backgroundColor: accentColor,
                    duration: const Duration(milliseconds: 1200),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: Icon(
                isAdded
                    ? Icons.check_circle_rounded
                    : Icons.add_shopping_cart_rounded,
                size: 14,
              ),
              label: Text(
                isAdded
                    ? 'Bahan Sudah Ada di Daftar Belanja ✓'
                    : '+ Tambah Bahan Resep ke Belanja',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isAdded
                    ? const Color(0xff10B981).withValues(alpha: 0.15)
                    : accentColor.withValues(alpha: 0.12),
                foregroundColor: isAdded
                    ? const Color(0xff10B981)
                    : accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scienceTipItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Star.ink,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Star.mut,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
