// lib/models/panen_model.dart
// Fix:
//  1. tanggalPanen: hapus jam (T17:00:00.000000Z) → tampil "2026-05-26" saja
//  2. musimTanam: baca dari field 'musim' (DB) ATAU 'musim_tanam' (Flutter kirim)
//  3. namaPetani: ambil dari relasi lahan.petani.nama

import '../core/constants.dart';
import 'lahan_model.dart';

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

double _toDoubleRequired(dynamic v) => _toDouble(v) ?? 0.0;

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// Bersihkan tanggal dari Laravel: "2026-05-26T17:00:00.000000Z" → "2026-05-26"
String _cleanTanggal(String raw) {
  // Ambil hanya bagian tanggal sebelum 'T' atau spasi
  if (raw.contains('T')) return raw.split('T').first;
  if (raw.contains(' ')) return raw.split(' ').first;
  return raw;
}

class PanenModel {
  final int id;
  final int lahanId;
  final int? petaniId;
  final String? petaniNama;
  final String tanggalPanen;    // Format bersih: "YYYY-MM-DD"
  final double jumlahGabah;
  final double? hargaGabahPerKg;  // Snapshot historis — tidak berubah walau harga master diubah
  final double? konversiBeras;    // Hasil beras dalam kg (bukan persentase)
  final String? musimTanam;       // Nilai dari kolom 'musim' di DB
  final String? komoditas;
  final String? catatan;
  final LahanModel? lahan;
  final String? fotoBuktiUrl;     // URL foto bukti panen dari backend

  // Nama petani: dari relasi API, fallback ke lahan atau petani_id
  String get namaPetani {
    if (petaniNama != null && petaniNama!.isNotEmpty) return petaniNama!;
    if (petaniId != null) return 'Petani #$petaniId';
    return lahan?.namaLahan ?? 'Petani';
  }

  // Label musim yang rapi untuk tabel
  String? get musimLabel {
    if (musimTanam == null || musimTanam!.isEmpty) return null;
    const map = {
      'kemarau':           'Kemarau',
      'hujan':             'Hujan',
      // backward compat nilai lama
      'apr_sep_2025':      'Kemarau',
      'okt_mar_2025_2026': 'Hujan',
      'apr_sep_2026':      'Kemarau',
      'okt_mar_2026_2027': 'Hujan',
    };
    return map[musimTanam] ?? musimTanam;
  }

  const PanenModel({
    required this.id,
    required this.lahanId,
    this.petaniId,
    this.petaniNama,
    required this.tanggalPanen,
    required this.jumlahGabah,
    this.hargaGabahPerKg,
    this.konversiBeras,
    this.musimTanam,
    this.komoditas,
    this.catatan,
    this.lahan,
    this.fotoBuktiUrl,
  });

  factory PanenModel.fromJson(Map<String, dynamic> json) {
    // Ambil nama petani dari berbagai kemungkinan path relasi Laravel
    String? petaniNama;
    if (json['petani'] != null && json['petani'] is Map) {
      petaniNama = (json['petani'] as Map<String, dynamic>)['nama'] as String?;
    } else if (json['lahan'] != null) {
      final lahanMap = json['lahan'] as Map<String, dynamic>;
      if (lahanMap['petani'] != null && lahanMap['petani'] is Map) {
        petaniNama = (lahanMap['petani'] as Map<String, dynamic>)['nama'] as String?;
      }
    }

    // Baca musim: cek 'musim' (kolom DB) dulu, lalu 'musim_tanam'
    final musimRaw = json['musim'] as String?
        ?? json['musim_tanam'] as String?;

    // Tanggal: bersihkan format ISO yang punya jam
    final tanggalRaw = json['tanggal_panen'] as String? ?? '';
    final tanggalBersih = _cleanTanggal(tanggalRaw);

    return PanenModel(
      id:              _toInt(json['id']),
      lahanId:         _toInt(json['lahan_id']),
      petaniId:        json['petani_id'] != null ? _toInt(json['petani_id']) : null,
      petaniNama:      petaniNama,
      tanggalPanen:    tanggalBersih,
      jumlahGabah:     _toDoubleRequired(json['jumlah_gabah']),
      // hargaGabahPerKg adalah snapshot historis — JANGAN hitung ulang
      hargaGabahPerKg: _toDouble(json['harga_gabah_per_kg']),
      konversiBeras:   _toDouble(json['konversi_beras']),
      musimTanam:      musimRaw,
      komoditas:       json['komoditas'] as String?,
      catatan:         json['catatan'] as String?,
      lahan: json['lahan'] != null
          ? LahanModel.fromJson(json['lahan'] as Map<String, dynamic>)
          : null,
      // URL foto bukti: gunakan field 'foto_bukti' (path relatif dari storage)
      // dan konversi via AppConstants.getStorageFileUrl() agar melewati route
      // /api/file/{path} yang sudah CORS-friendly untuk Flutter Web.
      fotoBuktiUrl: _buildFotoUrl(json),
    );
  }

  /// Bangun URL foto yang bisa diakses lintas-origin (via file proxy)
  static String? _buildFotoUrl(Map<String, dynamic> json) {
    // 1. Coba dari path relatif foto_bukti (panen/bukti/...)
    final relativePath = json['foto_bukti'] as String?;
    if (relativePath != null && relativePath.isNotEmpty && !relativePath.startsWith('http')) {
      return AppConstants.getStorageFileUrl(relativePath);
    }
    // 2. Coba dari foto_bukti_url yang sudah full URL (fallback)
    final fullUrl = json['foto_bukti_url'] as String?;
    if (fullUrl != null && fullUrl.isNotEmpty) {
      // Jika URL dari asset() Laravel, convert ke file proxy
      // Contoh: http://localhost/storage/panen/bukti/... → /api/file/panen/bukti/...
      if (fullUrl.contains('/storage/')) {
        final storageParts = fullUrl.split('/storage/');
        if (storageParts.length > 1) {
          return AppConstants.getStorageFileUrl(storageParts.last);
        }
      }
      return fullUrl;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id':                 id,
        'lahan_id':           lahanId,
        'petani_id':          petaniId,
        'tanggal_panen':      tanggalPanen,
        'jumlah_gabah':       jumlahGabah,
        'harga_gabah_per_kg': hargaGabahPerKg,
        'konversi_beras':     konversiBeras,
        'musim_tanam':        musimTanam,
        'komoditas':          komoditas,
        'catatan':            catatan,
      };

  /// Penghasilan = jumlah_gabah × harga_gabah_per_kg (snapshot historis)
  /// JANGAN ganti dengan harga master terbaru.
  double get penghasilan => jumlahGabah * (hargaGabahPerKg ?? 0);

  /// Alias untuk kompatibilitas kode lama
  double get nilaiPanen => penghasilan;
}
