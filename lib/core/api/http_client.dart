import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../storage/local_storage.dart';

/// HTTP client centralisé pour gérer toutes les requêtes API
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  final ApiService _apiService = ApiService();

  /// Effectue une requête GET
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Effectue une requête POST
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Effectue une requête POST sans authentification
  Future<Map<String, dynamic>> postUnauthenticated(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Effectue une requête PUT
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Effectue une requête DELETE
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Effectue une requête DELETE avec corps
  Future<Map<String, dynamic>> deleteWithBody(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Gère la réponse HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final responseBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        // Pour les réponses d'erreur valides (400, 422, etc.)
        // on retourne le corps de la réponse pour que le client puisse gérer les erreurs métier
        if (responseBody is Map<String, dynamic> &&
            responseBody.containsKey('success') &&
            responseBody.containsKey('data')) {
          return responseBody;
        }
        // Pour les autres erreurs, on lance une exception
        throw HttpException(
          responseBody['data']?['message'] ??
              responseBody['message'] ??
              'Erreur serveur',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException(
        'Erreur de parsing de la réponse: $e',
        response.statusCode,
      );
    }
  }

  /// Gère les erreurs
  Exception _handleError(dynamic error) {
    if (error is HttpException) {
      return error;
    } else if (error is http.ClientException) {
      return NetworkException('Erreur de connexion: ${error.message}');
    } else {
      return ApiException('Erreur inattendue: $error');
    }
  }
}

/// Exceptions personnalisées
class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
