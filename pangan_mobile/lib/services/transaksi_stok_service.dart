// lib/services/transaksi_stok_service.dart
// Menggunakan endpoint:
//   GET  /api/stok/transaksi        → daftar mutasi
//   POST /api/stok/catat            → catat transaksi baru

import '../models/transaksi_stok_model.dart';
import 'api_service.dart';

class TransaksiStokService {
  final ApiService _api = ApiService();

  /// Build query string tanpa page (dipakai oleh getAllPages)
  String _buildParams({
    String? jenis,
    String? komoditas,
    String? tanggal,
    String? tanggalMulai,
    String? tanggalAkhir,
    String? q,
    String? status,
  }) {
    final params = StringBuffer();
    if (jenis != null && jenis.isNotEmpty)                params.write('&jenis=$jenis');
    if (komoditas != null && komoditas.isNotEmpty)        params.write('&komoditas=$komoditas');
    if (tanggal != null && tanggal.isNotEmpty)            params.write('&tanggal=$tanggal');
    if (tanggalMulai != null && tanggalMulai.isNotEmpty)  params.write('&tanggal_mulai=$tanggalMulai');
    if (tanggalAkhir != null && tanggalAkhir.isNotEmpty)  params.write('&tanggal_akhir=$tanggalAkhir');
    if (q != null && q.isNotEmpty)                        params.write('&q=${Uri.encodeQueryComponent(q)}');
    if (status != null && status.isNotEmpty)              params.write('&status=$status');
    return params.toString();
  }

  /// Ambil SEMUA transaksi (loop semua halaman API) agar paging Flutter bisa
  /// menampilkan data lengkap.
  Future<List<TransaksiStokModel>> getAll({
    int page = 1, // diabaikan — selalu ambil semua halaman
    String? jenis,
    String? komoditas,
    String? tanggal,
    String? tanggalMulai,
    String? tanggalAkhir,
    String? q,
    String? status,
  }) async {
    final extra = _buildParams(
      jenis: jenis, komoditas: komoditas, tanggal: tanggal,
      tanggalMulai: tanggalMulai, tanggalAkhir: tanggalAkhir,
      q: q, status: status,
    );

    final allItems = <TransaksiStokModel>[];
    int currentPage = 1;
    int lastPage    = 1;

    do {
      final data = await _api.get('stok/transaksi?page=$currentPage$extra')
          as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      allItems.addAll(
        list.map((e) => TransaksiStokModel.fromJson(e as Map<String, dynamic>)),
      );
      // Laravel paginate() taruh last_page langsung di root response
      lastPage = (data['last_page'] as int?) ?? 1;
      currentPage++;
    } while (currentPage <= lastPage);

    return allItems;
  }

  /// Catat transaksi baru dengan support file upload.
  /// 
  /// Parameters:
  ///   - body: form data (jenis_transaksi, komoditas, jumlah, tujuan_distribusi_id, etc)
  ///   - fotoBuktiBytes: optional bytes file untuk bukti pengiriman (foto)
  ///   - fotoBuktiName: nama file (dengan ekstensi), wajib jika fotoBuktiBytes ada
  Future<TransaksiStokModel> create(
    Map<String, dynamic> body,
    List<int>? fotoBuktiBytes, {
    String? fotoBuktiName,
  }) async {
    late dynamic data;

    if (fotoBuktiBytes != null) {
      // Convert body values to String for multipart, skip null values
      final formFields = <String, String>{};
      body.forEach((key, value) {
        // Skip null values - jangan include di form fields
        if (value != null) {
          formFields[key] = value.toString();
        }
      });

      data = await _api.uploadMultipart(
        'stok/catat',
        fileBytes: fotoBuktiBytes,
        fileName: fotoBuktiName ?? 'bukti.jpg',
        fileFieldName: 'foto_bukti',
        additionalFields: formFields,
      ) as Map<String, dynamic>;
    } else {
      // Normal POST jika tidak ada file
      data = await _api.post('stok/catat', body) as Map<String, dynamic>;
    }

    return TransaksiStokModel.fromJson(data);
  }

  /// Toggle status transaksi antara 'aktif' dan 'dibatalkan'.
  /// Mengembalikan status baru setelah toggle.
  Future<String> toggleStatus(int id) async {
    final data = await _api.patch('stok/$id/toggle-status') as Map<String, dynamic>;
    final updated = data['data'] as Map<String, dynamic>?;
    return updated?['status'] as String? ?? '';
  }

  /// Daftar pilihan komoditas
  List<String> getKomoditas() => ['Gabah', 'Beras'];

  /// Daftar pilihan jenis transaksi
  List<String> getJenisTransaksi() => ['Masuk', 'Keluar'];
}