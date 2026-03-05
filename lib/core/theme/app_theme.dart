import 'package:flutter/material.dart';

class AppColors {
  static AppColorsData get current => _current;
  static AppColorsData _current = light;

  static void toggle() {
    _current = _current == light ? dark : light;
  }

  static void setDarkMode(bool isDark) {
    _current = isDark ? dark : light;
  }

  static Color get primary => current.primary;
  static Color get secondary => current.secondary;
  static Color get background => current.background;
  static Color get surface => current.surface;
  static Color get surfaceVariant => current.surfaceVariant;
  static Color get textPrimary => current.textPrimary;
  static Color get textSecondary => current.textSecondary;
  static Color get error => current.error;
  static Color get success => current.success;
  static Color get warning => current.warning;
  static Color get info => current.info;
  static Color get border => current.border;
  static Color get inputBorder => current.inputBorder;
  static Color get inputBackground => current.inputBackground;
  static Color get inputFocused => current.inputFocused;
  static Color get shadow => current.shadow;
  static Color get divider => current.divider;
  static Color get white => current.white;
  static Color get grey => current.grey;
  static Color get blue => current.blue;
  static Color get orange => current.orange;
  static Color get transparent => current.transparent;
  static Color get coach => current.coach;
  static Color get admin => current.admin;
  static Color get athleteFull => current.athleteFull;
  static Color get athleteProg => current.athleteProg;
  static Color get athleteCo => current.athleteCo;

  static AppColorsData get light => const AppColorsData(
    primary: Color(0xFF1A1A1A),
    secondary: Color(0xFF4A90D9),
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F5F5),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF757575),
    error: Color(0xFFE53935),
    success: Color(0xFF43A047),
    warning: Color(0xFFFB8C00),
    info: Color(0xFF1E88E5),
    border: Color(0xFFE0E0E0),
    inputBorder: Color(0xFFE0E0E0),
    inputBackground: Color(0xFFF5F5F5),
    inputFocused: Color(0xFF1A1A1A),
    shadow: Color(0x1A000000),
    divider: Color(0xFFEEEEEE),
    white: Color(0xFFFFFFFF),
    grey: Color(0xFF9E9E9E),
    blue: Color(0xFF2196F3),
    orange: Color(0xFFFF9800),
    transparent: Color(0x00000000),
    coach: Color(0xFF43A047),
    admin: Color(0xFFFF5722),
    athleteFull: Color(0xFFE53935),
    athleteProg: Color(0xFF1E88E5),
    athleteCo: Color(0xFF3949AB),
  );

  static AppColorsData get dark => const AppColorsData(
    primary: Color(0xFFFFFFFF),
    secondary: Color(0xFF64B5F6),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF2A2A2A),
    textPrimary: Color(0xFFFAFAFA),
    textSecondary: Color(0xFFB0B0B0),
    error: Color(0xFFEF5350),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFA726),
    info: Color(0xFF42A5F5),
    border: Color(0xFF424242),
    inputBorder: Color(0xFF424242),
    inputBackground: Color(0xFF2A2A2A),
    inputFocused: Color(0xFFFFFFFF),
    shadow: Color(0x33000000),
    divider: Color(0xFF333333),
    white: Color(0xFFFFFFFF),
    grey: Color(0xFF757575),
    blue: Color(0xFF64B5F6),
    orange: Color(0xFFFFA726),
    transparent: Color(0x00000000),
    coach: Color(0xFF66BB6A),
    admin: Color(0xFFFF7043),
    athleteFull: Color(0xFFEF5350),
    athleteProg: Color(0xFF42A5F5),
    athleteCo: Color(0xFF5C6BC0),
  );
}

class AppColorsData {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color border;
  final Color inputBorder;
  final Color inputBackground;
  final Color inputFocused;
  final Color shadow;
  final Color divider;
  final Color white;
  final Color grey;
  final Color blue;
  final Color orange;
  final Color transparent;
  final Color coach;
  final Color admin;
  final Color athleteFull;
  final Color athleteProg;
  final Color athleteCo;

  const AppColorsData({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.border,
    required this.inputBorder,
    required this.inputBackground,
    required this.inputFocused,
    required this.shadow,
    required this.divider,
    required this.white,
    required this.grey,
    required this.blue,
    required this.orange,
    required this.transparent,
    required this.coach,
    required this.admin,
    required this.athleteFull,
    required this.athleteProg,
    required this.athleteCo,
  });

  ThemeData toThemeData(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: brightness == Brightness.light
            ? white
            : const Color(0xFF1A1A1A),
        secondary: secondary,
        onSecondary: white,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: white,
      ),
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      dividerTheme: DividerThemeData(color: divider),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error),
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: brightness == Brightness.light
              ? white
              : const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
