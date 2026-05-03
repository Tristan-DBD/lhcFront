import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageCompressor {
  /// Internal class for passing data to the isolate
  static _CompressionParams? _params;

  static Future<Uint8List?> compressImage(
    Uint8List imageBytes, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 75,
    bool maintainAspectRatio = true,
    bool forceJpg = true,
  }) async {
    try {
      // Use compute to run the heavy work in a separate isolate
      return await compute(
        _compressInIsolate,
        _CompressionParams(
          imageBytes: imageBytes,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
          maintainAspectRatio: maintainAspectRatio,
          forceJpg: forceJpg,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      return null;
    }
  }

  /// The actual compression logic running in an isolate
  static Uint8List? _compressInIsolate(_CompressionParams params) {
    try {
      // Decode the image
      img.Image? originalImage = img.decodeImage(params.imageBytes);
      
      if (originalImage == null) {
        return null;
      }

      // Calculate new dimensions
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      bool needsResize = false;
      if (params.maintainAspectRatio) {
        double aspectRatio = originalImage.width / originalImage.height;
        
        if (originalImage.width > params.maxWidth) {
          newWidth = params.maxWidth;
          newHeight = (params.maxWidth / aspectRatio).round();
          needsResize = true;
        }
        
        if (newHeight > params.maxHeight) {
          newHeight = params.maxHeight;
          newWidth = (params.maxHeight * aspectRatio).round();
          needsResize = true;
        }
      } else {
        if (originalImage.width > params.maxWidth) {
          newWidth = params.maxWidth;
          needsResize = true;
        }
        if (originalImage.height > params.maxHeight) {
          newHeight = params.maxHeight;
          needsResize = true;
        }
      }

      img.Image processedImage = originalImage;
      if (needsResize) {
        processedImage = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear, // Faster than average, good enough for downscaling
        );
      }

      // Encode the image
      // For better compression, we default to JPEG unless it's a PNG we want to keep as PNG
      // But for this app (profile/products), JPEG is almost always better.
      
      Uint8List compressed;
      if (params.forceJpg) {
        compressed = Uint8List.fromList(img.encodeJpg(processedImage, quality: params.quality));
      } else {
        // Detect format or default to JPG
        if (_isPng(params.imageBytes)) {
          compressed = Uint8List.fromList(img.encodePng(processedImage, level: (100 - params.quality) ~/ 10));
        } else {
          compressed = Uint8List.fromList(img.encodeJpg(processedImage, quality: params.quality));
        }
      }

      // If the "compressed" version is actually larger than the original and we didn't resize,
      // return the original bytes
      if (!needsResize && compressed.length >= params.imageBytes.length) {
        return params.imageBytes;
      }

      return compressed;
    } catch (e) {
      return null;
    }
  }

  static bool _isPng(Uint8List bytes) {
    return bytes.length >= 4 && 
           bytes[0] == 0x89 && 
           bytes[1] == 0x50 && 
           bytes[2] == 0x4E && 
           bytes[3] == 0x47;
  }

  static Future<File?> compressImageFile(
    File imageFile, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 75,
    bool maintainAspectRatio = true,
  }) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      Uint8List? compressedBytes = await compressImage(
        imageBytes,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
        maintainAspectRatio: maintainAspectRatio,
      );

      if (compressedBytes == null) {
        return null;
      }

      // Create a new file with compressed data
      String newPath = '${imageFile.path}_compressed.jpg';
      File compressedFile = File(newPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image file: $e');
      }
      return null;
    }
  }

  static double calculateCompressionRatio(Uint8List original, Uint8List compressed) {
    if (original.isEmpty) return 0.0;
    return (1.0 - (compressed.length / original.length)) * 100;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

class _CompressionParams {
  final Uint8List imageBytes;
  final int maxWidth;
  final int maxHeight;
  final int quality;
  final bool maintainAspectRatio;
  final bool forceJpg;

  _CompressionParams({
    required this.imageBytes,
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
    required this.maintainAspectRatio,
    required this.forceJpg,
  });
}

