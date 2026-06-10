// lib/main.dart

import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/alert_screen.dart';
import 'main_shell.dart';
import 'petani_shell.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';

/// Global notifier untuk dark/light mode.
/// Akses dari mana saja: `themeNotifier.value = ThemeMode.dark`
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.light);

void main() {
  runApp(const SimhpsbApp());
}

class SimhpsbApp extends StatelessWidget {
  const SimhpsbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'SIMHPSB',
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          // ── LIGHT THEME ──────────────────────────────────────
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

          // ── DARK THEME ───────────────────────────────────────
          // Warna dipetakan dari dark-mode.css web SIMHPSB
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

          home: const AuthGate(),
          routes: {
            '/alert': (context) => const AlertScreen(),
          },
        );
      },
    );
  }
}

/// Cek token lokal → tampilkan LoginScreen atau MainShell.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
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
        if (user == null) return const LoginScreen();
        return user.isPetani ? const PetaniShell() : const MainShell();
      },
    );
  }
}
