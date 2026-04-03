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

  static Future<ApiResponse<User>> update(
    String userId,
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

  static Future<ApiResponse<List<User>>> getAll({List<String>? roles}) async {
    try {
      final httpClient = HttpClient();
      String url = '/user';
      if (roles != null && roles.isNotEmpty) {
        final queryParams = roles.map((r) => 'role=$r').join('&');
        url = '$url?$queryParams';
      }
      final response = await httpClient.get(url);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        if (dataList.isNotEmpty && dataList[0]['message'] is List) {
          final List<dynamic> usersData = dataList[0]['message'];
          final users = usersData.map((json) => User.fromJson(json)).toList();
          return ApiResponse.success(users);
        }
        // Fallback si la structure est directe
        final users = dataList.map((json) => User.fromJson(json)).toList();
        return ApiResponse.success(users);
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            response['message'] ??
            'Erreur lors de la récupération des utilisateurs',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<User>> getUserById(String userId) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/user/$userId');

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final userMap = data['message'] ?? data;
        return ApiResponse.success(User.fromJson(userMap));
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ?? response['message'] ?? 'Utilisateur non trouvé',
      );
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
        if (dataList.isNotEmpty && dataList[0]['message'] is List) {
          final List<dynamic> usersData = dataList[0]['message'];
          final users = usersData.map((json) => User.fromJson(json)).toList();
          return ApiResponse.success(users);
        }
        // Fallback
        final users = dataList.map((json) => User.fromJson(json)).toList();
        return ApiResponse.success(users);
      }
      String? errorMessage;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMessage = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            response['message'] ??
            'Erreur lors de la récupération des coachs',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
