import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static Future<void> load() async {
    // En dev local, charger le .env depuis les assets
    // En prod, les variables viennent des --dart-define via String.fromEnvironment
    try {
      await dotenv.load();
    } catch (e) {
      // Ignorer si le fichier n'est pas présent (ex: en prod Railway via Docker)
    }
  }

  static String _sanitize(String value) {
    return value.replaceAll('"', '').replaceAll("'", '').trim();
  }

  static String get apiUrl {
    const defaultVal = String.fromEnvironment('API_URL');
    final val = defaultVal.isNotEmpty ? defaultVal : (dotenv.env['API_URL'] ?? '');
    return _sanitize(val);
  }

  static String get supabaseUrl {
    const defaultVal = String.fromEnvironment('SUPABASE_URL');
    final val = defaultVal.isNotEmpty
        ? defaultVal
        : (dotenv.env['SUPABASE_URL'] ?? '');
    return _sanitize(val);
  }

  static String get supabaseAnonKey {
    const defaultVal = String.fromEnvironment('SUPABASE_ANON_KEY');
    final val = defaultVal.isNotEmpty
        ? defaultVal
        : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');
    return _sanitize(val);
  }

  static String get supabaseBucket {
    const defaultVal = String.fromEnvironment('SUPABASE_BUCKET');
    final val = defaultVal.isNotEmpty
        ? defaultVal
        : (dotenv.env['SUPABASE_BUCKET'] ?? '');
    return _sanitize(val);
  }

  static String get appName {
    const defaultVal = String.fromEnvironment('APP_NAME');
    final val = defaultVal.isNotEmpty ? defaultVal : (dotenv.env['APP_NAME'] ?? '');
    return _sanitize(val);
  }

  static String get appVersion {
    const defaultVal = String.fromEnvironment('APP_VERSION');
    final val = defaultVal.isNotEmpty
        ? defaultVal
        : (dotenv.env['APP_VERSION'] ?? '');
    return _sanitize(val);
  }
}
