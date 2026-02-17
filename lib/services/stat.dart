import 'http_client.dart';

class StatService {
  static Future<Map<String, dynamic>> create(statData) async {
    final httpClient = HttpClient();
    return await httpClient.post('/stats', body: statData);
  }

  static Future<Map<String, dynamic>> update(statData) async {
    final httpClient = HttpClient();
    return await httpClient.put('/stats', body: statData);
  }

  static Future<Map<String, dynamic>> getOne(int statId) async {
    final httpClient = HttpClient();
    return await httpClient.get('/stats/$statId');
  }
}