import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<String?> saveFileImpl({
  required String fileName,
  required Uint8List bytes,
}) async {
  return FilePicker.platform.saveFile(
    dialogTitle: 'Sauvegarder le programme',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'xls'],
    bytes: bytes,
  );
}
