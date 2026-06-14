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
