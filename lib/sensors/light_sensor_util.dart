import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';

import '../sensor_util.dart';
import '../sampling_interval.dart';

class LightSensor {
  static const eventChannel = EventChannel("com.kane.light_sensor.stream");
  static const methodChannel = MethodChannel('com.kane.light_sensor');

  static Future<bool> hasSensor() async {
    return (await methodChannel.invokeMethod<bool?>('sensor')) ?? false;
  }

  static Stream<int> luxStream() {
    return eventChannel.receiveBroadcastStream().map<int>((lux) => lux as int);
  }
}

final class LightSensorUtil implements SensorUtil {
  static final LightSensorUtil shared = LightSensorUtil._();
  LightSensorUtil._();
  factory LightSensorUtil() => shared;

  @override
  final samplingInterval = SamplingInterval.test;
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
    dev.log(hasSensor.toString());
    if (hasSensor) {
      _subscription = LightSensor.luxStream().listen(onData);
    } else {
      dev.log('Can not found Light Sensor');
    }
  }

  @override
  Future<bool> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }
}
