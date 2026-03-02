import '../../../../core/api/http_client.dart';

class StatService {
  static Future<Map<String, dynamic>> create(statData) async {
    final httpClient = HttpClient();
    return httpClient.post('/stats', body: statData);
  }

  static Future<Map<String, dynamic>> update(statData) async {
    final httpClient = HttpClient();
    return httpClient.put('/stats', body: statData);
  }

  static Future<Map<String, dynamic>> getOne(int statId) async {
    final httpClient = HttpClient();
    return httpClient.get('/stats/$statId');
  }
}
