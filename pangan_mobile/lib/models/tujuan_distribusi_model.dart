// lib/models/tujuan_distribusi_model.dart

class TujuanDistribusiModel {
  final int id;
  final String nama;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TujuanDistribusiModel({
    required this.id,
    required this.nama,
    this.createdAt,
    this.updatedAt,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  @override
  String toString() => 'TujuanDistribusi(id: $id, nama: $nama)';
}
