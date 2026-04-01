import 'dart:convert';
import '../storage/local_storage.dart';
import '../api/http_client.dart';

class JwtService {
  static Future<bool> isTokenValid() async {
    try {
      final payloadMap = await getTokenPayload();
      if (payloadMap == null) return false;

      // Vérifier l'expiration (exp)
      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (now >= exp) {
          // Token expiré, tentative de rafraîchissement
          final refreshed = await HttpClient().refreshToken();
          if (refreshed) {
            return true; // Le refresh a fonctionné, l'utilisateur est toujours connecté
          }
          return false; // Le token est expiré et le refresh a échoué
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getTokenPayload() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return null;

      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];

      // Conversion base64url en base64 standard
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');

      // Ajouter le padding si nécessaire pour le base64
      switch (payload.length % 4) {
        case 0:
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        default:
          return null;
      }

      final decodedPayload = utf8.decode(base64.decode(payload));
      return json.decode(decodedPayload) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<int?> getUserId() async {
    final payload = await getTokenPayload();
    return payload?['id'];
  }

  static Future<String?> getUserRole() async {
    final payload = await getTokenPayload();
    return payload?['role']?.toString();
  }
}
