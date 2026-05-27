// lib/models/gudang_model.dart
// Fix: Laravel kadang return angka sebagai String → pakai _toDouble() helper

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

class GudangModel {
  final int id;
  final String namaGudang;
  final String? lokasi;
  final double? kapasitas;
  final String status;

  const GudangModel({
    required this.id,
    required this.namaGudang,
    this.lokasi,
    this.kapasitas,
    this.status = 'aktif',
  });

  factory GudangModel.fromJson(Map<String, dynamic> json) => GudangModel(
        id:         _toInt(json['id']),
        namaGudang: json['nama_gudang'] as String,
        lokasi:     json['lokasi'] as String?,
        kapasitas:  _toDouble(json['kapasitas']),
        status:     json['status'] as String? ?? 'aktif',
      );

  Map<String, dynamic> toJson() => {
        'id':          id,
        'nama_gudang': namaGudang,
        'lokasi':      lokasi,
        'kapasitas':   kapasitas,
        'status':      status,
      };
}

// ── Stok ────────────────────────────────────────────────────────────────

class StokModel {
  final int id;
  final int gudangId;
  final double jumlahStok;
  final double batasMinimum;
  final String? tanggalUpdate;
  final String? catatan;
  final GudangModel? gudang;
  final String? monitoringStatus;

  const StokModel({
    required this.id,
    required this.gudangId,
    required this.jumlahStok,
    required this.batasMinimum,
    this.tanggalUpdate,
    this.catatan,
    this.gudang,
    this.monitoringStatus,
  });

  factory StokModel.fromJson(Map<String, dynamic> json) => StokModel(
        id:               _toInt(json['id']),
        gudangId:         _toInt(json['gudang_id']),
        jumlahStok:       _toDoubleRequired(json['jumlah_stok']),
        batasMinimum:     _toDoubleRequired(json['batas_minimum']),
        tanggalUpdate:    json['tanggal_update'] as String?,
        catatan:          json['catatan'] as String?,
        gudang: json['gudang'] != null
            ? GudangModel.fromJson(json['gudang'] as Map<String, dynamic>)
            : null,
        monitoringStatus: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'gudang_id':      gudangId,
        'jumlah_stok':    jumlahStok,
        'batas_minimum':  batasMinimum,
        'tanggal_update': tanggalUpdate,
        'catatan':        catatan,
      };

  bool get isLow =>
      monitoringStatus == 'low' || jumlahStok < batasMinimum;
}
