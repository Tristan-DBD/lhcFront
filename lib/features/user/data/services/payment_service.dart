import '../../../../core/api/api_response.dart';
import '../../../../core/api/http_client.dart';

class PaymentService {
  static Future<ApiResponse<Map<String, dynamic>>> toggleMonth({
    required String userId,
    required int year,
    required String month,
  }) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post(
        '/payment/toggle',
        body: {'userId': userId, 'year': year, 'month': month},
      );

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final paymentMap = data['message'] ?? data;
        return ApiResponse.success(paymentMap as Map<String, dynamic>);
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            response['message'] ??
            'Erreur lors de la mise à jour du paiement',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getPayments(
    String userId,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/payment/$userId');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        final firstItem = dataList.isNotEmpty ? dataList[0] : null;
        if (firstItem != null && firstItem['message'] is List) {
          final List<dynamic> payments = firstItem['message'];
          return ApiResponse.success(
            payments.map((e) => e as Map<String, dynamic>).toList(),
          );
        }
        // Fallback si pas de structure message
        return ApiResponse.success(
          dataList.map((e) => e as Map<String, dynamic>).toList(),
        );
      }
      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la récupération des paiements',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
