// Ekspor/impor cadangan SELF VOLTA (satu file JSON berisi blob `sv_v1`).
//
// [NATIVE] Memakai `file_picker` (dialog file sistem / SAF Android).
// Menambah plugin native => butuh `shorebird release` baru, BUKAN patch.
//
// Aturan Fase 1: impor harus tervalidasi, dan data lama wajib dicadangkan
// ke `sv_v1_bak` sebelum ditimpa (dilakukan di AppState.importJson).

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Batas ukuran file impor (JSON blob pribadi normalnya < 1 MB).
const int kMaxBackupBytes = 8 * 1024 * 1024;

/// Ringkasan isi file cadangan, ditampilkan di dialog konfirmasi.
class BackupSummary {
  final int txns;
  final int todos;
  final int notes;
  final int meals;
  final int xp;
  final String xpDay;

  const BackupSummary({
    required this.txns,
    required this.todos,
    required this.notes,
    required this.meals,
    required this.xp,
    required this.xpDay,
  });

  String get description =>
      '$txns transaksi · $todos tugas · $notes catatan makan · '
      '$meals menu kustom\nXP: $xp'
      '${xpDay.isEmpty ? '' : ' · buku besar: $xpDay'}';
}

class BackupService {
  BackupService._();

  /// Kunci yang selalu ada di blob `sv_v1`. Minimal satu harus muncul
  /// agar file asing (foto, JSON lain) ditolak.
  static const Set<String> knownKeys = {
    'txns',
    'todos',
    'eatenM',
    'boughtM',
    'xp',
    'streak',
    'budget',
    'income',
    'workout',
    'piano',
    'customMeals',
    'mealNotes',
    'bumbu',
    'calYear',
  };

  /// Parse + validasi isi file. Melempar [FormatException] dengan pesan
  /// yang bisa langsung ditampilkan ke pengguna.
  static Map<String, dynamic> validate(String text) {
    if (text.trim().isEmpty) {
      throw const FormatException('File kosong.');
    }
    if (text.length > kMaxBackupBytes) {
      throw const FormatException('File terlalu besar (maksimal 8 MB).');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      throw const FormatException(
        'File bukan JSON yang valid. Pilih file hasil ekspor SELF VOLTA.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Isi file bukan objek JSON.');
    }
    if (!decoded.keys.any(knownKeys.contains)) {
      throw const FormatException(
        'File JSON tidak dikenali sebagai cadangan SELF VOLTA.',
      );
    }
    for (final key in ['txns', 'todos', 'mealNotes', 'customMeals', 'piano']) {
      final v = decoded[key];
      if (v != null && v is! List) {
        throw FormatException('Bagian "$key" rusak (harus berupa daftar).');
      }
    }
    for (final key in ['eatenM', 'boughtM', 'workout', 'xpClaimed', 'bumbu']) {
      final v = decoded[key];
      if (v != null && v is! Map) {
        throw FormatException('Bagian "$key" rusak (harus berupa objek).');
      }
    }
    final xp = decoded['xp'];
    if (xp != null && xp is! num) {
      throw const FormatException('Bagian "xp" rusak (harus berupa angka).');
    }
    return decoded;
  }

  static BackupSummary summarize(Map<String, dynamic> j) {
    int len(String key) => (j[key] as List?)?.length ?? 0;
    return BackupSummary(
      txns: len('txns'),
      todos: len('todos'),
      notes: len('mealNotes'),
      meals: len('customMeals'),
      xp: (j['xp'] as num?)?.toInt() ?? 0,
      xpDay: j['xpDay'] as String? ?? '',
    );
  }

  /// Buka dialog "simpan sebagai" milik sistem. Mengembalikan URI file
  /// yang ditulis, atau null bila pengguna membatalkan.
  static Future<Uri?> exportToFile(String json) {
    final now = DateTime.now();
    final stamp =
        '${now.year}${_two(now.month)}${_two(now.day)}-'
        '${_two(now.hour)}${_two(now.minute)}';
    return FilePicker.saveFile(
      dialogTitle: 'Simpan cadangan SELF VOLTA',
      fileName: 'selfvolta-backup-$stamp.json',
      mimeType: 'application/json',
      bytes: Uint8List.fromList(utf8.encode(json)),
    );
  }

  /// Buka dialog pilih file. Mengembalikan isi teks, atau null bila batal.
  static Future<String?> pickJsonText() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Pilih file cadangan SELF VOLTA',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('File yang dipilih kosong.');
    }
    if (bytes.length > kMaxBackupBytes) {
      throw const FormatException('File terlalu besar (maksimal 8 MB).');
    }
    try {
      return utf8.decode(bytes);
    } catch (_) {
      throw const FormatException('File tidak bisa dibaca sebagai teks UTF-8.');
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
