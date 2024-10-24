import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/services.dart';

import '../../common/constants.dart';

class ApplicationAdaptor {
  ApplicationAdaptor._();

  static const _log = 'ApplicationAdaptor';
  static const _eventChannel = EventChannel(Constants.applicationEvnet);
  static const _methodChannel = MethodChannel(Constants.applicationMethod);

  static Stream<Map>? _stream;
  static Stream<Map> get stream {
    if (!Platform.isAndroid) {
      throw Exception("Notifications API exclusively available on Android!");
    }

    _stream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => jsonDecode(event));
    // .map<NotificationEvent>((e) => NotificationEvent.fromMap(e));
    return _stream!;
  }

  static Future<bool> requestPermission() async {
    try {
      dev.log('requestPermission', name: _log);
      return await _methodChannel.invokeMethod('requestPermission');
    } on PlatformException catch (error) {
      dev.log('$error', name: _log);
      return false;
    }
  }

  static Future<bool> hasPermission() async {
    try {
      final isGranted = await _methodChannel.invokeMethod('hasPermission');
      dev.log('hasPermission: $isGranted', name: _log);
      return isGranted;
    } on PlatformException catch (error) {
      dev.log('$error', name: _log);
      return false;
    }
  }
}
