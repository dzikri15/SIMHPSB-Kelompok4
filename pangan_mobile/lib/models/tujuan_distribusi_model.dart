// lib/models/tujuan_distribusi_model.dart

class TujuanDistribusiModel {
  final int id;
  final String nama;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final num? totalTerkirim;

  const TujuanDistribusiModel({
    required this.id,
    required this.nama,
    this.createdAt,
    this.updatedAt,
    this.totalTerkirim,
  });

  factory TujuanDistribusiModel.fromJson(Map<String, dynamic> json) {
    return TujuanDistribusiModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      totalTerkirim: json['total_terkirim'] != null 
          ? num.tryParse(json['total_terkirim'].toString()) 
          : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'total_terkirim': totalTerkirim,
  };

  @override
  String toString() => 'TujuanDistribusi(id: $id, nama: $nama, total: $totalTerkirim)';
}
