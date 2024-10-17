import 'dart:async';

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

    final isTemAvailable =
        await _sensors.getSensorAvailable(SensorType.AmbientTemperature);
    final isHumAvailable =
        await _sensors.getSensorAvailable(SensorType.Humidity);
    final isPreAvailable =
        await _sensors.getSensorAvailable(SensorType.Pressure);

    _subscriptions ??= [
      if (isTemAvailable)
        _sensors.temperature
            .map((event) => [
                  'temperature',
                  {
                    'value': event,
                    'timestamp': DateTime.now().toIso8601String()
                  }
                ])
            .listen(onData, onError: onError),
      if (isHumAvailable)
        _sensors.humidity
            .map((event) => [
                  'humidity',
                  {
                    'value': event,
                    'timestamp': DateTime.now().toIso8601String()
                  }
                ])
            .listen(onData, onError: onError),
      if (isPreAvailable)
        _sensors.pressure
            .map((event) => [
                  'pressure',
                  {
                    'value': event,
                    'timestamp': DateTime.now().toIso8601String()
                  }
                ])
            .listen(onData, onError: onError),
    ];

    await Future.delayed(Duration(seconds: 3));
    onCancel();
  }

  @override
  void onData(data) {
    super.onData(data);

    // Upload item to firebase
    if (data is List) {
      final list = data;
      FirebaseService.shared.upload(path: list[0], map: list[1]);
    }
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
