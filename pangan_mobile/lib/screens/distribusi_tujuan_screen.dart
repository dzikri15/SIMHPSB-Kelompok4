// lib/screens/distribusi_tujuan_screen.dart
// Manajemen Tujuan Distribusi - Daftar untuk dipilih saat catat transaksi

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../widgets/app_top_bar.dart';
import '../services/tujuan_distribusi_service.dart';
import '../models/tujuan_distribusi_model.dart';

class DistribusiTujuanScreen extends StatefulWidget {
  const DistribusiTujuanScreen({super.key});

  @override
  State<DistribusiTujuanScreen> createState() => _DistribusiTujuanScreenState();
}

class _DistribusiTujuanScreenState extends State<DistribusiTujuanScreen> {
  final TujuanDistribusiService _tujuanService = TujuanDistribusiService();
  int _refreshKey = 0;
  bool _isAdding = false;
  bool _isDeleting = false;
  
  final _namaController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _refreshKey++);

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
        _refresh();
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
        _refresh();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppTopBar(),
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
                          fontSize: 28,
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
                  label: const Text('Tambah Tujuan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Tujuan
          Expanded(
            child: _buildDaftarTujuan(),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarTujuan() {
    return FutureBuilder<List<TujuanDistribusiModel>>(
      key: ValueKey('daftar_$_refreshKey'),
      future: _tujuanService.getAll(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text('Error: ${snap.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final tujuanList = snap.data ?? [];
        if (tujuanList.isEmpty) {
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

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      width: 40,
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
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'DIBUAT',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'AKSI',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Tabel Rows
              ...List.generate(tujuanList.length, (index) {
                final tujuan = tujuanList[index];
                final createdDate = tujuan.createdAt != null
                    ? DateFormat('yyyy-MM-dd').format(tujuan.createdAt!)
                    : '-';

                return Container(
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
                        width: 40,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tujuan.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          createdDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDeleteDialog(tujuan),
                            icon: const Icon(Icons.delete, size: 14),
                            label: const Text(
                              'Hapus',
                              style: TextStyle(fontSize: 10),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[50],
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Tabel Footer
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
                    'Total: ${tujuanList.length} tujuan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
