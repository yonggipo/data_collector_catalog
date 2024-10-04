import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/services.dart';

import '../constants.dart';
import 'noti_event.dart';

class NotiEventDetector {
  NotiEventDetector._();

  static const _eventChannel = EventChannel(Constants.notiEvent);
  static const _methodChannel = MethodChannel(Constants.notiMethod);
  static Stream<NotiEvent>? _stream;

  static Stream<NotiEvent> get notiStream {
    if (!Platform.isAndroid) {
      throw Exception("Notifications API exclusively available on Android!");
    }

    _stream ??= _eventChannel
        .receiveBroadcastStream()
        .map<NotiEvent>((e) => NotiEvent.fromMap(e));
    return _stream!;
  }

  static Future<bool> requestP() async {
    try {
      return await _methodChannel.invokeMethod('requestP');
    } on PlatformException catch (error) {
      dev.log("$error");
      return Future.value(false);
    }
  }

  static Future<bool> hasP() async {
    try {
      return await _methodChannel.invokeMethod('hasP');
    } on PlatformException catch (error) {
      dev.log("$error");
      return false;
    }
  }
}
