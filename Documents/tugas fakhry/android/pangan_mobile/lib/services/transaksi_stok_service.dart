// lib/services/transaksi_stok_service.dart
// Menggunakan endpoint:
//   GET  /api/stok/transaksi        → daftar mutasi
//   POST /api/stok/catat            → catat transaksi baru

import '../models/transaksi_stok_model.dart';
import 'api_service.dart';

class TransaksiStokService {
  final ApiService _api = ApiService();

  /// Ambil daftar transaksi mutasi (paginated).
  /// Params opsional: jenis, komoditas, tanggal (YYYY-MM-DD), q (search)
  Future<List<TransaksiStokModel>> getAll({
    int page = 1,
    String? jenis,
    String? komoditas,
    String? tanggal,
    String? q,
  }) async {
    final params = StringBuffer('stok/transaksi?page=$page');
    if (jenis != null && jenis.isNotEmpty)     params.write('&jenis=$jenis');
    if (komoditas != null && komoditas.isNotEmpty) params.write('&komoditas=$komoditas');
    if (tanggal != null && tanggal.isNotEmpty) params.write('&tanggal=$tanggal');
    if (q != null && q.isNotEmpty)             params.write('&q=${Uri.encodeQueryComponent(q)}');

    final data = await _api.get(params.toString()) as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => TransaksiStokModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Catat transaksi baru.
  /// Body yang dikirim:
  ///   jenis, komoditas, jumlah, tanggal (opsional), 
  ///   tujuan_distribusi (opsional), keterangan (opsional), catatan (opsional)
  Future<TransaksiStokModel> create(Map<String, dynamic> body) async {
    final data = await _api.post('stok/catat', body) as Map<String, dynamic>;
    return TransaksiStokModel.fromJson(data);
  }

  /// Daftar pilihan komoditas
  List<String> getKomoditas() => ['Beras', 'Gabah', 'Jagung', 'Singkong'];

  /// Daftar pilihan jenis transaksi
  List<String> getJenisTransaksi() => ['Masuk', 'Keluar'];
}
