import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lhc_front/core/utils/config_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/theme_controller.dart';
import 'core/utils/navigation_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Config.load();

    final supabaseUrl = Config.supabaseUrl;
    final supabaseAnonKey = Config.supabaseAnonKey;

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } catch (e) {
    debugPrint("Erreur d'initialisation : $e");
    // L'application continuera mais les fonctionnalités liées à Supabase échoueront proprement
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
final themeController = ThemeController();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeController.init();
  }

  Key _appKey = UniqueKey();
  bool _lastIsDark = false;

  @override
  Widget build(BuildContext context) {
    final isDark = themeController.isDarkMode;
    if (isDark != _lastIsDark) {
      _lastIsDark = isDark;
      _appKey = UniqueKey();
    }

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        final colors = themeController.colors;
        return ThemeScope(
          controller: themeController,
          child: MaterialApp(
            key: _appKey,
            title: 'LHC Coaching',
            theme: colors.toThemeData(Brightness.light),
            darkTheme: colors.toThemeData(Brightness.dark),
            themeMode: themeController.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
            locale: const Locale('fr', 'FR'),
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeAuth(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Future<void> _initializeAuth(BuildContext context) async {
    await NavigationHelper.initNavigation(context);
  }
}
