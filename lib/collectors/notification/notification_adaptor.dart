import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/services.dart';

import '../../common/constants.dart';
import 'notification_event.dart';

class NotificationAdaptor {
  NotificationAdaptor._();

  static const _log = 'NotificationAdaptor';
  static const _eventChannel = EventChannel(Constants.notiEvent);
  static const _methodChannel = MethodChannel(Constants.notiMethod);

  static Stream<NotificationEvent>? _stream;
  static Stream<NotificationEvent> get stream {
    if (!Platform.isAndroid) {
      throw Exception("Notifications API exclusively available on Android!");
    }

    _stream ??= _eventChannel
        .receiveBroadcastStream()
        .map<NotificationEvent>((e) => NotificationEvent.fromMap(e));
    return _stream!;
  }

  static Future<bool> requestPermission() async {
    try {
      return await _methodChannel.invokeMethod('requestPermission');
    } on PlatformException catch (error) {
      dev.log('$error', name: _log);
      return false;
    }
  }

  static Future<bool> hasPermission() async {
    try {
      return await _methodChannel.invokeMethod('hasPermission');
    } on PlatformException catch (error) {
      dev.log('$error', name: _log);
      return false;
    }
  }
}
