// lib/models/lahan_model.dart
// Fix: _toDouble handles String values from Laravel

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
  final int id;
  final int petaniId;
  final String? namaLahan;
  final double? luas;
  final String? komoditas;
  final String? status;

  const LahanModel({
    required this.id,
    required this.petaniId,
    this.namaLahan,
    this.luas,
    this.komoditas,
    this.status,
  });

  factory LahanModel.fromJson(Map<String, dynamic> json) => LahanModel(
        id:        _toInt(json['id']),
        petaniId:  _toInt(json['petani_id']),
        namaLahan: json['nama_lahan'] as String?,
        luas:      _toDouble(json['luas']),
        komoditas: json['komoditas'] as String?,
        status:    json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':         id,
        'petani_id':  petaniId,
        'nama_lahan': namaLahan,
        'luas':       luas,
        'komoditas':  komoditas,
        'status':     status,
      };
}
