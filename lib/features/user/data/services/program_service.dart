import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/http_client.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/local_storage.dart';

class ProgramService {
  final HttpClient _httpClient = HttpClient();
  final ApiService _apiService = ApiService();

  /// Upload un fichier Excel pour un programme utilisateur
  Future<ApiResponse<Map<String, dynamic>>> uploadProgram(
    int userId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return ApiResponse.error('Token non trouvé');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiService.apiUrl}/user/program/$userId'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      String contentType;
      if (fileName.toLowerCase().endsWith('.xlsx')) {
        contentType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else if (fileName.toLowerCase().endsWith('.xls')) {
        contentType = 'application/vnd.ms-excel';
      } else {
        contentType = 'application/octet-stream';
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'programFile',
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          {},
        ); // Succès sans données spécifiques à retourner
      } else {
        return ApiResponse.error('Échec de l\'upload: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Supprime un programme par nom de fichier
  Future<ApiResponse<void>> deleteProgram(int userId, String fileName) async {
    try {
      final responseBody = await _httpClient.deleteWithBody(
        '/user/program/$userId',
        body: {'name': fileName},
      );

      if (responseBody['success'] == true) {
        return ApiResponse.success(null);
      }
      String? errorMessage;
      if (responseBody['data'] != null &&
          (responseBody['data'] as List).isNotEmpty) {
        errorMessage = responseBody['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            responseBody['message'] ??
            'Erreur lors de la suppression',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Récupère la liste des programmes d'un utilisateur
  Future<ApiResponse<List<dynamic>>> getPrograms(int userId) async {
    try {
      final responseBody = await _httpClient.get('/user/program/$userId');

      if (responseBody['success'] == true && responseBody['data'] != null) {
        return ApiResponse.success(responseBody['data'] as List<dynamic>);
      }
      String? errorMessage;
      if (responseBody['data'] != null &&
          (responseBody['data'] as List).isNotEmpty) {
        errorMessage = responseBody['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMessage ??
            responseBody['message'] ??
            'Erreur lors de la récupération',
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Met à jour la photo de profil via l'API (Inclus ici car présent dans l'ancien service)
  Future<ApiResponse<void>> updateProfileImage(
    int userId,
    File imageFile,
  ) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return ApiResponse.error('Token non trouvé');

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${_apiService.apiUrl}/user/$userId/profile-image'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      final fileBytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;

      String contentType = 'image/jpeg';
      if (fileName.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'profileImage',
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null);
      }
      return ApiResponse.error('Échec de la mise à jour de l\'image');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
