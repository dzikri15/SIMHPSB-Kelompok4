import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../core/app_colors.dart';
import '../core/constants.dart';
import '../models/petani_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/petani_service.dart';
import '../widgets/app_top_bar.dart';

class PetaniListScreen extends StatefulWidget {
  const PetaniListScreen({super.key});

  @override
  State<PetaniListScreen> createState() => _PetaniListScreenState();
}

class _PetaniListScreenState extends State<PetaniListScreen> {
  final PetaniService _petaniService = PetaniService();
  final ApiService _api = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<PetaniModel> _petaniList = [];
  bool _isLoading = true;
  bool _isDownloading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase();
      });
    });
    _loadPetani();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPetani() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      int page = 1;
      bool hasMore = true;
      List<PetaniModel> allPetani = [];

      while (hasMore) {
        final data = await _api.get('petani?page=$page');
        if (data == null || data['data'] == null) {
          hasMore = false;
        } else {
          final list = data['data'] as List<dynamic>;
          if (list.isEmpty) {
            hasMore = false;
          } else {
            allPetani.addAll(
                list.map((e) => PetaniModel.fromJson(e as Map<String, dynamic>)));
            page++;
          }
        }
      }

      if (mounted) {
        allPetani.sort(
            (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
        setState(() {
          _petaniList = allPetani;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data petani: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final token = await AuthService().getToken();
      final url = '${AppConstants.baseUrl}/petani/export-pdf';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      // Simpan ke folder cache
      final dir = await getTemporaryDirectory();
      final filename =
          'data_petani_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);

      // Buka file
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil diunduh. Pastikan ada aplikasi PDF di perangkat.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _toggleStatus(PetaniModel petani) async {
    try {
      await _petaniService.toggleStatus(petani.id);

      setState(() {
        final index = _petaniList.indexWhere((p) => p.id == petani.id);
        if (index != -1) {
          final old = _petaniList[index];
          final newStatus = old.status == 'aktif' ? 'nonaktif' : 'aktif';
          _petaniList[index] = PetaniModel(
            id: old.id,
            nama: old.nama,
            nik: old.nik,
            alamat: old.alamat,
            telepon: old.telepon,
            noHp: old.noHp,
            email: old.email,
            tanggalLahir: old.tanggalLahir,
            status: newStatus,
            luasLahan: old.luasLahan,
            komoditas: old.komoditas,
            catatan: old.catatan,
            lahan: old.lahan,
          );
        }
      });

      if (mounted) {
        final current =
            _petaniList.firstWhere((p) => p.id == petani.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status ${petani.nama} → ${current.status == 'aktif' ? 'Aktif' : 'Non-aktif'}'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mengubah status: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _petaniList
        .where((p) => p.nama.toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      appBar: const AppTopBar(showBack: true, showAlert: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header + Download Button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Icon(Icons.people_alt_outlined,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Data Petani',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                // Tombol Download PDF
                GestureDetector(
                  onTap: _isDownloading ? null : _downloadPdf,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: _isDownloading
                          ? null
                          : LinearGradient(
                              colors: [
                                Colors.red[700]!,
                                Colors.red[500]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color:
                          _isDownloading ? Colors.grey[300] : null,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _isDownloading
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isDownloading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Icon(Icons.picture_as_pdf,
                                color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _isDownloading ? 'Mengunduh...' : 'PDF',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isDownloading
                                ? Colors.grey[600]
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      size: 20,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Cari nama petani...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: Icon(Icons.close,
                          size: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),

          // ── List Petani ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadPetani,
                    color: AppColors.primary,
                    child: filteredList.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.2),
                              Center(
                                child: Text(
                                  'Tidak ada data petani',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 32),
                            itemCount: filteredList.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final p = filteredList[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surface,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primary
                                                .withValues(alpha: 0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          p.nama
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.nama,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            p.telepon ?? '-',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: p.status == 'aktif'
                                                  ? Colors.green
                                                      .withValues(alpha: 0.1)
                                                  : Colors.red
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              p.status == 'aktif'
                                                  ? 'Aktif'
                                                  : 'Non-aktif',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: p.status == 'aktif'
                                                    ? Colors.green[700]
                                                    : Colors.red[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Toggle Switch
                                    Column(
                                      children: [
                                        Text(
                                          'Status',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                        Switch(
                                          value: p.status == 'aktif',
                                          onChanged: (val) =>
                                              _toggleStatus(p),
                                          activeColor: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
