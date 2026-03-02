import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeAwareBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    AppColorsData colors,
    bool isDarkMode,
  )
  builder;

  const ThemeAwareBuilder({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return builder(context, colors, isDarkMode);
  }
}
