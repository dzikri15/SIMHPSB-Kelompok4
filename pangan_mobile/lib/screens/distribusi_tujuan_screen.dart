// lib/screens/distribusi_tujuan_screen.dart
// Manajemen Tujuan Distribusi - Daftar untuk dipilih saat catat transaksi

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../widgets/app_top_bar.dart';
import '../services/tujuan_distribusi_service.dart';
import '../models/tujuan_distribusi_model.dart';
import 'distribusi_histori_screen.dart';
import 'dart:async';

class DistribusiTujuanScreen extends StatefulWidget {
  final VoidCallback? onLogoutTap;
  const DistribusiTujuanScreen({super.key, this.onLogoutTap});

  @override
  State<DistribusiTujuanScreen> createState() => _DistribusiTujuanScreenState();
}

class _DistribusiTujuanScreenState extends State<DistribusiTujuanScreen> {
  final TujuanDistribusiService _tujuanService = TujuanDistribusiService();
  
  bool _isAdding = false;
  bool _isDeleting = false;
  final _namaController = TextEditingController();

  // Pagination & Search State
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<TujuanDistribusiModel> _tujuanList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  // Stats State
  int _totalTujuan = 0;
  String _tujuanTerbanyak = '-';
  num _totalDikirimBulanIni = 0;

  @override
  void initState() {
    super.initState();
    _fetchData(refresh: true);
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
      _fetchData();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchData(refresh: true);
    });
  }

  Future<void> _fetchData({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _tujuanList.clear();
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response = await _tujuanService.getPaginated(
        page: _currentPage,
        search: _searchController.text,
        withStats: refresh, // Ambil stats hanya saat refresh/halaman 1
      );

      final data = response['data'] as List;
      final newItems = data.map((e) => TujuanDistribusiModel.fromJson(e)).toList();

      setState(() {
        _currentPage++;
        _tujuanList.addAll(newItems);
        if (newItems.isEmpty || data.length < 15) {
          _hasMore = false;
        }

        if (refresh && response['summary'] != null) {
          final summary = response['summary'];
          _totalTujuan = int.tryParse(summary['total_tujuan'].toString()) ?? 0;
          _tujuanTerbanyak = summary['tujuan_terbanyak']?.toString() ?? '-';
          _totalDikirimBulanIni = num.tryParse(summary['total_dikirim_bulan_ini'].toString()) ?? 0;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddDialog() {
    _namaController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tujuan Distribusi'),
        content: TextField(
          controller: _namaController,
          decoration: InputDecoration(
            hintText: 'Nama tujuan',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _isAdding ? null : _handleAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isAdding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _handleAdd() async {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tujuan tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isAdding = true);
    try {
      await _tujuanService.create(nama);
      if (mounted) {
        Navigator.pop(context);
        _fetchData(refresh: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tujuan "$nama" berhasil ditambah')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  void _showDeleteDialog(TujuanDistribusiModel tujuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tujuan'),
        content: Text('Apakah Anda yakin ingin menghapus "${tujuan.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _isDeleting ? null : () => _handleDelete(tujuan),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _handleDelete(TujuanDistribusiModel tujuan) async {
    setState(() => _isDeleting = true);
    try {
      await _tujuanService.delete(tujuan.id);
      if (mounted) {
        Navigator.pop(context);
        _fetchData(refresh: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tujuan "${tujuan.nama}" berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatNumber = NumberFormat('#,##0', 'id_ID');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        showMenu: widget.onLogoutTap != null,
        showLogout: widget.onLogoutTap != null,
        showPetaniList: true,
        onLogoutTap: widget.onLogoutTap,
      ),
      body: Column(
        children: [
          // Header dengan tombol Tambah
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manajemen Tujuan Distribusi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lokasi tujuan pengiriman stok pangan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),

          // Stat Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatCard('Total Tujuan', '$_totalTujuan Lokasi', Icons.location_on, AppColors.primary),
                const SizedBox(width: 10),
                _buildStatCard('Terbanyak (Bln Ini)', _tujuanTerbanyak, Icons.trending_up, Colors.orange),
                const SizedBox(width: 10),
                _buildStatCard('Terkirim (Bln Ini)', '${formatNumber.format(_totalDikirimBulanIni)} Kg', Icons.local_shipping, Colors.green),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari tujuan distribusi...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Daftar Tujuan
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchData(refresh: true),
              child: _buildDaftarTujuan(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarTujuan() {
    if (_tujuanList.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada tujuan distribusi',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final formatNumber = NumberFormat('#,##0', 'id_ID');

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          // Tabel Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'NAMA TUJUAN',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'TOTAL TERKIRIM',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'DIBUAT',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    'AKSI',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Tabel Rows
          ...List.generate(_tujuanList.length, (index) {
            final tujuan = _tujuanList[index];
            final createdDate = tujuan.createdAt != null
                ? DateFormat('yyyy-MM-dd').format(tujuan.createdAt!)
                : '-';
                
            final totalTerkirim = tujuan.totalTerkirim ?? 0;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DistribusiHistoriScreen(tujuan: tujuan),
                  ),
                );
              },
              child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      tujuan.nama,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${formatNumber.format(totalTerkirim)} Kg',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      createdDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Center(
                      child: InkWell(
                        onTap: () => _showDeleteDialog(tujuan),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.delete, size: 14, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            );
          }),

          // Loading indicator at bottom
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),

          // Tabel Footer
          if (!_isLoading && !_hasMore && _tujuanList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'Semua tujuan telah dimuat.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
