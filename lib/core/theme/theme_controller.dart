import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  bool _isDarkMode = false;
  bool _followSystem = true;

  bool get isDarkMode => _isDarkMode;
  bool get followSystem => _followSystem;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  AppColorsData get colors => _isDarkMode ? AppColors.dark : AppColors.light;

  void init() {
    _detectSystemTheme();
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
          if (_followSystem) {
            _detectSystemTheme();
            _updateColors();
            notifyListeners();
          }
        };
    _updateColors();
  }

  void _detectSystemTheme() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode = brightness == Brightness.dark;
  }

  void _updateColors() {
    AppColors.setDarkMode(_isDarkMode);
  }

  void toggle() {
    _followSystem = false;
    _isDarkMode = !_isDarkMode;
    _updateColors();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _followSystem = false;
    _isDarkMode = value;
    _updateColors();
    notifyListeners();
  }

  void setFollowSystem(bool value) {
    _followSystem = value;
    if (value) {
      _detectSystemTheme();
      _updateColors();
    }
    notifyListeners();
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    required ThemeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ThemeScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeScope>()!;
  }

  static AppColorsData colorsOf(BuildContext context) {
    return of(context).notifier!.colors;
  }

  AppColorsData get colors => notifier!.colors;
  bool get isDarkMode => notifier!.isDarkMode;
  ThemeController get controller => notifier!;
}
