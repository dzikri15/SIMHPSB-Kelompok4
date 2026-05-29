// lib/services/petani_profile_service.dart
// Service khusus untuk role 'petani' — mengambil data profil & panen milik sendiri

import '../models/panen_model.dart';
import '../models/petani_model.dart';
import 'api_service.dart';

class PetaniProfileService {
  static final PetaniProfileService _instance = PetaniProfileService._internal();
  factory PetaniProfileService() => _instance;
  PetaniProfileService._internal();

  final ApiService _api = ApiService();

  /// Ambil profil petani yang sedang login
  Future<PetaniModel> getProfile() async {
    final data = await _api.get('petani-profile') as Map<String, dynamic>;
    return PetaniModel.fromJson(data);
  }

  /// Ambil ringkasan statistik untuk dashboard
  Future<Map<String, dynamic>> getRingkasan() async {
    final data = await _api.get('petani-profile/ringkasan') as Map<String, dynamic>;
    return data;
  }

  /// Ambil daftar panen milik petani yang login
  Future<List<PanenModel>> getPanen({int page = 1, int perPage = 20}) async {
    final data = await _api.get('petani-profile/panen?page=$page&per_page=$perPage')
        as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => PanenModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil detail satu catatan panen
  Future<PanenModel> getPanenDetail(int id) async {
    final data = await _api.get('petani-profile/panen/$id') as Map<String, dynamic>;
    return PanenModel.fromJson(data);
  }
}
