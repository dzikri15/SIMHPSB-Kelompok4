// lib/petani_shell.dart
// Shell navigasi khusus untuk user dengan role 'petani'

import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'main.dart'; // themeNotifier
import 'screens/petani/petani_beranda_screen.dart';
import 'screens/petani/petani_panen_screen.dart';
import 'screens/petani/petani_profil_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'widgets/app_bottom_nav.dart';

class PetaniShell extends StatefulWidget {
  const PetaniShell({super.key});

  @override
  State<PetaniShell> createState() => _PetaniShellState();
}

class _PetaniShellState extends State<PetaniShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    PetaniBerandaScreen(
      onNavigateToTab: (index) => setState(() => _selectedIndex = index),
    ),
    const PetaniPanenScreen(),
    const PetaniProfilScreen(),
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
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
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
            icon: Icons.person_outline_rounded,
            iconFill: Icons.person_rounded,
            label: 'Profil',
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
