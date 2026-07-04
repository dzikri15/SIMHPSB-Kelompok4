// lib/services/tujuan_distribusi_service.dart

import '../models/tujuan_distribusi_model.dart';
import 'api_service.dart';

class TujuanDistribusiService {
  final ApiService _api = ApiService();

  /// GET /api/tujuan-distribusi
  /// Ambil semua tujuan distribusi
  Future<List<TujuanDistribusiModel>> getAll() async {
    try {
      final response = await _api.get('tujuan-distribusi');
      
      // Handle jika response adalah list langsung atau paginated
      final list = response is List ? response : (response['data'] is List ? response['data'] : []);
      
      return (list as List<dynamic>)
          .map((e) => TujuanDistribusiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat tujuan distribusi: $e');
    }
  }

  /// GET /api/tujuan-distribusi?page=x&search=y&with_stats=1
  Future<Map<String, dynamic>> getPaginated({int page = 1, String search = '', bool withStats = false}) async {
    try {
      final queryParams = <String>[];
      queryParams.add('page=$page');
      if (search.isNotEmpty) queryParams.add('search=$search');
      if (withStats) queryParams.add('with_stats=1');

      final url = 'tujuan-distribusi?${queryParams.join('&')}';
      final response = await _api.get(url);
      
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal memuat tujuan distribusi: $e');
    }
  }

  /// GET /api/tujuan-distribusi/{id}/histori
  Future<Map<String, dynamic>> getHistori(int id, {int page = 1}) async {
    try {
      final response = await _api.get('tujuan-distribusi/$id/histori?page=$page');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal memuat histori tujuan: $e');
    }
  }

  /// POST /api/tujuan-distribusi (admin only)
  Future<TujuanDistribusiModel> create(String nama) async {
    try {
      final data = await _api.post('tujuan-distribusi', {'nama': nama}) as Map<String, dynamic>;
      return TujuanDistribusiModel.fromJson(data);
    } catch (e) {
      throw Exception('Gagal membuat tujuan: $e');
    }
  }

  /// PUT /api/tujuan-distribusi/{id} (admin only)
  Future<TujuanDistribusiModel> update(int id, String nama) async {
    try {
      final data = await _api.put('tujuan-distribusi/$id', {'nama': nama}) as Map<String, dynamic>;
      return TujuanDistribusiModel.fromJson(data);
    } catch (e) {
      throw Exception('Gagal update tujuan: $e');
    }
  }

  /// DELETE /api/tujuan-distribusi/{id} (admin only)
  Future<void> delete(int id) async {
    try {
      await _api.delete('tujuan-distribusi/$id');
    } catch (e) {
      throw Exception('Gagal hapus tujuan: $e');
    }
  }
}
