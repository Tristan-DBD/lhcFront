import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';
import 'http_client.dart';
import 'storage.dart';

class ProgramService {
  static final ProgramService _instance = ProgramService._internal();
  factory ProgramService() => _instance;
  ProgramService._internal();

  final HttpClient _httpClient = HttpClient();
  final ApiService _apiService = ApiService();

  /// Upload un fichier Excel pour un programme utilisateur
  Future<Map<String, dynamic>> uploadProgram(int userId, File excelFile) async {
    final token = await StorageService.getToken();
    if (token == null) throw Exception('Token non trouvé');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${_apiService.apiUrl}/user/program/$userId'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    final fileBytes = await excelFile.readAsBytes();
    final fileName = excelFile.path.split('/').last;

    // Déterminer le MIME type selon l'extension
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

    // Parser la réponse JSON pour la retourner comme Map
    final responseData = jsonDecode(response.body);
    return responseData;
  }

  /// Supprime un programme par nom de fichier
  Future<Map<String, dynamic>> deleteProgram(
    int userId,
    String fileName,
  ) async {
    final token = await StorageService.getToken();
    if (token == null) throw Exception('Token non trouvé');

    final response = await http.delete(
      Uri.parse('${_apiService.apiUrl}/user/program/$userId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{"name": "$fileName"}',
    );

    // Parser la réponse JSON pour la retourner comme Map
    final responseData = jsonDecode(response.body);
    return responseData;
  }

  /// Récupère la liste des programmes d'un utilisateur
  Future<Map<String, dynamic>> getPrograms(int userId) async {
    return await _httpClient.get('/user/program/$userId');
  }
}
