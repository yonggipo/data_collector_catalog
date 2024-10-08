import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../sensors/constants.dart';

class FileManager {
  static final FileManager shared = FileManager._();
  FileManager._();
  factory FileManager() => shared;

  Directory? directory;

  static requestPermission() {
    // Permission.d
  }

  static Future<String> getPath() async {
    // var status = await Permission.storage.request();
    // dev.log(
    //   '[file] storage permission isGranted: ${status.isGranted}',
    // );

    final directory = await getExternalStorageDirectory();
    dev.log('[file] directory: $directory');
    return directory?.path ?? '';
  }

  // static Future<String> getPath()

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

  static Future<List<String>> findFileNames(String filePath) async {
    final directory = await getExternalStorageDirectory();
    var path = directory?.path;
    if (path == null) {
      dev.log(
        '[file] can not found directory path..',
        name: 'file',
      );
      return [];
    }

    final fullPath = p.join(
      path,
      filePath,
    );
    final fileDirectory = Directory(fullPath);
    if (await fileDirectory.exists()) {
      final files = directory?.listSync();
      if (files != null && files is List<File>) {
        return files.map((e) {
          final name = e.path.split('/').last;
          dev.log(
            '[file] found file name: $name',
            name: 'file',
          );
          return name;
        }).toList();
      } else {
        return [];
      }
    } else {
      dev.log(
        '[file] does not found file directory...',
        name: 'file',
      );
      return [];
    }
  }

  static Future<File?> getFile(String path, String name) async {
    final filePath = p.join(path, name);
    final fileDirectory = Directory(filePath);

    if (!await fileDirectory.exists()) {
      dev.log("[file] $name file) does not exists");
      return null;
    }

    return fileDirectory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith(name))
        .toList()
        .first;
  }
}
