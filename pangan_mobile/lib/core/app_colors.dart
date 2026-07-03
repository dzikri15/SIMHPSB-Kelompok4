import 'package:flutter/material.dart';

class AppColors {
  // ══════════════════════════════════════════
  // LIGHT MODE
  // ══════════════════════════════════════════

  // Primary
  static const primary = Color(0xFF3A694A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFBDF0C6);
  static const onPrimaryContainer = Color(0xFF00210F);
  static const primaryFixed = Color(0xFFBDF0C6);
  static const primaryFixedDim = Color(0xFFA2D3AB);
  static const primaryDim = Color(0xFFA2D3AB);
  static const onPrimaryFixed = Color(0xFF00210F);
  static const onPrimaryFixedVariant = Color(0xFF224E33);
  static const inversePrimary = Color(0xFFA2D3AB);
  static const surfaceTint = Color(0xFF3A694A);

  // Secondary
  static const secondary = Color(0xFF526354);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFDCE5DC);
  static const onSecondaryContainer = Color(0xFF111F14);
  static const secondaryFixed = Color(0xFFDCE5DC);
  static const secondaryFixedDim = Color(0xFFB6CCB8);
  static const secondaryDim = Color(0xFFB6CCB8);
  static const onSecondaryFixed = Color(0xFF121D16);
  static const onSecondaryFixedVariant = Color(0xFF3B4B3D);

  // Tertiary
  static const tertiary = Color(0xFF3A6550);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFC7EACB);
  static const onTertiaryContainer = Color(0xFF002113);
  static const tertiaryFixed = Color(0xFFC7EACB);
  static const tertiaryFixedDim = Color(0xFFABD3B5);
  static const tertiaryDim = Color(0xFFABD3B5);
  static const onTertiaryFixed = Color(0xFF002113);
  static const onTertiaryFixedVariant = Color(0xFF224E39);

  // Surface
  static const background = Color(0xFFF5FBF6);
  static const onBackground = Color(0xFF191C1A);
  static const surface = Color(0xFFF5FBF6);
  static const surfaceBright = Color(0xFFF5FBF6);
  static const surfaceDim = Color(0xFFD7DAD7);
  static const surfaceVariant = Color(0xFFDDE5DB);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF6FBF6);
  static const surfaceContainer = Color(0xFFF0F4F0);
  static const surfaceContainerHigh = Color(0xFFE9ECE9);
  static const surfaceContainerHighest = Color(0xFFE1E4E1);
  static const onSurface = Color(0xFF191C1A);
  static const onSurfaceVariant = Color(0xFF414942);
  static const inverseSurface = Color(0xFF2E312E);
  static const inverseOnSurface = Color(0xFFEFF1EE);

  // Outline
  static const outline = Color(0xFF717971);
  static const outlineVariant = Color(0xFFC1C9C0);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);
  static const errorDim = Color(0xFFFFB4AB);

  // Brand-specific
  static const brandDark = Color(0xFF012D1D);
  static const brandMedium = Color(0xFF1B4332);

  // Accent colors untuk UI components
  static const accentBlue = Color(0xFF1565C0);
  static const accentBlueLight = Color(0xFFE3F2FD);
  static const accentOrange = Color(0xFFE65100);
  static const accentOrangeLight = Color(0xFFFFF3E0);
  static const accentGreen = primary;
  static const accentGreenLight = primaryContainer;
  static const accentRed = error;
  static const accentRedLight = Color(0xFFFFEBEE);

  // ══════════════════════════════════════════
  // DARK MODE
  // Dipetakan dari dark-mode.css web (SIMHP)
  // --green-400 → primary, --surface-2 → surface, dsb.
  // ══════════════════════════════════════════

  // Primary dark  (--green-400: #3db370)
  static const darkPrimary = Color(0xFF3DB370);
  static const darkOnPrimary = Color(0xFF00210F);
  static const darkPrimaryContainer = Color(0xFF1A5C38); // --green-600
  static const darkOnPrimaryContainer = Color(0xFFD1FAE5); // --text-primary

  // Secondary dark  (--green-300: #5fcc90)
  static const darkSecondary = Color(0xFF5FCC90);
  static const darkOnSecondary = Color(0xFF0A1F14); // --green-900
  static const darkSecondaryContainer = Color(0xFF123524); // --green-700
  static const darkOnSecondaryContainer = Color(0xFFD1FAE5);

  // Tertiary dark
  static const darkTertiary = Color(0xFF6FCF97); // --text-secondary
  static const darkOnTertiary = Color(0xFF091A10); // --green-50
  static const darkTertiaryContainer = Color(0xFF0E2A1C); // --green-800
  static const darkOnTertiaryContainer = Color(0xFFD1FAE5);

  // Surface dark
  static const darkBackground = Color(0xFF0F1F17);    // --surface
  static const darkSurface = Color(0xFF152B1E);        // --surface-2
  static const darkSurface2 = Color(0xFF152B1E);       // --surface-2
  static const darkSurface3 = Color(0xFF1A3326);       // --surface-3
  static const darkOnSurface = Color(0xFFD1FAE5);      // --text-primary
  static const darkOnSurfaceVariant = Color(0xFF6FCF97); // --text-secondary
  static const darkInverseSurface = Color.fromARGB(255, 209, 250, 229);
  static const darkInverseOnSurface = Color(0xFF0F1F17);
  static const darkSurfaceContainerLowest = Color(0xFF0A1F14); // --green-900
  static const darkSurfaceContainerLow = Color(0xFF0E2A1C);
  static const darkSurfaceContainer = Color(0xFF0F1F17);
  static const darkSurfaceContainerHigh = Color(0xFF152B1E);
  static const darkSurfaceContainerHighest = Color(0xFF1A3326);

  // Outline dark
  static const darkOutline = Color.fromRGBO(74, 144, 104, 1);        // --text-muted
  static const darkOutlineVariant = Color(0xFF1E3D2A); // --border

  // Error dark
  static const darkError = Color(0xFFDC2626);          // --red-500
  static const darkOnError = Color(0xFFFFFFFF);
  static const darkErrorContainer = Color(0xFF2D0A0A); // --red-100
  static const darkOnErrorContainer = Color(0xFFF87171);

  // ══════════════════════════════════════════
  // HELPER METHODS untuk mendapatkan theme-aware colors
  // ══════════════════════════════════════════

  /// Dapatkan warna teks utama berdasarkan brightness
  static Color onSurfaceByContext(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Dapatkan warna teks sekunder berdasarkan brightness
  static Color onSurfaceVariantByContext(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  /// Dapatkan warna outline berdasarkan brightness
  static Color outlineByContext(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  /// Dapatkan warna surface berdasarkan brightness
  static Color surfaceByContext(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
}
