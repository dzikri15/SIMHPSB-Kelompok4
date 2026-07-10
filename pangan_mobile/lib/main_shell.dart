// lib/main_shell.dart

import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/beranda_screen.dart';
import 'screens/panen_screen.dart';
import 'screens/gudang_screen.dart';
import 'screens/distribusi_tujuan_screen.dart';
import 'screens/chatbot_screen.dart';
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

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return BerandaScreen(
          onNavigateToScreen: (idx) {
            setState(() => _selectedIndex = idx);
          },
          onLogoutTap: _logout,
        );
      case 1:
        return PanenScreen(onLogoutTap: _logout);
      case 2:
        return GudangScreen(onLogoutTap: _logout);
      case 3:
        return DistribusiTujuanScreen(onLogoutTap: _logout);
      case 4:
        return ChatbotScreen(onLogoutTap: _logout);
      default:
        return const SizedBox.shrink();
    }
  }

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
      body: _buildScreen(_selectedIndex),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          AppBottomNavItem(
            icon: Icons.home_outlined,
            iconFill: Icons.home_rounded,
            label: 'Beranda',
          ),
          AppBottomNavItem(
            icon: Icons.agriculture_outlined,
            iconFill: Icons.agriculture,
            label: 'Panen',
          ),
          AppBottomNavItem(
            icon: Icons.warehouse_outlined,
            iconFill: Icons.warehouse_rounded,
            label: 'Gudang',
          ),
          AppBottomNavItem(
            icon: Icons.location_on_outlined,
            iconFill: Icons.location_on_rounded,
            label: 'Distribusi',
          ),
          AppBottomNavItem(
            icon: Icons.smart_toy_outlined,
            iconFill: Icons.smart_toy_rounded,
            label: 'HPSBBot',
          ),
        ],
      ),
    );
  }
}
