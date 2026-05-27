// lib/services/laporan_service.dart
// Service terhubung ke Laravel API untuk semua jenis laporan SIMHPSB

import '../services/api_service.dart';

class LaporanService {
  final ApiService _api = ApiService();

  // ── Laporan Panen ────────────────────────────────────────────────────────
  /// GET /api/laporan/panen?petani_id=&dari=&sampai=
  Future<Map<String, dynamic>> getLaporanPanen({
    String? petaniId,
    String? dari,
    String? sampai,
  }) async {
    final params = <String>[];
    if (petaniId != null && petaniId != 'semua') params.add('petani_id=$petaniId');
    if (dari != null) params.add('dari=$dari');
    if (sampai != null) params.add('sampai=$sampai');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final data = await _api.get('laporan/panen$query') as Map<String, dynamic>;
    return data;
  }

  // ── Laporan Stok ─────────────────────────────────────────────────────────
  /// GET /api/laporan/stok?komoditas=&dari=&sampai=
  Future<Map<String, dynamic>> getLaporanStok({
    String? komoditas,
    String? dari,
    String? sampai,
  }) async {
    final params = <String>[];
    if (komoditas != null && komoditas != 'semua') params.add('komoditas=$komoditas');
    if (dari != null) params.add('dari=$dari');
    if (sampai != null) params.add('sampai=$sampai');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final data = await _api.get('laporan/stok$query') as Map<String, dynamic>;
    return data;
  }

  // ── Laporan Margin ───────────────────────────────────────────────────────
  /// GET /api/laporan/margin?petani_id=&dari=&sampai=
  Future<Map<String, dynamic>> getLaporanMargin({
    String? petaniId,
    String? dari,
    String? sampai,
  }) async {
    final params = <String>[];
    if (petaniId != null && petaniId != 'semua') params.add('petani_id=$petaniId');
    if (dari != null) params.add('dari=$dari');
    if (sampai != null) params.add('sampai=$sampai');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final data = await _api.get('laporan/margin$query') as Map<String, dynamic>;
    return data;
  }

  // ── Daftar petani untuk dropdown ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getPetaniDropdown() async {
    try {
      final data = await _api.get('petani?per_page=200') as Map<String, dynamic>;
      final list = (data['data'] as List<dynamic>? ?? []);
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }
}
