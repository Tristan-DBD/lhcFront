import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static Future<void> load() async {
    // Tente de charger le fichier .env en fallback pour les builds locaux
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Ignorer si le fichier n'est pas présent (ex: en prod Railway via Docker)
    }
  }

  static String get apiUrl {
    const defaultVal = String.fromEnvironment('API_URL');
    return defaultVal.isNotEmpty ? defaultVal : (dotenv.env['API_URL'] ?? '');
  }

  static String get supabaseUrl {
    const defaultVal = String.fromEnvironment('SUPABASE_URL');
    return defaultVal.isNotEmpty
        ? defaultVal
        : (dotenv.env['SUPABASE_URL'] ?? '');
  }

  static String get supabaseAnonKey {
    const defaultVal = String.fromEnvironment('SUPABASE_ANON_KEY');
    return defaultVal.isNotEmpty
        ? defaultVal
        : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');
  }

  static String get supabaseBucket {
    const defaultVal = String.fromEnvironment('SUPABASE_BUCKET');
    return defaultVal.isNotEmpty
        ? defaultVal
        : (dotenv.env['SUPABASE_BUCKET'] ?? '');
  }

  static String get appName {
    const defaultVal = String.fromEnvironment('APP_NAME');
    return defaultVal.isNotEmpty ? defaultVal : (dotenv.env['APP_NAME'] ?? '');
  }

  static String get appVersion {
    const defaultVal = String.fromEnvironment('APP_VERSION');
    return defaultVal.isNotEmpty
        ? defaultVal
        : (dotenv.env['APP_VERSION'] ?? '');
  }
}
