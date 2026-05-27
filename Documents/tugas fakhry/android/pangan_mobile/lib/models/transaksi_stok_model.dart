// lib/models/transaksi_stok_model.dart
// Disesuaikan dengan field yang dikembalikan GET /api/stok/transaksi

import 'gudang_model.dart';

class TransaksiStokModel {
  final int id;
  final int? gudangId;
  final String? jenisTransaksi; // 'masuk' / 'keluar'
  final String? komoditas;
  final double? jumlah;
  final double? jumlahStok;
  final String? keterangan;
  final String? catatan;
  final String? tanggalLabel; // formatted 'YYYY-MM-DD HH:mm'
  final String? dicatatOleh;
  final GudangModel? gudang;

  const TransaksiStokModel({
    required this.id,
    this.gudangId,
    this.jenisTransaksi,
    this.komoditas,
    this.jumlah,
    this.jumlahStok,
    this.keterangan,
    this.catatan,
    this.tanggalLabel,
    this.dicatatOleh,
    this.gudang,
  });

  factory TransaksiStokModel.fromJson(Map<String, dynamic> json) {
    // Coba parse tanggal dari berbagai kemungkinan field
    String? tglLabel = json['tanggal_label'] as String?;
    if (tglLabel == null || tglLabel == '-') {
      final raw = json['tanggal_update'] ?? json['tanggal'] ?? json['created_at'];
      if (raw != null) {
        try {
          final dt = DateTime.parse(raw.toString());
          tglLabel =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } catch (_) {
          tglLabel = raw.toString();
        }
      }
    }

    GudangModel? gudang;
    if (json['gudang'] != null) {
      try {
        gudang = GudangModel.fromJson(json['gudang'] as Map<String, dynamic>);
      } catch (_) {}
    }

    return TransaksiStokModel(
      id:            _toInt(json['id']),
      gudangId:      json['gudang_id'] != null ? _toInt(json['gudang_id']) : null,
      jenisTransaksi: json['jenis_transaksi'] as String?,
      komoditas:     json['komoditas'] as String?,
      jumlah:        _toDouble(json['jumlah']),
      jumlahStok:    _toDouble(json['jumlah_stok']),
      keterangan:    json['keterangan'] as String?,
      catatan:       json['catatan'] as String?,
      tanggalLabel:  tglLabel,
      dicatatOleh:   json['dicatat_oleh'] as String? ?? json['user']?['name'] as String?,
      gudang:        gudang,
    );
  }

  bool get isMasuk => (jenisTransaksi ?? '').toLowerCase() == 'masuk';

  String get komoditasDisplay => komoditas ?? '-';

  String get keteranganDisplay => keterangan ?? catatan ?? '-';

  String get saldoDisplay {
    if (jumlahStok == null) return '-';
    final v = jumlahStok!;
    return v >= 1000
        ? '${(v / 1000).toStringAsFixed(1)} Ton'
        : '${v.toStringAsFixed(0)} kg';
  }

  String get jumlahDisplay {
    if (jumlah == null) return '-';
    final prefix = isMasuk ? '+' : '-';
    final v = jumlah!;
    return '$prefix${v >= 1000 ? (v / 1000).toStringAsFixed(1) : v.toStringAsFixed(0)} kg';
  }
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
