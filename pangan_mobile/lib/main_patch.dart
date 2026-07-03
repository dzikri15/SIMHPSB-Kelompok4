// ══════════════════════════════════════════════════════════════════════
// PATCH 1: lib/main.dart
// Ganti class AuthGate agar route ke PetaniShell atau MainShell
// berdasarkan role yang disimpan di cache.
// ══════════════════════════════════════════════════════════════════════

// lib/main.dart  ← VERSI LENGKAP (replace file lama)

import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/alert_screen.dart';
import 'main_shell.dart';
import 'petani_shell.dart';          // ← TAMBAH
import 'services/auth_service.dart';
import 'models/user_model.dart';     // ← TAMBAH

void main() {
  runApp(const SimhpApp());
}

class SimhpApp extends StatelessWidget {
  const SimhpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMHP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          error: AppColors.error,
          onError: AppColors.onError,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'sans-serif',
      ),
      home: const AuthGate(),
      routes: {
        '/alert': (context) => const AlertScreen(),
      },
    );
  }
}

/// Cek token lokal → tampilkan LoginScreen, MainShell (petugas/admin), atau PetaniShell.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      // getCachedUser() sekarang untuk mendapatkan role juga
      future: _resolveUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        // Route berdasarkan role
        if (user.isPetani) return const PetaniShell();
        return const MainShell();
      },
    );
  }

  Future<UserModel?> _resolveUser() async {
    final isLoggedIn = await AuthService().isLoggedIn();
    if (!isLoggedIn) return null;
    return AuthService().getCachedUser();
  }
}


// ══════════════════════════════════════════════════════════════════════
// PATCH 2: lib/screens/login_screen.dart
// Ganti blok _login() agar setelah login, route ke shell yang benar
// ══════════════════════════════════════════════════════════════════════

// Ganti method _login() di _LoginScreenState dengan ini:

/*
  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await AuthService().login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (!mounted) return;

      // ── Role-based routing ──────────────────────────────────────────
      final Widget shell = user.isPetani
          ? const PetaniShell()   // import 'package:pangan_mobile/petani_shell.dart';
          : const MainShell();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => shell),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
*/

// Jangan lupa tambahkan import di bagian atas login_screen.dart:
// import '../petani_shell.dart';
