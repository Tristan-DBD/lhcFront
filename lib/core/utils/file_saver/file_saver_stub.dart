import 'dart:typed_data';

Future<String?> saveFileImpl({
  required String fileName,
  required Uint8List bytes,
}) {
  throw UnsupportedError('Save file not supported on this platform');
}
