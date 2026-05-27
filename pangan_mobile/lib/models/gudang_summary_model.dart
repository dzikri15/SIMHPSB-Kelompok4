// lib/models/gudang_summary_model.dart
// Model untuk response GET /api/stok/summary

class GudangSummaryModel {
  final double saldoBeras;
  final double saldoGabah;
  final double kapasitasBeras;
  final double kapasitasGabah;
  final double masukBulanIni;
  final double keluarBulanIni;
  final double masukBerasBulanIni;
  final double masukGabahBulanIni;
  final double keluarBerasBulanIni;
  final double keluarGabahBulanIni;
  final String? bulan;

  const GudangSummaryModel({
    required this.saldoBeras,
    required this.saldoGabah,
    required this.kapasitasBeras,
    required this.kapasitasGabah,
    required this.masukBulanIni,
    required this.keluarBulanIni,
    required this.masukBerasBulanIni,
    required this.masukGabahBulanIni,
    required this.keluarBerasBulanIni,
    required this.keluarGabahBulanIni,
    this.bulan,
  });

  factory GudangSummaryModel.fromJson(Map<String, dynamic> json) {
    return GudangSummaryModel(
      saldoBeras:           _d(json['saldo_beras']),
      saldoGabah:           _d(json['saldo_gabah']),
      kapasitasBeras:       _d(json['kapasitas_beras'], 1000),
      kapasitasGabah:       _d(json['kapasitas_gabah'], 2000),
      masukBulanIni:        _d(json['masuk_bulan_ini']),
      keluarBulanIni:       _d(json['keluar_bulan_ini']),
      masukBerasBulanIni:   _d(json['masuk_beras_bulan_ini']),
      masukGabahBulanIni:   _d(json['masuk_gabah_bulan_ini']),
      keluarBerasBulanIni:  _d(json['keluar_beras_bulan_ini']),
      keluarGabahBulanIni:  _d(json['keluar_gabah_bulan_ini']),
      bulan:                json['bulan'] as String?,
    );
  }

  // Persentase kapasitas
  double get persenBeras =>
      kapasitasBeras > 0 ? (saldoBeras / kapasitasBeras).clamp(0, 999) : 0;
  double get persenGabah =>
      kapasitasGabah > 0 ? (saldoGabah / kapasitasGabah).clamp(0, 999) : 0;
}

double _d(dynamic v, [double fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}
