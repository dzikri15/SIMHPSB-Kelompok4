// lib/models/petani_model.dart
// Fix: Laravel kadang return angka sebagai String → pakai _toDouble() helper

import 'lahan_model.dart';

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

class PetaniModel {
  final int id;
  final String nama;
  final String? nik;
  final String? alamat;
  final String? telepon;
  final String? noHp;
  final String? email;
  final String? tanggalLahir;
  final String status;
  final double? luasLahan;
  final String? komoditas;
  final String? catatan;
  final List<LahanModel> lahan;

  const PetaniModel({
    required this.id,
    required this.nama,
    this.nik,
    this.alamat,
    this.telepon,
    this.noHp,
    this.email,
    this.tanggalLahir,
    this.status = 'aktif',
    this.luasLahan,
    this.komoditas,
    this.catatan,
    this.lahan = const [],
  });

  factory PetaniModel.fromJson(Map<String, dynamic> json) => PetaniModel(
        id:           _toInt(json['id']),
        nama:         json['nama'] as String,
        nik:          json['nik'] as String?,
        alamat:       json['alamat'] as String?,
        telepon:      json['telepon'] as String?,
        noHp:         json['no_hp'] as String?,
        email:        json['email'] as String?,
        tanggalLahir: json['tanggal_lahir'] as String?,
        status:       json['status'] as String? ?? 'aktif',
        luasLahan:    _toDouble(json['luas_lahan']),
        komoditas:    json['komoditas'] as String?,
        catatan:      json['catatan'] as String?,
        lahan: (json['lahan'] as List<dynamic>? ?? [])
            .map((e) => LahanModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id':            id,
        'nama':          nama,
        'nik':           nik,
        'alamat':        alamat,
        'telepon':       telepon,
        'no_hp':         noHp,
        'email':         email,
        'tanggal_lahir': tanggalLahir,
        'status':        status,
        'luas_lahan':    luasLahan,
        'komoditas':     komoditas,
        'catatan':       catatan,
      };

  bool get isAktif => status == 'aktif';
}
