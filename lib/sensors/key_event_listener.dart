import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

final class KeyEventListener {
  KeyEventListener._();

  static const _eventChannel = EventChannel('keystroke_event_channel');

  static Stream<dynamic>? _stream;

  static Stream<dynamic> get keyEvnetStream {
    if (Platform.isAndroid) {
      _stream ??= _eventChannel.receiveBroadcastStream();
      return _stream!;
    } else {
      throw Exception("KeyStroke API available on AOS");
    }
  }
}
