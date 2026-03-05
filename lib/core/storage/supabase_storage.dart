import 'package:flutter/foundation.dart';
import 'package:lhc_front/core/utils/config_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SupabaseStorageService {
  static final SupabaseStorageService _instance =
      SupabaseStorageService._internal();
  factory SupabaseStorageService() => _instance;
  SupabaseStorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = Config.supabaseBucket;

  /// Récupère l'URL signée d'une image de profil
  Future<String> getProfileImageUrl(String imagePath) async {
    if (imagePath.isEmpty) {
      return '';
    }

    // Normaliser le chemin (enlever le slash initial si présent)
    final normalizedPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    try {
      // Tenter d'abord l'URL signée (si le bucket est privé)
      final url = await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(normalizedPath, 3600);
      // Success log removed
      return url;
    } catch (e) {
      // Error log removed
      try {
        // Fallback sur l'URL publique (si le bucket est public)
        final publicUrl = _supabase.storage
            .from(_bucketName)
            .getPublicUrl(normalizedPath);
        debugPrint(
          'Supabase Fallback: Public URL generated for $normalizedPath',
        );
        return publicUrl;
      } catch (e2) {
        // Error log removed
        return '';
      }
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
      return null;
    }
  }

  /// Met à jour la photo de profil via l'API
  Future<http.Response> updateProfileImage(
    int userId,
    Uint8List fileBytes,
    String fileName,
    String token,
  ) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${Config.apiUrl}/user/$userId/profile-image'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // Plus besoin de lire les bytes du fichier, ils sont passés en paramètre

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
    return http.Response.fromStream(streamedResponse);
  }
}
