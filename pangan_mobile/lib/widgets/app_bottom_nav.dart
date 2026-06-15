// lib/widgets/app_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../main.dart';

class AppBottomNavItem {
  final IconData icon;
  final IconData iconFill;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const AppBottomNavItem({
    required this.icon,
    required this.iconFill,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });
}

class AppBottomNav extends StatelessWidget {
  final List<AppBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;

    final barBg = isDark ? AppColors.darkSurface3 : Colors.white;
    final activeBg = isDark
        ? AppColors.darkPrimaryContainer.withValues(alpha: 0.35)
        : AppColors.brandDark;
    final activeIconColor = isDark ? AppColors.darkPrimary : cs.onPrimary;
    final inactiveColor =
        isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;
    final logoutColor = isDark
        ? AppColors.darkError.withValues(alpha: 0.85)
        : AppColors.error.withValues(alpha: 0.8);
    final borderColor = isDark
        ? AppColors.darkOutlineVariant.withValues(alpha: 0.55)
        : AppColors.outlineVariant.withValues(alpha: 0.45);

    return SafeArea(
      child: Container(
        // Kotak penuh, tidak ada margin samping, tidak ada border radius
        width: double.infinity,
        decoration: BoxDecoration(
          color: barBg,
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : AppColors.brandDark.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isActive = item.onTap == null && selectedIndex == i;
            final isLogout = item.isDestructive;

            final iconColor = isLogout
                ? logoutColor
                : (isActive ? activeIconColor : inactiveColor);
            final labelColor = isLogout
                ? logoutColor
                : (isActive ? activeIconColor : inactiveColor);

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (item.onTap != null) {
                    item.onTap!();
                  } else {
                    onTap(i);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  // Background flat di seluruh lebar tab — tidak ada radius
                  color: isActive && !isLogout ? activeBg : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive && !isLogout ? item.iconFill : item.icon,
                        color: iconColor,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive && !isLogout
                              ? FontWeight.w700
                              : FontWeight.w500,
                          letterSpacing: 0.2,
                          color: labelColor,
                          height: 1.0,
                        ),
                        child: Text(
                          item.label,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}