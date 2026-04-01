import 'package:lhc_front/core/api/api_response.dart';
import '../models/course.dart';
import '../../../../core/api/http_client.dart';

class CourseService {
  static Future<ApiResponse<Course>> create(
    Map<String, dynamic> courseData,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post('/course', body: courseData);

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        // L'API semble parfois renvoyer une Map avec un champ 'message' qui contient l'objet
        final courseMap = data['message'] ?? data;
        return ApiResponse.success(Course.fromJson(courseMap));
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            response['message'] ??
            'Erreur lors de la création du cours',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<List<Course>>> getAll({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final httpClient = HttpClient();
      String queryParams = '';

      if (startDate != null && endDate != null) {
        // Envoi en UTC avec 'Z' pour la compatibilité backend (Zod)
        queryParams =
            '?startDate=${startDate.toUtc().toIso8601String()}&endDate=${endDate.toUtc().toIso8601String()}';
      }

      final response = await httpClient.get('/course$queryParams');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList;

        if (response.containsKey('pagination')) {
          // Format paginé : la liste est directement dans 'data'
          dataList = response['data'] as List<dynamic>;
        } else {
          // Format standard avec enveloppe 'message'
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

        final courses = dataList.map((json) => Course.fromJson(json)).toList();
        return ApiResponse.success(courses);
      }
      return ApiResponse.error(response['message'] ?? 'Erreur inconnue');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<List<dynamic>>> getNbrRegistration(
    int courseId,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/course/registrations/$courseId');

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

  static Future<ApiResponse<bool>> delete(int courseId) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.delete('/course/$courseId');
      return ApiResponse.success(response['success'] == true);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<bool>> unregisterFromCourse(
    int courseId,
    int userId,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post(
        '/course/unregister',
        body: {'courseId': courseId, 'userId': userId},
      );
      return ApiResponse.success(response['success'] == true);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<Course>> getById(int courseId) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/course/$courseId');

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final courseMap = data['message'] ?? data;
        return ApiResponse.success(Course.fromJson(courseMap));
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ?? response['message'] ?? 'Cours non trouvé',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<Course>> update(
    int courseId,
    Map<String, dynamic> courseData,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.put(
        '/course/$courseId',
        body: courseData,
      );

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final courseMap = data['message'] ?? data;
        return ApiResponse.success(Course.fromJson(courseMap));
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            response['message'] ??
            'Erreur lors de la mise à jour du cours',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<bool>> registerToCourse(
    int courseId,
    int userId,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post(
        '/course/register',
        body: {'courseId': courseId, 'userId': userId},
      );
      return ApiResponse.success(response['success'] == true);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
