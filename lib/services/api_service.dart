import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String apiUrl = dotenv.env['API_URL']!;

  // Headers communs pour les requêtes
  Map<String, String> headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
