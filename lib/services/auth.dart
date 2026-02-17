import 'package:lhc_front/services/http_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final httpClient = HttpClient();
    return await httpClient.postUnauthenticated(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
  }
}
