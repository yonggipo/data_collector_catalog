import 'dart:io';

import 'package:flutter/services.dart';

class CalendarWatcher {
  CalendarWatcher._();
  static const _eventChannel = EventChannel('com.kane.calendar_watcher_event');

  // ignore: unused_field
  static const _log = 'CalendarWatcher';

  static Stream<void>? _stream;
  static Stream<void> get stream {
    if (!Platform.isAndroid) {
      throw Exception("API exclusively available on Android!");
    }

    _stream ??= _eventChannel.receiveBroadcastStream();
    return _stream!;
  }
}
