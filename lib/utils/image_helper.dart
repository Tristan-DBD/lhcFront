import 'package:flutter/material.dart';
import 'package:lhc_front/services/supabase_storage.dart';
import '../constant/app_colors.dart';

class ImageHelper {
  static final SupabaseStorageService _storage = SupabaseStorageService();

  /// Widget simplifié pour afficher une image de profil
  static Widget profileImage(String? imagePath, {double size = 40}) {
    return FutureBuilder<String>(
      future: _storage.getProfileImageUrl(imagePath ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _placeholder(size);
        }

        final imageUrl = snapshot.data;
        if (imageUrl == null || imageUrl.isEmpty) {
          return _placeholder(size);
        }

        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(size),
        );
      },
    );
  }

  static Widget _placeholder(double size) {
    return Container(
      color: AppColors.background,
      child: Icon(Icons.person, size: size, color: AppColors.textSecondary),
    );
  }
}
