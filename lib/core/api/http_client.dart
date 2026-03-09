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
      return _handleResponse(response, retry: () async => http.get(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
      ));
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
      return _handleResponse(response, retry: () async => http.post(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
        body: body != null ? jsonEncode(body) : null,
      ));
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
      return _handleResponse(response, retry: () async => http.put(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
        body: body != null ? jsonEncode(body) : null,
      ));
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
      return _handleResponse(response, retry: () async => http.delete(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
      ));
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
      return _handleResponse(response, retry: () async => http.delete(
        Uri.parse('${_apiService.apiUrl}$endpoint'),
        headers: _apiService.headers(token: await StorageService.getToken()),
        body: body != null ? jsonEncode(body) : null,
      ));
    } catch (e) {
      throw _handleError(e);
    }
  }

  bool _isRefreshing = false;

  /// Gère la réponse HTTP
  Future<Map<String, dynamic>> _handleResponse(http.Response response, {Future<http.Response> Function()? retry}) async {
    try {
      final responseBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else if (response.statusCode == 401 && retry != null) {
        // Tentative de refresh token
        if (!_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshed = await refreshToken();
            _isRefreshing = false;
            if (refreshed) {
              final newResponse = await retry();
              return _handleResponse(newResponse);
            }
          } catch (e) {
            _isRefreshing = false;
          }
        } else {
          // Attendre que le refresh en cours se termine
          await Future.delayed(const Duration(milliseconds: 500));
          final newResponse = await retry();
          return _handleResponse(newResponse);
        }
        
        // Si on arrive ici, le refresh a échoué
        throw HttpException('Session expirée', 401);
      } else {
        // Pour les réponses d'erreur valides (400, 422, etc.)
        if (responseBody is Map<String, dynamic> &&
            responseBody.containsKey('success') &&
            responseBody.containsKey('data')) {
          return responseBody;
        }
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

  /// Rafraîchit les tokens
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${_apiService.apiUrl}/auth/refresh'),
        headers: _apiService.headers(),
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokens = data['data'][0]['message'];
        await StorageService.saveToken(tokens['accessToken']);
        await StorageService.saveRefreshToken(tokens['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
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
