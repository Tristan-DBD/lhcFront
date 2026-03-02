import '../models/user.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/http_client.dart';

class UserService {
  static Future<ApiResponse<User>> create(Map<String, dynamic> userData) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post('/user', body: userData);

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        // L'API semble parfois renvoyer une Map avec un champ 'message' qui contient l'User
        final userMap = data['message'] ?? data;
        return ApiResponse.success(User.fromJson(userMap));
      }
      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la création',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<User>> update(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.put('/user/$userId', body: userData);

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final userMap = data['message'] ?? data;
        return ApiResponse.success(User.fromJson(userMap));
      }
      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la mise à jour',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<List<User>>> getAll() async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/user');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        final users = dataList.map((json) => User.fromJson(json)).toList();
        return ApiResponse.success(users);
      }
      return ApiResponse.error(
        response['message'] ??
            'Erreur lors de la récupération des utilisateurs',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<User>> getUserById(int userId) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/user/$userId');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        // Si c'est une liste, on prend le premier élément
        final userMap = (data is List && data.isNotEmpty) ? data[0] : data;
        return ApiResponse.success(User.fromJson(userMap));
      }
      return ApiResponse.error(response['message'] ?? 'Utilisateur non trouvé');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<List<User>>> getAllCoach() async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/user/get-coach');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        final users = dataList.map((json) => User.fromJson(json)).toList();
        return ApiResponse.success(users);
      }
      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la récupération des coachs',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
