import 'http_client.dart';

class CourseService {
  static Future<Map<String, dynamic>> create(
    Map<String, dynamic> courseData,
  ) async {
    final httpClient = HttpClient();
    return await httpClient.post('/course', body: courseData);
  }

  static Future<Map<String, dynamic>> getAll() async {
    final httpClient = HttpClient();
    return await httpClient.get('/course');
  }

  static Future<Map<String, dynamic>> getNbrRegistration(courseId) async {
    final httpClient = HttpClient();
    return await httpClient.get('/course/registrations/$courseId');
  }

  static Future<Map<String, dynamic>> delete(int courseId) async {
    final httpClient = HttpClient();
    return await httpClient.delete('/course/$courseId');
  }

  static Future<Map<String, dynamic>> unregisterFromCourse(
    int courseId,
    int userId,
  ) async {
    final httpClient = HttpClient();
    return await httpClient.deleteWithBody(
      '/course/unregister',
      body: {'courseId': courseId, 'userId': userId},
    );
  }

  static Future<Map<String, dynamic>> getById(int courseId) async {
    final httpClient = HttpClient();
    return await httpClient.get('/course/$courseId');
  }

  static Future<Map<String, dynamic>> update(
    int courseId,
    Map<String, dynamic> courseData,
  ) async {
    final httpClient = HttpClient();
    return await httpClient.put('/course/$courseId', body: courseData);
  }

  static Future<Map<String, dynamic>> registerToCourse(
    int courseId,
    int userId,
  ) async {
    final httpClient = HttpClient();
    return await httpClient.post(
      '/course/register',
      body: {'courseId': courseId, 'userId': userId},
    );
  }
}
