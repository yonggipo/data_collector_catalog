import 'package:flutter/services.dart';

import '../constants.dart';

class LightSensor {
  LightSensor._();

  static const eventChannel = EventChannel(Constants.lightEvent);
  static const methodChannel = MethodChannel(Constants.lightMethod);

  static Future<bool> hasSensor() async {
    return (await methodChannel.invokeMethod<bool?>('sensor')) ?? false;
  }

  static Stream<int> luxStream() {
    return eventChannel.receiveBroadcastStream().map<int>((lux) => lux as int);
  }
}
