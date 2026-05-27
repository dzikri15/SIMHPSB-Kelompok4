// lib/screens/konfigurasi_alert_screen.dart

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/stok_service.dart';
import '../widgets/app_top_bar.dart';

class KonfigurasiAlertScreen extends StatefulWidget {
  const KonfigurasiAlertScreen({super.key});

  @override
  State<KonfigurasiAlertScreen> createState() => _KonfigurasiAlertScreenState();
}

class _KonfigurasiAlertScreenState extends State<KonfigurasiAlertScreen> {
  final StokService _stokService = StokService();
  late Future _futureStok;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _futureStok = _stokService.getMonitoring();
  }

  Future<void> _refreshStok() async {
    setState(() {
      _futureStok = _stokService.getMonitoring();
    });
  }

  void _showEditDialog(dynamic stok) {
    final batasController = TextEditingController(
      text: stok.batasMinimum.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ubah Batas Minimum - ${stok.gudang?.namaGudang ?? 'Unknown'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stok Saat Ini:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              '${stok.jumlahStok.toStringAsFixed(2)} kg',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Batas Minimum (kg):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: batasController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Masukkan batas minimum',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newBatas = double.tryParse(batasController.text);
              if (newBatas != null && newBatas >= 0) {
                try {
                  await _stokService.update(
                    stok.id,
                    {'batas_minimum': newBatas},
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _refreshStok();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Batas minimum berhasil diubah'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(double stok, double batas) {
    if (stok >= batas) {
      return AppColors.primary;
    } else if (stok >= batas * 0.5) {
      return const Color(0xFFF57C00);
    } else {
      return AppColors.error;
    }
  }

  String _getStatusLabel(double stok, double batas) {
    if (stok >= batas) {
      return 'Aman';
    } else if (stok >= batas * 0.5) {
      return 'Rendah';
    } else {
      return 'Kritis';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(showBack: true),
      body: FutureBuilder(
        future: _futureStok,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final stokList = snapshot.data as List? ?? [];

          return RefreshIndicator(
            onRefresh: _refreshStok,
            color: AppColors.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Konfigurasi Batas Minimum',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Atur batas minimum stok untuk setiap gudang',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...stokList.map((stok) {
                    final status = _getStatusLabel(
                      stok.jumlahStok,
                      stok.batasMinimum,
                    );
                    final statusColor = _getStatusColor(
                      stok.jumlahStok,
                      stok.batasMinimum,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outline.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stok.gudang?.namaGudang ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Stok Saat Ini',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${stok.jumlahStok.toStringAsFixed(2)} kg',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Batas Minimum',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${stok.batasMinimum.toStringAsFixed(2)} kg',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Kapasitas',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(stok.kapasitas ?? 0).toStringAsFixed(0)} kg',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showEditDialog(stok),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Ubah Batas Minimum',
                                style: TextStyle(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
