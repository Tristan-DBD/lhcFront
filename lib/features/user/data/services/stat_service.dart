import '../../../../core/api/api_response.dart';
import '../../../../core/api/http_client.dart';

class StatService {
  static Future<ApiResponse<Map<String, dynamic>>> create(
    Map<String, dynamic> statData,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post('/stats', body: statData);

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final statMap = data['message'] ?? data;
        return ApiResponse.success(statMap as Map<String, dynamic>);
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ?? response['message'] ?? 'Erreur lors de la création',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> update(
    Map<String, dynamic> statData,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.put('/stats', body: statData);

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final statMap = data['message'] ?? data;
        return ApiResponse.success(statMap as Map<String, dynamic>);
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ?? response['message'] ?? 'Erreur lors de la mise à jour',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getOne(int statId) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/stats/$statId');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final statMap = (data is List && data.isNotEmpty) ? data[0] : data;
        return ApiResponse.success(statMap as Map<String, dynamic>);
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ?? response['message'] ?? 'Stats introuvables',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
