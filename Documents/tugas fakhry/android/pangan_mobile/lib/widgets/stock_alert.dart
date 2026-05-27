// lib/widgets/stock_alert.dart

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class StockAlert extends StatelessWidget {
  final String namaKomoditas;
  final double jumlahStok;
  final double batasMinimum;
  final String status; // 'aman', 'rendah', 'kritis'

  const StockAlert({
    super.key,
    required this.namaKomoditas,
    required this.jumlahStok,
    required this.batasMinimum,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'aman':
        return AppColors.primary;
      case 'rendah':
        return const Color(0xFFF57C00); // Orange
      case 'kritis':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'aman':
        return 'STOK AMAN';
      case 'rendah':
        return 'STOK RENDAH';
      case 'kritis':
        return 'STOK KRITIS';
      default:
        return 'TIDAK DIKETAHUI';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusLabel = _getStatusLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan notifikasi alert stock
class StockAlertNotification extends StatelessWidget {
  final String namaKomoditas;
  final double jumlahStok;
  final String status; // 'rendah', 'kritis'
  final VoidCallback? onDismiss;

  const StockAlertNotification({
    super.key,
    required this.namaKomoditas,
    required this.jumlahStok,
    required this.status,
    this.onDismiss,
  });

  Color _getAlertColor() {
    return status == 'kritis' ? AppColors.error : const Color(0xFFF57C00);
  }

  IconData _getAlertIcon() {
    return status == 'kritis' ? Icons.warning_rounded : Icons.info_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final alertColor = _getAlertColor();
    final alertIcon = _getAlertIcon();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(alertIcon, color: alertColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock ${status.toLowerCase() == 'kritis' ? 'Kritis' : 'Rendah'}: $namaKomoditas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: alertColor,
                  ),
                ),
                Text(
                  'Sisa stok: ${jumlahStok.toStringAsFixed(2)} Ton',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: alertColor, size: 18),
            ),
        ],
      ),
    );
  }
}
