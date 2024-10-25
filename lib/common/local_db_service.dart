// ignore: unused_import
import 'dart:developer' as dev;

import 'package:hive/hive.dart';

import 'firebase_service.dart';

class LocalDbService {
  LocalDbService._();

  static Future<Box> loadBox(String path) async {
    final isOpen = Hive.isBoxOpen(path);
    return isOpen ? Hive.box(path) : await Hive.openBox(path);
  }

  static Future<void> save(Map map, String path) async {
    map['timestamp'] = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final box = await loadBox(path);
    await box.add(map);
  }

  static Future<void> upload(String path) async {
    final box = await loadBox(path);
    box.values.cast<Map>().forEach((data) async {
      await FirebaseService.shared.upload(path: path, map: data);
    });
  }
}
