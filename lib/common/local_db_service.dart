// ignore: unused_import
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'dart:ui';

import 'package:data_collector_catalog/main.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_service.dart';

class LocalDbService {
  LocalDbService._();
  static const _log = 'LocalDbService';

  // Register background message stream listener
  static StreamSubscription registerBackgroundMessagePort() {
    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'main_port');

    return receivePort.listen((message) async {
      if (message is Map<String, dynamic>) {
        final path = message['path'];
        final data = message['data'];
        await save(data, path);
      }
    });
  }

  // Send message to main isolate
  static void backgroundMessageHandler(String path, Map<String, dynamic> data) {
    dev.log(' path: $path, onData: $data', name: _log);
    final message = <String, dynamic>{
      'path': path,
      'data': data,
    };
    IsolateNameServer.lookupPortByName('main_port')?.send(message);
  }

  static Future<Box> loadBox(String path) async {
    await Hive.initFlutter();
    final isOpen = Hive.isBoxOpen(path);
    return isOpen ? Hive.box(path) : await Hive.openBox(path);
  }

  static Future<void> save(Map map, String path) async {
    final map0 = (map as Map<String, dynamic>);
    dev.log('save $path', name: _log);
    map0['timestamp'] = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final box = await loadBox(path);
    await box.add(map0);
  }

  static Future<void> upload(String path) async {
    final box = await loadBox(path);
    box.values.cast<Map>().forEach((data) async {
      await FirebaseService.shared.upload(path: path, map: data);
    });
  }

  static Future<bool> isUserIn() async {
    final box = await loadBox("user");
    final username = box.get('root');
    return (username != null);
  }
}
