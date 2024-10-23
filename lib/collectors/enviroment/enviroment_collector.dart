import 'dart:async';
import 'dart:developer' as dev;

import 'package:environment_sensors/environment_sensors.dart';

import '../../common/firebase_service.dart';
import '../../models/collector.dart';

class EnviromentCollector extends Collector {
  EnviromentCollector._() : super();
  static final shared = EnviromentCollector._();
  factory EnviromentCollector() => shared;

  // ignore: unused_field
  static const _log = 'EnviromentCollector';
  final _sensors = EnvironmentSensors();
  List<StreamSubscription>? _subscriptions;

  @override
  void onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);

    // lightAvailable
    final tempAvailable =
        await _sensors.getSensorAvailable(SensorType.AmbientTemperature);
    final humidityAvailable =
        await _sensors.getSensorAvailable(SensorType.Humidity);
    final pressureAvailable =
        await _sensors.getSensorAvailable(SensorType.Pressure);

    dev.log('temp available: $tempAvailable', name: _log);
    dev.log('humidity available: $humidityAvailable', name: _log);
    dev.log('pressure available: $pressureAvailable', name: _log);

    _subscriptions ??= [
      if (tempAvailable)
        _sensors.temperature
            .map((event) => ('temperature', event))
            .listen(onData, onError: onError),
      if (humidityAvailable)
        _sensors.humidity
            .map((event) => ('humidity', event))
            .listen(onData, onError: onError),
      if (pressureAvailable)
        _sensors.pressure
            .map((event) => ('pressure', event))
            .listen(onData, onError: onError),
    ];

    await Future.delayed(Duration(seconds: 3));
    onCancel();
  }

  @override
  void onData(data) {
    super.onData(data);

    // Upload item to firebase
    if (data is (String, double)) {
      final pair = data;
      FirebaseService.shared
          .upload(path: 'environment/${pair.$1}', map: {pair.$1: pair.$2});
    }
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
