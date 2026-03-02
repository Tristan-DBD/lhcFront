import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';
import '../theme/app_theme.dart';

class ThemeToggle extends StatelessWidget {
  final bool showLabel;
  const ThemeToggle({super.key, this.showLabel = false});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController();
    final colors = AppColors.current;

    return IconButton(
      onPressed: controller.toggle,
      icon: Icon(
        controller.isDarkMode
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
        color: colors.textPrimary,
      ),
      tooltip: controller.isDarkMode
          ? 'Passer au thème clair'
          : 'Passer au thème sombre',
    );
  }
}

class ThemeToggleWithLabel extends StatelessWidget {
  const ThemeToggleWithLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController();
    final colors = AppColors.current;

    return InkWell(
      onTap: controller.toggle,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              controller.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: colors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              controller.isDarkMode ? 'Thème clair' : 'Thème sombre',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
