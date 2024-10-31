// ignore: unused_import
import 'dart:developer' as dev;

import 'package:environment_sensors/environment_sensors.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

class EnviromentCollector extends Collector2 {
  EnviromentCollector._() : super();
  static final shared = EnviromentCollector._();
  factory EnviromentCollector() => shared;

  // ignore: unused_field
  static const _log = 'EnviromentCollector';
  final _sensors = EnvironmentSensors();

  @override
  Item get item => Item.environment;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.min15;

  @override
  void collect() async {
    sendMessageToPort(true);

    final tempAvailable =
        await _sensors.getSensorAvailable(SensorType.AmbientTemperature);
    final humidityAvailable =
        await _sensors.getSensorAvailable(SensorType.Humidity);
    final pressureAvailable =
        await _sensors.getSensorAvailable(SensorType.Pressure);
    final lightAvailable = await _sensors.getSensorAvailable(SensorType.Light);
    dev.log('lightAvailable: $lightAvailable', name: _log);

    final tem = (tempAvailable) ? await _sensors.temperature.first : null;
    final hum = (humidityAvailable) ? await _sensors.humidity.first : null;
    final pre = (pressureAvailable) ? await _sensors.pressure.first : null;
    final lux = (lightAvailable) ? await _sensors.light.first : null;

    sendMessageToPort(<String, dynamic>{
      'enviroment': <String, dynamic>{
        'temperature': tem,
        'humidity': hum,
        'pressure': pre,
        'light': lux,
      },
    });
    sendMessageToPort(false);
  }
}
