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
    primary: Color(0xFF101828),
    secondary: Color(0xFF3538CD),
    background: Color(0xFFF9FAFB),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF2F4F7),
    textPrimary: Color(0xFF101828),
    textSecondary: Color(0xFF475467),
    error: Color(0xFFD92D20),
    success: Color(0xFF079455),
    warning: Color(0xFFDC6803),
    info: Color(0xFF1570EF),
    border: Color(0xFFD0D5DD),
    inputBorder: Color(0xFFD0D5DD),
    inputBackground: Color(0xFFFFFFFF),
    inputFocused: Color(0xFF3538CD),
    shadow: Color(0x0D101828),
    divider: Color(0xFFEAECF0),
    white: Color(0xFFFFFFFF),
    grey: Color(0xFF667085),
    blue: Color(0xFF1570EF),
    orange: Color(0xFFF79009),
    transparent: Color(0x00000000),
    coach: Color(0xFF079455),
    admin: Color(0xFF7F56D9),
    athleteFull: Color(0xFFD92D20),
    athleteProg: Color(0xFF1570EF),
    athleteCo: Color(0xFF3538CD),
  );

  static AppColorsData get dark => const AppColorsData(
    primary: Color(0xFFF9FAFB),
    secondary: Color(0xFF6172F3),
    background: Color(0xFF0C111D),
    surface: Color(0xFF1D2939),
    surfaceVariant: Color(0xFF344054),
    textPrimary: Color(0xFFF9FAFB),
    textSecondary: Color(0xFF98A2B3),
    error: Color(0xFFF04438),
    success: Color(0xFF12B76A),
    warning: Color(0xFFF79009),
    info: Color(0xFF2E90FA),
    border: Color(0xFF344054),
    inputBorder: Color(0xFF344054),
    inputBackground: Color(0xFF1D2939),
    inputFocused: Color(0xFF6172F3),
    shadow: Color(0x33000000),
    divider: Color(0xFF344054),
    white: Color(0xFFFFFFFF),
    grey: Color(0xFF98A2B3),
    blue: Color(0xFF528BFF),
    orange: Color(0xFFFEC84B),
    transparent: Color(0x00000000),
    coach: Color(0xFF12B76A),
    admin: Color(0xFF9E77ED),
    athleteFull: Color(0xFFF04438),
    athleteProg: Color(0xFF2E90FA),
    athleteCo: Color(0xFF6172F3),
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

  // Métriques utilitaires pour les dégradés
  Gradient getPrimaryGradient({double opacity1 = 0.1, double opacity2 = 0.3}) {
    return LinearGradient(
      colors: [primary.withOpacity(opacity1), primary.withOpacity(opacity2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Gradient getCustomGradient(Color color, {double opacity1 = 0.1, double opacity2 = 0.3}) {
    return LinearGradient(
      colors: [color.withOpacity(opacity1), color.withOpacity(opacity2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

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
