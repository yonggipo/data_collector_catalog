import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'constants.dart';

class FileManager {
  static final FileManager shared = FileManager._();
  FileManager._();
  factory FileManager() => shared;

  Directory? directory;

  Future<void> toJsonFile(dynamic data) async {
    final jsonContent = json.encode(data);
    try {
      directory = await getExternalStorageDirectory();
    } catch (e) {
      dev.log('[✗ Noti] file: $e');
    }

    if (directory == null) {
      dev.log('[✗ Noti] path is null');
      return;
    }

    final filePath = '${directory?.path}/${Constants.file.lux}';
    final file = File(filePath);
    file.writeAsStringSync(jsonContent);
    // uploadJsonFile(filePath, file);
  }
}
