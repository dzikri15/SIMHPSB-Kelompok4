// lib/services/stok_service.dart

import '../models/gudang_model.dart';
import '../models/gudang_summary_model.dart';
import 'api_service.dart';

class StokService {
  final ApiService _api = ApiService();

  Future<List<StokModel>> getAll({int page = 1}) async {
    final data = await _api.get('stok?page=$page') as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => StokModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StokModel>> getMonitoring() async {
    final list = await _api.get('stok/monitoring') as List<dynamic>;
    return list
        .map((e) => StokModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ringkasan statistik gudang: saldo, masuk/keluar bulan ini, kapasitas
  Future<GudangSummaryModel> getSummary() async {
    final data = await _api.get('stok/summary') as Map<String, dynamic>;
    return GudangSummaryModel.fromJson(data);
  }

  Future<StokModel> getById(int id) async {
    final data = await _api.get('stok/$id') as Map<String, dynamic>;
    return StokModel.fromJson(data);
  }

  /// Ambil stok terkini untuk komoditas tertentu (untuk validasi client-side)
  /// Returns: {jumlah_stok, batas_minimum, komoditas}
  Future<Map<String, dynamic>> getCurrentStok(String komoditas) async {
    try {
      final data = await _api.get('stok/current?komoditas=$komoditas') as Map<String, dynamic>;
      return data;
    } catch (e) {
      // Jika API gagal, kembalikan default nilai aman
      return {
        'jumlah_stok': 0,
        'batas_minimum': 500,
        'komoditas': komoditas,
      };
    }
  }

  Future<StokModel> create(Map<String, dynamic> body) async {
    final data = await _api.post('stok', body) as Map<String, dynamic>;
    return StokModel.fromJson(data);
  }

  Future<StokModel> update(int id, Map<String, dynamic> body) async {
    final data = await _api.put('stok/$id', body) as Map<String, dynamic>;
    return StokModel.fromJson(data);
  }

  Future<void> delete(int id) => _api.delete('stok/$id');
}
