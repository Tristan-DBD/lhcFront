import '../models/course.dart';
import '../../../../core/api/api_response.dart';
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
      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la création du cours',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<List<Course>>> getAll() async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/course');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        final courses = dataList.map((json) => Course.fromJson(json)).toList();
        return ApiResponse.success(courses);
      }
      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la récupération des cours',
      );
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
      return ApiResponse.error(
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

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final courseMap = (data is List && data.isNotEmpty) ? data[0] : data;
        return ApiResponse.success(Course.fromJson(courseMap));
      }
      return ApiResponse.error(response['message'] ?? 'Cours non trouvé');
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
      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la mise à jour du cours',
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
