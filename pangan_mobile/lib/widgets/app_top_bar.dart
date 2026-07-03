// lib/widgets/app_top_bar.dart
// Updated: tambah tombol "Laporan" di sebelah kiri ikon notifikasi

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';


class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBack;
  final bool showAlert;
  final bool showProfile;
  final bool showLogout;
  final bool showMenu;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;
  const AppTopBar({
    super.key,
    this.showBack = false,
    this.showAlert = true,
    this.showProfile = false,
    this.showLogout = false,
    this.showMenu = false,
    this.onProfileTap,
    this.onLogoutTap,
  });

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
    final isDark = themeNotifier.value == ThemeMode.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final surfaceColor = Theme.of(context).scaffoldBackgroundColor;
    
    return Container(
      color: surfaceColor.withValues(alpha: 0.9),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              if (widget.showBack)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  color: Theme.of(context).colorScheme.onSurface,
                )
              else ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withValues(alpha: 0.8),
                        secondaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.network(
                      'https://raw.githubusercontent.com/NoahMikhailovna/foto/c45c72f9adca95001eefebd49d7581e89d0de508/padi_logo_fitted.svg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'SIMHP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
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
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                      if (aktifCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              aktifCount.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // ── Profile Icon (petani) ─────────────────────────────────────
              if (widget.showProfile)
                IconButton(
                  onPressed: widget.onProfileTap,
                  icon: Icon(
                    Icons.person_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
                ),

              // ── Menu Dropdown (Profil, Dark Mode + Logout) ────────────────
              if (widget.showMenu)
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'profile') {
                      widget.onProfileTap?.call();
                    } else if (value == 'dark_mode') {
                      themeNotifier.value = themeNotifier.value == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    } else if (value == 'logout') {
                      widget.onLogoutTap?.call();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    if (widget.onProfileTap != null)
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Profil Saya',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuItem<String>(
                      value: 'dark_mode',
                      child: Row(
                        children: [
                          Icon(
                            themeNotifier.value == ThemeMode.dark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            themeNotifier.value == ThemeMode.dark
                                ? 'Light Mode'
                                : 'Dark Mode',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.showLogout)
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Keluar',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
