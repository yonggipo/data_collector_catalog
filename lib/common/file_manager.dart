import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'constants.dart';

@override
Future<void> upload(String filePath, dynamic file) async {
  // var formData = FormData.fromMap({
  //   'Lux': await MultipartFile.fromFile(filePath,
  //       filename: 'Lux.json', contentType: MediaType('application', 'json')),
  //   'pin': pin, // Add the pin form field
  // });
  // var options = Options(headers: {'Content-Type': 'multipart/form-data'});
  // var response =
  //     await dio.post("$subUrl/app/upload", data: formData, options: options);
  // if (response.statusCode == 200) {
  //   dev.log('File uploaded successfully!');
  //   file.deleteSync();
  // } else {
  //   dev.log('[✗ Noti] network: ${response.statusCode}');
  // }
}

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

  Future<void> save(Map map, String path) async {
    final jsonData = json.encode(map);
    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final filePath = '${directory.path}/$path';
    final file = File(filePath);
    file.writeAsStringSync(jsonData);
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
