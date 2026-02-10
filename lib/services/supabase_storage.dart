import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SupabaseStorageService {
  static final SupabaseStorageService _instance =
      SupabaseStorageService._internal();
  factory SupabaseStorageService() => _instance;
  SupabaseStorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = dotenv.env['SUPABASE_BUCKET']!;

  /// Récupère l'URL signée d'une image de profil
  Future<String> getProfileImageUrl(String imagePath) async {
    if (imagePath.isEmpty) {
      return '';
    }

    try {
      return await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(imagePath, 3600); // 1 heure
    } catch (e) {
      print('Erreur lors de la récupération de l\'URL de l\'image: $e');
      return '';
    }
  }

  /// Télécharge un fichier programme depuis Supabase Storage
  Future<File?> downloadProgramFile(String fileUri, String savePath) async {
    try {
      // Utiliser directement le fileUri qui contient déjà le chemin complet
      // Ex: /prog/1770733721037.xlsx
      final filePath = fileUri.startsWith('/') ? fileUri.substring(1) : fileUri;

      // Télécharger les données du fichier
      final response = await _supabase.storage
          .from(_bucketName)
          .download(filePath);

      // Créer le fichier local
      final file = File(savePath);
      await file.writeAsBytes(response);

      return file;
    } catch (e) {
      print('Erreur lors du téléchargement du fichier depuis Supabase: $e');
      return null;
    }
  }

  /// Met à jour la photo de profil via l'API
  Future<http.Response> updateProfileImage(
    int userId,
    File imageFile,
    String token,
  ) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${dotenv.env['API_URL']}/user/$userId/profile-image'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

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
