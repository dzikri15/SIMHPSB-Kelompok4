// lib/models/lahan_model.dart
// FIXED: gabungan field lama (komoditas) + field baru (lokasi, jenisTanah)

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class LahanModel {
  final int     id;
  final int     petaniId;
  final String? namaLahan;
  final double? luas;
  final String? komoditas;   // ← field lama, dipakai petani_screen.dart
  final String? lokasi;      // ← field baru, dipakai petani_profil_screen.dart
  final String? jenisTanah;  // ← field baru
  final String? status;

  const LahanModel({
    required this.id,
    required this.petaniId,
    this.namaLahan,
    this.luas,
    this.komoditas,
    this.lokasi,
    this.jenisTanah,
    this.status,
  });

  factory LahanModel.fromJson(Map<String, dynamic> json) => LahanModel(
        id:        _toInt(json['id']),
        petaniId:  _toInt(json['petani_id']),
        namaLahan: json['nama_lahan'] as String?,
        luas:      _toDouble(json['luas']),
        komoditas: json['komoditas'] as String?,
        lokasi:    json['lokasi'] as String?,
        jenisTanah:json['jenis_tanah'] as String?,
        status:    json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':          id,
        'petani_id':   petaniId,
        'nama_lahan':  namaLahan,
        'luas':        luas,
        'komoditas':   komoditas,
        'lokasi':      lokasi,
        'jenis_tanah': jenisTanah,
        'status':      status,
      };
}
