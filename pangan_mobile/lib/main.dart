// lib/main.dart

import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/alert_screen.dart';
import 'main_shell.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const SimhpsbApp());
}

class SimhpsbApp extends StatelessWidget {
  const SimhpsbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMHPSB',
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

/// Cek token lokal → tampilkan LoginScreen atau MainShell.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final loggedIn = snapshot.data ?? false;
        return loggedIn ? const MainShell() : const LoginScreen();
      },
    );
  }
}
