// lib/services/petani_service.dart

import '../models/petani_model.dart';
import 'api_service.dart';

class PetaniService {
  final ApiService _api = ApiService();

  Future<List<PetaniModel>> getAll({int page = 1}) async {
    final data = await _api.get('petani?page=$page') as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => PetaniModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PetaniModel> getById(int id) async {
    final data = await _api.get('petani/$id') as Map<String, dynamic>;
    return PetaniModel.fromJson(data);
  }

  Future<PetaniModel> create(Map<String, dynamic> body) async {
    final data = await _api.post('petani', body) as Map<String, dynamic>;
    return PetaniModel.fromJson(data);
  }

  Future<PetaniModel> update(int id, Map<String, dynamic> body) async {
    final data = await _api.put('petani/$id', body) as Map<String, dynamic>;
    return PetaniModel.fromJson(data);
  }

  Future<void> delete(int id) => _api.delete('petani/$id');

  Future<void> toggleStatus(int id) async {
    await _api.patch('petani/$id/toggle-status');
  }
}
