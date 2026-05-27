// lib/models/alert_model.dart

import 'user_model.dart';

class AlertModel {
  final int id;
  final String komoditas;
  final double stokSaatIni;
  final double batasMinimum;
  final String status;
  final int? ditanganiOleh;
  final UserModel? handler;
  final String? createdAt;

  const AlertModel({
    required this.id,
    required this.komoditas,
    required this.stokSaatIni,
    required this.batasMinimum,
    this.status = 'aktif',
    this.ditanganiOleh,
    this.handler,
    this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id:            json['id'] as int,
        komoditas:     json['komoditas'] as String,
        stokSaatIni:   (json['stok_saat_ini'] as num).toDouble(),
        batasMinimum:  (json['batas_minimum'] as num).toDouble(),
        status:        json['status'] as String? ?? 'aktif',
        ditanganiOleh: json['ditangani_oleh'] as int?,
        handler: json['handler'] != null
            ? UserModel.fromJson(json['handler'] as Map<String, dynamic>)
            : null,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'komoditas':      komoditas,
        'stok_saat_ini':  stokSaatIni,
        'batas_minimum':  batasMinimum,
        'status':         status,
        'ditangani_oleh': ditanganiOleh,
      };

  bool get isAktif  => status == 'aktif';
  bool get isProses => status == 'proses';
  bool get isSelesai => status == 'selesai';

  double get defisit => batasMinimum - stokSaatIni;
}
