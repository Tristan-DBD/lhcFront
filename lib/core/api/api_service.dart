import '../utils/config_helper.dart';

class ApiService {
  final String apiUrl = Config.apiUrl;

  ApiService() {}

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
