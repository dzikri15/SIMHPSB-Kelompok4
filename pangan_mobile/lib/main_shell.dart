// lib/main_shell.dart

import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/beranda_screen.dart';
import 'screens/panen_screen.dart';
import 'screens/gudang_screen.dart';
import 'screens/distribusi_tujuan_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'widgets/app_bottom_nav.dart';

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
    const DistribusiTujuanScreen(),
  ];

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          const AppBottomNavItem(
            icon: Icons.home_outlined,
            iconFill: Icons.home_rounded,
            label: 'Beranda',
          ),
          const AppBottomNavItem(
            icon: Icons.agriculture_outlined,
            iconFill: Icons.agriculture,
            label: 'Panen',
          ),
          const AppBottomNavItem(
            icon: Icons.warehouse_outlined,
            iconFill: Icons.warehouse_rounded,
            label: 'Gudang',
          ),
          const AppBottomNavItem(
            icon: Icons.location_on_outlined,
            iconFill: Icons.location_on_rounded,
            label: 'Distribusi',
          ),
          AppBottomNavItem(
            icon: Icons.logout_rounded,
            iconFill: Icons.logout_rounded,
            label: 'Keluar',
            isDestructive: true,
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
