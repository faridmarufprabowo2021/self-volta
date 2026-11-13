import 'package:flutter/material.dart';

import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class BuatPage extends StatefulWidget {
  final bool openDetail;
  const BuatPage({super.key, this.openDetail = false});
  @override
  State<BuatPage> createState() => _BuatPageState();
}

class _BuatPageState extends State<BuatPage> {
  final name = TextEditingController();
  final note = TextEditingController();
  final sel = <String>{};

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (_, _) {
        final st = AppState.I;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            SecHead(
              'buat',
              Icons.add_circle_rounded,
              'Buat Kombinasi Baru',
              'Pilih pola, jadi daftar kombinasi',
              action: Pill('2-4 pola', page: Themes.buat.acc),
            ),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih 2-4 pola (A-G, alat: pisau+MC/PL). Tiap pola = 2 hari ±Rp19-22,5rb.',
                    style: AppText.body,
                  ),
                  const SizedBox(height: 12),
                  for (final k in POLA.keys)
                    // Material sendiri agar ink ripple CheckboxListTile tidak
                    // tertutup DecoratedBox SoftCard (assertion debug + ripple hilang).
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: CheckboxListTile(
                        value: sel.contains(k),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            sel.add(k);
                          } else {
                            sel.remove(k);
                          }
                        }),
                        title: Text(
                          '$k - ${POLA[k]!.t}',
                          style: AppText.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          POLA[k]!.belanja,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.secondary,
                        ),
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Nama kombinasi',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: note,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final polas = sel.toList();
                      if (polas.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih minimal 1 pola A-G'),
                          ),
                        );
                        return;
                      }
                      final rawName = name.text.trim();
                      final n = rawName.isEmpty
                          ? 'Kombinasi ${st.combos.length + 1}'
                          : (rawName.length > 40
                                ? rawName.substring(0, 40)
                                : rawName);
                      final rawNote = note.text.trim();
                      final cleanNote = rawNote.length > 100
                          ? rawNote.substring(0, 100)
                          : rawNote;

                      final messenger = ScaffoldMessenger.of(context);
                      await st.saveCombo(n, polas, cleanNote);
                      name.clear();
                      note.clear();
                      sel.clear();
                      if (!mounted) return;
                      setState(() {});
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Tersimpan! Cek halaman Kombinasi.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Simpan kombinasi'),
                  ),
                ],
              ),
            ),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📝 Daftar Kombinasi',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (st.combos.isEmpty)
                    const EmptyHint('Belum ada kombinasi')
                  else
                    for (final c in st.combos)
                      RowItem(
                        AppIcon(Icons.soup_kitchen_rounded, kolor(), size: 32),
                        c.name,
                        '${c.polas.join(' + ')} | ${c.polas.length * 2} hari',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => showComboSheet(context, c),
                              child: const Text('Buka'),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Hapus?'),
                                    content: Text(
                                      'Hapus kombinasi "${c.name}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          AppState.I.delCombo(c.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  if (widget.openDetail) const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color kolor() => Themes.buat.acc;
}

void showComboSheet(BuildContext context, Combo c) {
  final st = AppState.I;
  final total = st.comboCost(c.polas);
  final hari = c.polas.length * 2;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Star.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Star.overlay,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(c.name, style: AppText.cardTitle.copyWith(fontSize: 18)),
                Text(
                  '${c.polas.length} pola x 2 hari = $hari hari | ${rp(total)}',
                  style: AppText.secondary.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Star.warning.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Star.warning.withValues(alpha: .4),
                    ),
                  ),
                  child: Text(
                    c.note.isEmpty ? '-' : c.note,
                    style: AppText.body.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    AppState.I.addTxn("Belanja ${c.name}", total, kat: "sayur");
                    Navigator.pop(context);
                  },
                  child: const Text("Pakai belanja"),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
