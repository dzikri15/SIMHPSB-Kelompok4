// lib/services/panen_service.dart

import 'dart:typed_data';
import '../models/panen_model.dart';
import 'api_service.dart';

class PanenService {
  final ApiService _api = ApiService();

  /// Ambil SEMUA data panen (loop semua halaman API) agar paging Flutter
  /// bisa menampilkan data lengkap.
  Future<List<PanenModel>> getAll({int page = 1}) async {
    final allItems = <PanenModel>[];
    int currentPage = 1;
    int lastPage    = 1;

    do {
      final data = await _api.get('panen?page=$currentPage') as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      allItems.addAll(
        list.map((e) => PanenModel.fromJson(e as Map<String, dynamic>)),
      );
      // Laravel paginate() taruh last_page langsung di root response
      lastPage = (data['last_page'] as int?) ?? 1;
      currentPage++;
    } while (currentPage <= lastPage);

    return allItems;
  }

  Future<PanenModel> getById(int id) async {
    final data = await _api.get('panen/$id') as Map<String, dynamic>;
    return PanenModel.fromJson(data);
  }

  /// Buat catatan panen BARU — wajib menyertakan foto bukti via multipart.
  /// Backend akan otomatis mencatat Gabah Masuk ke stok & snapshot harga.
  Future<PanenModel> createWithFoto(
    Map<String, dynamic> body,
    Uint8List fotoBytes, {
    String fotoName = 'bukti_panen.jpg',
  }) async {
    // Konversi semua nilai body ke String (multipart hanya terima String)
    final formFields = <String, String>{};
    body.forEach((key, value) {
      if (value != null) formFields[key] = value.toString();
    });

    final data = await _api.uploadMultipart(
      'panen',
      fileBytes: fotoBytes,
      fileName: fotoName,
      fileFieldName: 'foto_bukti',
      additionalFields: formFields,
    ) as Map<String, dynamic>;

    return PanenModel.fromJson(data);
  }

  /// Update catatan panen (tanpa foto) — pakai JSON biasa.
  Future<PanenModel> update(int id, Map<String, dynamic> body) async {
    final data = await _api.put('panen/$id', body) as Map<String, dynamic>;
    return PanenModel.fromJson(data);
  }

  Future<void> delete(int id) => _api.delete('panen/$id');
}