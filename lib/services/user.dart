import 'package:lhc_front/services/http_client.dart';

class UserService {
  static Future<Map<String, dynamic>> create(userData) async {
    final httpClient = HttpClient();
    return await httpClient.post('/user', body: userData);
  }

  static Future<Map<String, dynamic>> update(int userId, userData) async {
    final httpClient = HttpClient();
    return await httpClient.put('/user/$userId', body: userData);
  }

  static Future<Map<String, dynamic>> getAll() async {
    final httpClient = HttpClient();
    return await httpClient.get('/user');
  }

  static Future<Map<String, dynamic>> getUserById(int userId) async {
    final httpClient = HttpClient();
    return await httpClient.get('/user/$userId');
  }

  static Future<Map<String, dynamic>> getAllCoach() async {
    final httpClient = HttpClient();
    return await httpClient.get('/user/get-coach');
  }
}
