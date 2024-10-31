// ignore: unused_import
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'dart:ui';

import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_service.dart';

class LocalDbService {
  LocalDbService._();
  static const _log = 'LocalDbService';
  static List<StreamSubscription>? _subscriptions;

  static void clear() {
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }

  // Register background message stream listener
  static void registerBackgroundMessagePort() {
    dev.log('Registered save port and upload port', name: _log);
    final savePort = ReceivePort();
    IsolateNameServer.registerPortWithName(savePort.sendPort, 'main_port');
    final uploadPort = ReceivePort();
    IsolateNameServer.registerPortWithName(uploadPort.sendPort, 'upload');

    _subscriptions ??= [
      savePort.listen((message) async {
        dev.log(
            '[${Isolate.current.debugName}] Receive meesage in save port message: $message',
            name: _log);
        final path = message['path'];
        final data = message['data'];
        await save(path, data);
      }, onError: (e) {
        dev.log('Error occurred: $e', name: _log);
      }),
      uploadPort.listen((message) async {
        dev.log(
            '${Isolate.current.hashCode} Receive meesage in upload port message: $message',
            name: _log);
        final path = message['path'];
        await upload(path);
      }),
    ];
  }

  // Send message to main isolate
  static void sendMessageToSavePort(String path, Map<String, dynamic> data) {
    dev.log('Send meesage to save port path: $path, onData: $data', name: _log);
    final message = <String, dynamic>{
      'path': path,
      'data': data,
    };
    IsolateNameServer.lookupPortByName('main_port')?.send(message);
  }

  // Send message to main isolate
  static void sendMessageToUploadPort(String path) {
    try {
      dev.log(
          '[${Isolate.current.debugName}] Send meesage to upload port path: $path',
          name: _log);
      final message = <String, dynamic>{'path': path};
      IsolateNameServer.lookupPortByName('upload')?.send(message);
    } catch (e) {
      dev.log('Error occurred: $e', name: _log);
    }
  }

  static Future<Box> _loadBox(String path) async {
    await Hive.initFlutter();
    final isOpen = Hive.isBoxOpen(path);
    return isOpen ? Hive.box(path) : await Hive.openBox(path);
  }

  static Future<void> save(String path, dynamic map) async {
    try {
      dev.log('Save $path data: $map', name: _log);
      map['timestamp'] = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      final box = await _loadBox(path);
      await box.add(map);
    } catch (e) {
      dev.log('Error occurred: $e', name: _log);
    }
  }

  static Future<int> count(String path) async {
    final box = await _loadBox(path);
    return box.values.length;
  }

  static Future<void> upload(String path) async {
    try {
      final box = await _loadBox(path);
      final maps = box.values.cast<Map>();
      dev.log('$path data count: ${maps.length}', name: _log);
      box.values.cast<Map>().forEach((data) async {
        await FirebaseService.shared.upload(path: path, map: data);
      });
      box.clear();
    } catch (e) {
      dev.log('Error occurred: $e', name: _log);
    }
  }

  static Future<bool> isUserIn() async {
    final box = await _loadBox("user");
    final username = box.get('root');
    return (username != null);
  }
}
