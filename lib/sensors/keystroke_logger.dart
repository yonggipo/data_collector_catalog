import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/sensors/key_event_listener.dart';
import 'package:flutter/foundation.dart';

import '../sampling_interval.dart';
import '../sensor_util.dart';

/// AOS - https://developer.android.com/reference/android/view/KeyEvent
/// iOS -
final class KeystrokeLogger extends SensorUtil {
  static final KeystrokeLogger shared = KeystrokeLogger._();
  KeystrokeLogger._();
  factory KeystrokeLogger() => shared;
  StreamSubscription? _subscription;

  @override
  final samplingInterval = SamplingInterval.event;

  @override
  void cancel() {
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
  Future<bool> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }

  @override
  void start() {
    _subscription = KeyEventListener.keyEvnetStream.listen(onData);
  }
}
