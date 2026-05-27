// lib/screens/alert_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';
import '../widgets/app_top_bar.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final AlertService _alertService = AlertService();
  late Future<List<AlertModel>> _futureAlerts;

  @override
  void initState() {
    super.initState();
    _futureAlerts = _alertService.getAll();
  }

  Future<void> _refreshAlerts() async {
    setState(() {
      _futureAlerts = _alertService.getAll();
    });
  }

  Future<void> _markAsHandled(int alertId, String newStatus) async {
    try {
      await _alertService.update(alertId, {'status': newStatus});
      _refreshAlerts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status berhasil diupdate ke $newStatus'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return AppColors.error;
      case 'proses':
        return const Color(0xFFF57C00);
      case 'selesai':
        return AppColors.primary;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return 'Alert Aktif';
      case 'proses':
        return 'Dalam Penanganan';
      case 'selesai':
        return 'Sudah Ditangani';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return Icons.warning_rounded;
      case 'proses':
        return Icons.hourglass_bottom_rounded;
      case 'selesai':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: FutureBuilder<List<AlertModel>>(
        future: _futureAlerts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error.withOpacity(0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshAlerts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final alerts = snapshot.data ?? [];
          final aktifCount = alerts.where((a) => a.isAktif).length;
          final prosesCount = alerts.where((a) => a.isProses).length;
          final selesaiCount = alerts.where((a) => a.isSelesai).length;

          return RefreshIndicator(
            onRefresh: _refreshAlerts,
            color: AppColors.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Alert Stok',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Notifikasi otomatis saat stok mendekati batas minimum',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ringkasan Status Alert
                  const Text(
                    'Ringkasan Status Alert',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          title: 'Alert Aktif',
                          count: aktifCount,
                          color: AppColors.error,
                          icon: Icons.warning_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          title: 'Dalam Penanganan',
                          count: prosesCount,
                          color: const Color(0xFFF57C00),
                          icon: Icons.hourglass_bottom_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          title: 'Sudah Ditangani',
                          count: selesaiCount,
                          color: AppColors.primary,
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Riwayat Alert
                  const Text(
                    'Riwayat Alert',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Semua notifikasi sistem, terbaru di atas',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alert List
                  if (alerts.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 48,
                            color: AppColors.onSurfaceVariant.withOpacity(0.4),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada alert',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: alerts.map((alert) {
                        return _buildAlertItem(alert);
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AlertModel alert) {
    final statusColor = _getStatusColor(alert.status);
    final statusLabel = _getStatusLabel(alert.status);
    final statusIcon = _getStatusIcon(alert.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.komoditas,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Stok: ${alert.stokSaatIni.toStringAsFixed(2)} kg',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Batas Min: ${alert.batasMinimum.toStringAsFixed(2)} kg',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.createdAt != null
                          ? DateFormat('dd MMM yyyy HH:mm')
                              .format(DateTime.parse(alert.createdAt!))
                          : 'Tanggal tidak tersedia',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (alert.handler != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'By: ${alert.handler!.name}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (alert.isAktif)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markAsHandled(alert.id, 'proses'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tandai Ditangani',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
              else if (alert.isProses)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markAsHandled(alert.id, 'selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tandai Selesai',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✓ Sudah Ditangani',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
