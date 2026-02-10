import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ProgramService {
  final String apiUrl = dotenv.env['API_URL']!;

  // Headers communs pour les requêtes
  Map<String, String> headers({String? token, bool isMultipart = false}) {
    final headers = {'Accept': 'application/json'};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Upload un fichier Excel pour un programme utilisateur
  Future<http.Response> uploadProgram(
    int userId,
    File excelFile,
    String token,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/user/program/$userId'),
    );

    request.headers.addAll(headers(token: token, isMultipart: true));

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
    return await http.Response.fromStream(streamedResponse);
  }

  // Supprime un programme par nom de fichier
  Future<http.Response> deleteProgram(
    int userId,
    String fileName,
    String token,
  ) async {
    return await http.delete(
      Uri.parse('$apiUrl/user/program/$userId'),
      headers: headers(token: token),
      body: '{"name": "$fileName"}',
    );
  }

  // Récupère la liste des programmes d'un utilisateur
  Future<http.Response> getPrograms(int userId, String token) async {
    return await http.get(
      Uri.parse('$apiUrl/user/program/$userId'),
      headers: headers(token: token),
    );
  }

  // Met à jour la photo de profil d'un utilisateur
  Future<http.Response> updateProfileImage(
    int userId,
    File imageFile,
    String token,
  ) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$apiUrl/user/$userId/profile-image'),
    );

    request.headers.addAll(headers(token: token, isMultipart: true));

    final fileBytes = await imageFile.readAsBytes();
    final fileName = imageFile.path.split('/').last;

    // Déterminer le MIME type selon l'extension
    String contentType;
    if (fileName.toLowerCase().endsWith('.png')) {
      contentType = 'image/png';
    } else if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg')) {
      contentType = 'image/jpeg';
    } else {
      contentType = 'image/jpeg'; // défaut
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'profileImage',
      fileBytes,
      filename: fileName,
      contentType: MediaType.parse(contentType),
    );

    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
