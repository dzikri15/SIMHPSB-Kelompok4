// lib/main.dart
// PATCH: Ganti `home: const AuthGate()` menjadi `home: const LandingGuard()`
// LandingGuard → jika sudah login langsung ke Shell, jika belum → LandingScreen

import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/landing_screen.dart';        // ← IMPORT BARU
import 'screens/alert_screen.dart';
import 'screens/distribusi_tujuan_screen.dart';
import 'main_shell.dart';
import 'petani_shell.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';

final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.light);

void main() {
  runApp(const SimhpApp());
}

class SimhpApp extends StatelessWidget {
  const SimhpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'SIMHP',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
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
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkPrimary,
              onPrimary: AppColors.darkOnPrimary,
              primaryContainer: AppColors.darkPrimaryContainer,
              onPrimaryContainer: AppColors.darkOnPrimaryContainer,
              secondary: AppColors.darkSecondary,
              onSecondary: AppColors.darkOnSecondary,
              secondaryContainer: AppColors.darkSecondaryContainer,
              onSecondaryContainer: AppColors.darkOnSecondaryContainer,
              tertiary: AppColors.darkTertiary,
              onTertiary: AppColors.darkOnTertiary,
              tertiaryContainer: AppColors.darkTertiaryContainer,
              onTertiaryContainer: AppColors.darkOnTertiaryContainer,
              surface: AppColors.darkSurface,
              onSurface: AppColors.darkOnSurface,
              onSurfaceVariant: AppColors.darkOnSurfaceVariant,
              inverseSurface: AppColors.darkInverseSurface,
              onInverseSurface: AppColors.darkInverseOnSurface,
              surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
              surfaceContainerLow: AppColors.darkSurfaceContainerLow,
              surfaceContainer: AppColors.darkSurfaceContainer,
              surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
              surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
              error: AppColors.darkError,
              onError: AppColors.darkOnError,
              errorContainer: AppColors.darkErrorContainer,
              onErrorContainer: AppColors.darkOnErrorContainer,
              outline: AppColors.darkOutline,
              outlineVariant: AppColors.darkOutlineVariant,
            ),
            scaffoldBackgroundColor: AppColors.darkBackground,
            fontFamily: 'sans-serif',
          ),

          // ─── GANTI home ke LandingGuard ───────────────────
          home: const LandingGuard(),
          routes: {
            '/alert': (context) => const AlertScreen(),
            '/distribusi-tujuan': (context) => const DistribusiTujuanScreen(),
          },
        );
      },
    );
  }
}

/// Cek token lokal:
/// - Belum login → LandingScreen (liquid_swipe onboarding)
/// - Sudah login  → MainShell / PetaniShell langsung
class LandingGuard extends StatefulWidget {
  const LandingGuard({super.key});

  @override
  State<LandingGuard> createState() => _LandingGuardState();
}

class _LandingGuardState extends State<LandingGuard> {
  Future<UserModel?> _resolveShell() async {
    final loggedIn = await AuthService().isLoggedIn();
    if (!loggedIn) return null;
    return AuthService().getCachedUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _resolveShell(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;

        // Belum login → tampilkan landing page
        if (user == null) return const LandingScreen();

        // Sudah login → langsung ke shell yang sesuai
        return user.isPetani ? const PetaniShell() : const MainShell();
      },
    );
  }
}