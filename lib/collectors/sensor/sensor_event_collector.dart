import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';
import 'dart:developer' as dev;

import '../../models/collector.dart';

class SensorEventCollector extends Collector {
  SensorEventCollector._() : super();
  static final SensorEventCollector shared = SensorEventCollector._();
  factory SensorEventCollector() => shared;

  static const _log = 'Health';
  List<StreamSubscription>? _subscriptions;
  final Duration _duration = const Duration(minutes: 15);

  @override
  void onStart() {
    super.onStart();
    dev.log('Start collection', name: _log);

    _subscriptions ??= [
      // 장치의 가속도를 m/s²
      userAccelerometerEventStream(samplingPeriod: _duration)
          .listen(onData, onError: onError),

      // 중력의 영향을 포함한 장치의 가속도 m/s²
      accelerometerEventStream(samplingPeriod: _duration)
          .listen(onData, onError: onError),

      // 장치의 회전
      gyroscopeEventStream(samplingPeriod: _duration)
          .listen(onData, onError: onError),

      // 장치를 둘러싼 자기장
      magnetometerEventStream(samplingPeriod: _duration)
          .listen(onData, onError: onError),
    ];
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
