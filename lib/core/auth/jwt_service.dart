import 'dart:convert';
import '../storage/local_storage.dart';

class JwtService {
  static Future<bool> isTokenValid() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return false;

      // Validation JWT locale
      final parts = token.split('.');
      if (parts.length != 3) return false; // JWT doit avoir 3 parties

      // Décoder le payload (partie 2)
      String payload = parts[1];

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
          return false;
      }

      final decodedPayload = utf8.decode(base64.decode(payload));
      final payloadMap = json.decode(decodedPayload) as Map<String, dynamic>;

      // Vérifier l'expiration (exp)
      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (now >= exp) {
          return false; // Token expiré
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
