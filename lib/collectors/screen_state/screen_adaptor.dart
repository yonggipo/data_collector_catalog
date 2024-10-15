import 'dart:convert';
import 'dart:io';

import 'package:data_collector_catalog/collectors/screen_state/screen_state_event.dart';
import 'package:flutter/services.dart';

import 'screen_state.dart';

class ScreenAdaptor {
  ScreenAdaptor._();

  static const _log = 'ScreenAdaptor';
  static const _eventChannel = EventChannel("com.kane.screen.event");

  static Stream<ScreenStateEvent>? _stream;
  static Stream<ScreenStateEvent> get stream {
    if (!Platform.isAndroid) {
      throw Exception("ScreenAdaptor is only implemented in Android");
    }

    _stream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => jsonDecode(event))
        .map<ScreenStateEvent>((e) => ScreenStateEvent.fromMap(e));
    return _stream!;
  }
}
