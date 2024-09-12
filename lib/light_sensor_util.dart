import 'dart:async';
import 'dart:developer' as dev;

import 'package:light_sensor/light_sensor.dart';

import 'sampling_interval.dart';
import 'sensor_util.dart';

final class LightSensorUtil implements SensorUtil {
  static final LightSensorUtil shared = LightSensorUtil._();
  LightSensorUtil._();
  factory LightSensorUtil() => shared;

  @override
  final samplingInterval = SamplingInterval.min15;
  StreamSubscription? _subscription;

  @override
  void cancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onData(object) {
    dev.log('<light sensor> lux: $object');
    cancel();
  }

  @override
  void onError(Object error) {
    // TODO: implement onError
  }

  @override
  void start() async {
    final hasSensor = await LightSensor.hasSensor();
    if (hasSensor) _subscription = LightSensor.luxStream().listen(onData);
  }

  @override
  Future<bool> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }
}
