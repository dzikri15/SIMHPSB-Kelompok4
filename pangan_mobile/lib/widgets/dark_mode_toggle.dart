// lib/widgets/dark_mode_toggle.dart
//
// Tombol toggle dark mode — sama seperti tombol di topbar web SIMHP.
// Taruh di mana saja: AppBar actions, settings page, dsb.
//
// Contoh pakai di AppBar:
//   actions: const [DarkModeToggle()],

import 'package:flutter/material.dart';
import '../main.dart'; // import themeNotifier

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
            ),
          ),
          onPressed: () {
            themeNotifier.value =
                isDark ? ThemeMode.light : ThemeMode.dark;
          },
        );
      },
    );
  }
}
