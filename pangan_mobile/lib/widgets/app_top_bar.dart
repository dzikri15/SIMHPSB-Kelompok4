// lib/widgets/app_top_bar.dart
// Updated: tambah tombol "Laporan" di sebelah kiri ikon notifikasi

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';

class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBack;
  final bool showAlert;
  const AppTopBar({super.key, this.showBack = false, this.showAlert = true});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  final AlertService _alertService = AlertService();
  late Future<List<AlertModel>> _futureAlerts;

  @override
  void initState() {
    super.initState();
    _futureAlerts = _alertService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.9),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              if (widget.showBack)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.brandDark,
                )
              else ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF68D391), Color(0xFF2F855A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x6638A169),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌾', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'SIMHPSB',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
              const Spacer(),

              // ── Ikon Notifikasi / Alert (hanya petugas) ──────────────────
              if (widget.showAlert)
              FutureBuilder<List<AlertModel>>(
                future: _futureAlerts,
                builder: (context, snapshot) {
                  final aktifCount = snapshot.hasData
                      ? snapshot.data!.where((a) => a.isAktif).length
                      : 0;

                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/alert');
                        },
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.brandDark,
                          size: 24,
                        ),
                      ),
                      if (aktifCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              aktifCount.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
