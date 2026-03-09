import 'dart:typed_data';
import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_mobile.dart';

abstract class FileSaver {
  /// Sauvegarde un fichier ou déclenche un téléchargement
  static Future<String?> saveFile({
    required String fileName,
    required Uint8List bytes,
  }) {
    return saveFileImpl(fileName: fileName, bytes: bytes);
  }
}
