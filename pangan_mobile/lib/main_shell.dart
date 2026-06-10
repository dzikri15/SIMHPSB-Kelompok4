// lib/main_shell.dart

import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'main.dart'; // themeNotifier
import 'screens/beranda_screen.dart';
import 'screens/panen_screen.dart';
import 'screens/gudang_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    BerandaScreen(
      onNavigateToScreen: (index) {
        setState(() => _selectedIndex = index);
      },
    ),
    const PanenScreen(),
    const GudangScreen(),
  ];

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await AuthService().logout();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;
    final surfaceColor = isDark ? cs.surface : Colors.white;

    final items = [
      {'icon': Icons.home_outlined,        'iconFill': Icons.home,        'label': 'BERANDA'},
      {'icon': Icons.agriculture_outlined, 'iconFill': Icons.agriculture, 'label': 'PANEN'},
      {'icon': Icons.warehouse_outlined,   'iconFill': Icons.warehouse,   'label': 'GUDANG'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandDark.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Tab items
          ...List.generate(items.length, (i) {
            final isActive = _selectedIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark ? AppColors.darkPrimaryContainer : AppColors.brandDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? (items[i]['iconFill'] as IconData)
                          : (items[i]['icon'] as IconData),
                      color: isActive
                          ? (isDark ? AppColors.darkPrimary : cs.onPrimary)
                          : cs.onSurfaceVariant,
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: isActive
                            ? (isDark ? AppColors.darkPrimary : cs.onPrimary)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Logout
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: cs.onSurfaceVariant, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    'KELUAR',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
