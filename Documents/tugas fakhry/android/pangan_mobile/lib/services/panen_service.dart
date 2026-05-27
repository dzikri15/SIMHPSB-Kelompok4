// lib/services/panen_service.dart

import '../models/panen_model.dart';
import 'api_service.dart';

class PanenService {
  final ApiService _api = ApiService();

  Future<List<PanenModel>> getAll({int page = 1}) async {
    final data = await _api.get('panen?page=$page') as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => PanenModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PanenModel> getById(int id) async {
    final data = await _api.get('panen/$id') as Map<String, dynamic>;
    return PanenModel.fromJson(data);
  }

  Future<PanenModel> create(Map<String, dynamic> body) async {
    final data = await _api.post('panen', body) as Map<String, dynamic>;
    return PanenModel.fromJson(data);
  }

  Future<PanenModel> update(int id, Map<String, dynamic> body) async {
    final data = await _api.put('panen/$id', body) as Map<String, dynamic>;
    return PanenModel.fromJson(data);
  }

  Future<void> delete(int id) => _api.delete('panen/$id');
}
