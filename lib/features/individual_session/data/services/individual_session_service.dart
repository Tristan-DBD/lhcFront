import 'package:lhc_front/core/api/api_response.dart';
import '../models/individual_session.dart';
import '../../../../core/api/http_client.dart';

class IndividualSessionService {
  static Future<ApiResponse<IndividualSession>> create(
    Map<String, dynamic> sessionData,
  ) async {
    try {
      final httpClient = HttpClient();
      final response =
          await httpClient.post('/individual-session', body: sessionData);

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final sessionMap = data['message'] ?? data;
        return ApiResponse.success(IndividualSession.fromJson(sessionMap));
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            response['message'] ??
            'Erreur lors de la création de la séance',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<List<IndividualSession>>> getAll({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final httpClient = HttpClient();
      String queryParams = '';

      if (startDate != null && endDate != null) {
        queryParams =
            '?startDate=${startDate.toUtc().toIso8601String()}&endDate=${endDate.toUtc().toIso8601String()}';
      }

      final response = await httpClient.get('/individual-session$queryParams');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList;

        if (response.containsKey('pagination')) {
          dataList = response['data'] as List<dynamic>;
        } else {
          if ((response['data'] as List).isEmpty) {
            dataList = [];
          } else {
            final firstItem = response['data'][0];
            final message = firstItem['message'];
            if (message is List) {
              dataList = message;
            } else if (message is Map && message['data'] is List) {
              dataList = message['data'];
            } else {
              dataList = [firstItem];
            }
          }
        }

        final sessions =
            dataList.map((json) => IndividualSession.fromJson(json)).toList();
        return ApiResponse.success(sessions);
      }
      return ApiResponse.error(response['message'] ?? 'Erreur inconnue');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<List<dynamic>>> getNbrRegistration(
    String sessionId,
  ) async {
    try {
      final httpClient = HttpClient();
      final response =
          await httpClient.get('/individual-session/registrations/$sessionId');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        return ApiResponse.success(dataList);
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            response['message'] ??
            'Erreur lors de la récupération des inscriptions',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<bool>> delete(String sessionId) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.delete('/individual-session/$sessionId');
      return ApiResponse.success(response['success'] == true);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<bool>> unregisterFromSession(
    String sessionId,
    String userId,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post(
        '/individual-session/unregister',
        body: {'courseId': sessionId, 'userId': userId},
      );
      return ApiResponse.success(response['success'] == true);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<IndividualSession>> getById(
    String sessionId,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/individual-session/$sessionId');

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final sessionMap = data['message'] ?? data;
        return ApiResponse.success(IndividualSession.fromJson(sessionMap));
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ?? response['message'] ?? 'Séance non trouvée',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<IndividualSession>> update(
    String sessionId,
    Map<String, dynamic> sessionData,
  ) async {
    try {
      final httpClient = HttpClient();
      final response =
          await httpClient.put('/individual-session/$sessionId', body: sessionData);

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final sessionMap = data['message'] ?? data;
        return ApiResponse.success(IndividualSession.fromJson(sessionMap));
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            response['message'] ??
            'Erreur lors de la mise à jour de la séance',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<bool>> registerToSession(
    String sessionId,
    String userId,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post(
        '/individual-session/register',
        body: {'courseId': sessionId, 'userId': userId},
      );
      return ApiResponse.success(response['success'] == true);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
