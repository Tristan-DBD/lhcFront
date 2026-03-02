import '../api/http_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final httpClient = HttpClient();
    return httpClient.postUnauthenticated(
      '/auth/login',
      body: {'username': username, 'password': password},
    );
  }
}
