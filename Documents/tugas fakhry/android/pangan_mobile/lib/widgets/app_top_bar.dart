import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';

class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBack;
  const AppTopBar({super.key, this.showBack = false});

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
      color: AppColors.background.withOpacity(0.9),
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
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield, color: AppColors.primary, size: 20),
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
