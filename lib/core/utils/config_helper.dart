import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static Future<void> load() async {
    if (!kReleaseMode) {
      // Dev : charger .env
      await dotenv.load(fileName: ".env");
    }
  }

  static String get apiUrl => kReleaseMode
      ? const String.fromEnvironment('API_URL')
      : dotenv.env['API_URL']!;
  static String get supabaseUrl => kReleaseMode
      ? const String.fromEnvironment('SUPABASE_URL')
      : dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => kReleaseMode
      ? const String.fromEnvironment('SUPABASE_ANON_KEY')
      : dotenv.env['SUPABASE_ANON_KEY']!;
  static String get supabaseBucket => kReleaseMode
      ? const String.fromEnvironment('SUPABASE_BUCKET')
      : dotenv.env['SUPABASE_BUCKET']!;
  static String get appName => kReleaseMode
      ? const String.fromEnvironment('APP_NAME')
      : dotenv.env['APP_NAME']!;
  static String get appVersion => kReleaseMode
      ? const String.fromEnvironment('APP_VERSION')
      : dotenv.env['APP_VERSION']!;
}
