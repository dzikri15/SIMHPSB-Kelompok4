// lib/services/alert_service.dart

import '../models/alert_model.dart';
import 'api_service.dart';

class AlertService {
  final ApiService _api = ApiService();

  Future<List<AlertModel>> getAll({int page = 1}) async {
    final data = await _api.get('alert?page=$page') as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Hanya alert yang stoknya di bawah minimum atau status = aktif.
  Future<List<AlertModel>> getMinimum() async {
    final data =
        await _api.get('alert/minimum') as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AlertModel> getById(int id) async {
    final data = await _api.get('alert/$id') as Map<String, dynamic>;
    return AlertModel.fromJson(data);
  }

  Future<AlertModel> create(Map<String, dynamic> body) async {
    final data = await _api.post('alert', body) as Map<String, dynamic>;
    return AlertModel.fromJson(data);
  }

  Future<AlertModel> update(int id, Map<String, dynamic> body) async {
    final data = await _api.put('alert/$id', body) as Map<String, dynamic>;
    return AlertModel.fromJson(data);
  }

  Future<void> delete(int id) => _api.delete('alert/$id');

  // ── Konfigurasi Batas Minimum ──────────────────────────────────────────

  /// GET /api/alert/konfigurasi
  Future<Map<String, double>> getKonfigurasi() async {
    final data = await _api.get('alert/konfigurasi') as Map<String, dynamic>;
    return {
      'batas_min_beras': _toDouble(data['batas_min_beras']),
      'batas_min_gabah': _toDouble(data['batas_min_gabah']),
    };
  }

  /// PUT /api/alert/konfigurasi
  Future<void> saveKonfigurasi({
    required double batasMinBeras,
    required double batasMinGabah,
  }) async {
    await _api.put('alert/konfigurasi', {
      'batas_min_beras': batasMinBeras,
      'batas_min_gabah': batasMinGabah,
    });
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
