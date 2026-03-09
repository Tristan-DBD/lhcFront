import 'package:flutter/material.dart';
import '../api/http_client.dart';
import '../storage/local_storage.dart';
import '../../features/user/presentation/screens/login_page.dart';

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

  static Future<Map<String, dynamic>> changePassword(String newPassword) async {
    final httpClient = HttpClient();
    return httpClient.post(
      '/auth/change-password',
      body: {'newPassword': newPassword},
    );
  }

  static Future<void> logout(BuildContext context) async {
    final refreshToken = await StorageService.getRefreshToken();
    if (refreshToken != null) {
      try {
        await HttpClient().post('/auth/logout', body: {'refreshToken': refreshToken});
      } catch (e) {
        // Ignorer l'erreur si le serveur est injoignable
      }
    }
    await StorageService.clearTokens();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }
}
