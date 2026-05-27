// lib/models/panen_model.dart
// Fix: _toDouble handles String values from Laravel

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

class PanenModel {
  final int id;
  final int lahanId;
  final String tanggalPanen;
  final double jumlahGabah;
  final double? hargaGabahPerKg;
  final double? konversiBeras;
  final String? catatan;
  final LahanModel? lahan;

  const PanenModel({
    required this.id,
    required this.lahanId,
    required this.tanggalPanen,
    required this.jumlahGabah,
    this.hargaGabahPerKg,
    this.konversiBeras,
    this.catatan,
    this.lahan,
  });

  factory PanenModel.fromJson(Map<String, dynamic> json) => PanenModel(
        id:              _toInt(json['id']),
        lahanId:         _toInt(json['lahan_id']),
        tanggalPanen:    json['tanggal_panen'] as String,
        jumlahGabah:     _toDoubleRequired(json['jumlah_gabah']),
        hargaGabahPerKg: _toDouble(json['harga_gabah_per_kg']),
        konversiBeras:   _toDouble(json['konversi_beras']),
        catatan:         json['catatan'] as String?,
        lahan: json['lahan'] != null
            ? LahanModel.fromJson(json['lahan'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id':                 id,
        'lahan_id':           lahanId,
        'tanggal_panen':      tanggalPanen,
        'jumlah_gabah':       jumlahGabah,
        'harga_gabah_per_kg': hargaGabahPerKg,
        'konversi_beras':     konversiBeras,
        'catatan':            catatan,
      };

  double get nilaiPanen => jumlahGabah * (hargaGabahPerKg ?? 0);
}
