import 'dart:async';

import 'package:light_sensor/light_sensor.dart';
import 'dart:developer' as dev;

import 'sensor_util.dart';

final class LightSensorUtil implements SensorUtil {
  static final LightSensorUtil shared = LightSensorUtil._();
  LightSensorUtil._();
  factory LightSensorUtil() => shared;

  StreamSubscription? _subscription;

  @override
  void cancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onData(object) {
    dev.log('LUX: $object');
  }

  @override
  void onError(Object error) {
    // TODO: implement onError
  }

  @override
  void start() async {
    // LightSensor
    final hasSensor = await LightSensor.hasSensor();
    if (hasSensor) _subscription = LightSensor.luxStream().listen(onData);
  }

  @override
  Future<bool> requestPermission() {
    return Future.value(true);
  }
}
