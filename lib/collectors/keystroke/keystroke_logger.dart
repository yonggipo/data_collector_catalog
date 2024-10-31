import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import '../../models/collector.dart';
import 'key_event_listener.dart';

final class KeystrokeLogger {
  KeystrokeLogger._() : super();
  static final KeystrokeLogger shared = KeystrokeLogger._();
  factory KeystrokeLogger() => shared;

  StreamSubscription? _subscription;

  @override
  void onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onData(data) {
    if (kReleaseMode) print('[✓] key stroke event $data');
    dev.log('key stroke event: $data');
  }

  @override
  void onCollectStart() {
    _subscription = KeyEventListener.keyEvnetStream.listen(onData);
  }
}
