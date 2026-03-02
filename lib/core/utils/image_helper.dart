import 'package:flutter/material.dart';
import '../storage/supabase_storage.dart';

class ImageHelper {
  static final SupabaseStorageService _storage = SupabaseStorageService();

  /// Widget simplifié pour afficher une image de profil
  static Widget profileImage(String? imagePath, {double size = 40}) {
    return FutureBuilder<String>(
      future: _storage.getProfileImageUrl(imagePath ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _placeholder(context, size);
        }

        final imageUrl = snapshot.data;
        if (imageUrl == null || imageUrl.isEmpty) {
          return _placeholder(context, size);
        }

        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(context, size),
        );
      },
    );
  }

  static Widget _placeholder(BuildContext context, double size) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Icon(
        Icons.person,
        size: size,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
