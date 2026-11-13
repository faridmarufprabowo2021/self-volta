import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Themes.tips;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const SecHead(
          'tips',
          Icons.restaurant_menu_rounded,
          'Tips Masak Hemat Waktu',
          'Alat terbatas: pisau + MC/PL',
        ),
        SoftCard(
          color: c.accBg.withValues(alpha: .4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HRow(
                Icons.lightbulb_rounded,
                'tips',
                'Aturan Enak',
                'Tempel di dapur',
              ),
              const SizedBox(height: 8),
              const InfoList([
                'Potong tipis biar cepat empuk.',
                'MC: nasi + telur/tempe/ikan kukus barengan hemat listrik.',
                'PL: didihkan dulu baru masuk bahan, garam terakhir.',
                'Tanpa cabai (tidak suka pedas), tanpa santan, tanpa goreng, tanpa mie instan.',
                'Kunyah pelan, makan porsi kecil 3x teratur + snack jam 10 & 15.',
                'Serat pola cuma ±5g/hari - tambah pepaya/pisang 1 potong atau sayur 1 mangkok ekstra biar perut nyaman (target serat 25-30g/hari).',
                'Air hangat, tidur 2-3 jam setelah makan.',
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
