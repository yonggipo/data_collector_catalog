import 'dart:async';

import 'package:data_collector_catalog/common/firebase_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:developer' as dev;

import '../../models/collector.dart';

class SensorEventCollector extends Collector {
  SensorEventCollector._() : super();
  static final SensorEventCollector shared = SensorEventCollector._();
  factory SensorEventCollector() => shared;

  static const _log = 'SensorEventCollector';
  List<StreamSubscription>? _subscriptions;

  @override
  void onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);

    _subscriptions ??= [
      // 장치의 가속도를 m/s²
      userAccelerometerEventStream().listen(onData, onError: onError),

      // 중력의 영향을 포함한 장치의 가속도 m/s²
      accelerometerEventStream().listen(onData, onError: onError),

      // 장치의 회전
      gyroscopeEventStream().listen(onData, onError: onError),

      // 장치를 둘러싼 자기장
      magnetometerEventStream().listen(onData, onError: onError),
    ];

    await Future.delayed(Duration(seconds: 3));
    onCancel();
  }

  @override
  void onData(object) {
    super.onData(object);

    if (object is UserAccelerometerEvent) {
      final acc = object;
      FirebaseService.shared.upload(
        path: 'sensors/user_accelerometer',
        map: {
          'x': acc.x,
          'y': acc.y,
          'z': acc.z,
          'timestamp': acc.timestamp.toIso8601String()
        },
      );
    } else if (object is AccelerometerEvent) {
      final acc = object;
      FirebaseService.shared.upload(
        path: 'sensors/accelerometer',
        map: {
          'x': acc.x,
          'y': acc.y,
          'z': acc.z,
          'timestamp': acc.timestamp.toIso8601String()
        },
      );
    } else if (object is GyroscopeEvent) {
      final gyr = object;
      FirebaseService.shared.upload(
        path: 'sensors/gyroscope',
        map: {
          'x': gyr.x,
          'y': gyr.y,
          'z': gyr.z,
          'timestamp': gyr.timestamp.toIso8601String()
        },
      );
    } else if (object is MagnetometerEvent) {
      final mag = object;
      FirebaseService.shared.upload(
        path: 'sensors/magnetometer',
        map: {
          'x': mag.x,
          'y': mag.y,
          'z': mag.z,
          'timestamp': mag.timestamp.toIso8601String()
        },
      );
    }
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
