// lib/petani_shell.dart
// Shell navigasi khusus untuk user dengan role 'petani'
// Tab: Beranda | Panen | Profil | Keluar
 
import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/petani/petani_beranda_screen.dart';
import 'screens/petani/petani_panen_screen.dart';
import 'screens/petani/petani_profil_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
 
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
    // Tunda navigasi ke frame berikutnya agar semua widget selesai dispose
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
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
 
  Widget _buildBottomNav() {
    final items = [
      {
        'icon': Icons.home_outlined,
        'iconFill': Icons.home,
        'label': 'BERANDA',
      },
      {
        'icon': Icons.agriculture_outlined,
        'iconFill': Icons.agriculture,
        'label': 'PANEN',
      },
      {
        'icon': Icons.person_outline,
        'iconFill': Icons.person,
        'label': 'PROFIL',
      },
    ];
 
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandDark.withValues(alpha: 0.12),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ...List.generate(items.length, (i) {
            final isActive = _selectedIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.brandDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? (items[i]['iconFill'] as IconData)
                          : (items[i]['icon'] as IconData),
                      color: isActive ? Colors.white : AppColors.outline,
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: isActive ? Colors.white : AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Tombol Keluar
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: AppColors.outline, size: 22),
                  SizedBox(height: 3),
                  Text(
                    'KELUAR',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.outline,
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