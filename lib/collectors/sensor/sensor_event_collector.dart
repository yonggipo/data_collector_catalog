import 'dart:async';
import 'dart:developer' as dev;

import 'package:sensors_plus/sensors_plus.dart';

import '../../common/local_db_service.dart';
import '../../models/collector.dart';

class SensorEventCollector extends Collector {
  SensorEventCollector._() : super();
  static final SensorEventCollector shared = SensorEventCollector._();
  factory SensorEventCollector() => shared;

  static const _log = 'SensorEventCollector';
  // ignore: unused_field
  StreamSubscription? _subscription;

  /// TODO: 값이 제대로 들어오는지 확인해야 함
  /// [SensorEventCollector] onData: {x: 0.0, z: 0.0, y: 0.0}
  /// [SensorEventCollector] onData: {x: 0.002159513533115387, z: 0.004904747009277344, y: 0.0016338974237442017}
  /// [SensorEventCollector] onData: {x: -0.002205025404691696, z: 0.009659767150878906, y: 0.00021119415760040283}
  /// [SensorEventCollector] onData: {x: 0.001930195838212967, z: 0.014006614685058594, y: -0.0014226734638214111}
  /// [SensorEventCollector] onData: {x: 0.0026906877756118774, z: 0.01701068878173828, y: 0.0010791867971420288}
  /// [SensorEventCollector] onData: {x: 0.0018122680485248566, z: 0.015103340148925781, y: 0.0007445067167282104}
  @override
  void onCollectStart() async {
    super.onCollectStart();
    dev.log('onStart', name: _log);

    try {
      // stream 으로 받을 시 너무 많은 데이터가 들어옴
      // _subscription = userAccelerometerEventStream().listen(onData, onError: onError);

      // 장치의 가속도 (m/s²?)
      final userAcc = await userAccelerometerEventStream().firstWhere(
          (userAcc) =>
              (userAcc.x != 0) || (userAcc.y != 0) || (userAcc.z != 0));
      dev.log('accelerometer: ${userAcc.x}, ${userAcc.y}, ${userAcc.z}',
          name: _log);
      LocalDbService.sendMessageToSavePort(
          'user_accelerometer', <String, dynamic>{
        'x': userAcc.x,
        'z': userAcc.z,
        'y': userAcc.y,
      });

      // 중력의 영향을 포함한 장치의 가속도 (m/s²)
      final acc = await accelerometerEventStream()
          .firstWhere((acc) => (acc.x != 0) || (acc.y != 0) || (acc.z != 0));
      dev.log('accelerometer: ${acc.x}, ${acc.y}, ${acc.z}', name: _log);
      LocalDbService.sendMessageToSavePort('accelerometer', <String, dynamic>{
        'x': acc.x,
        'z': acc.z,
        'y': acc.y,
      });

      // 장치의 회전
      final gyr = await gyroscopeEventStream()
          .firstWhere((gyr) => (gyr.x != 0) || (gyr.y != 0) || (gyr.z != 0));
      dev.log('gyroscope: ${gyr.x}, ${gyr.y}, ${gyr.z}', name: _log);
      LocalDbService.sendMessageToSavePort('gyroscope', <String, dynamic>{
        'x': gyr.x,
        'y': gyr.y,
        'z': gyr.z,
      });

      // 장치를 둘러싼 자기장
      final mag = await magnetometerEventStream()
          .firstWhere((mag) => (mag.x != 0) || (mag.y != 0) || (mag.z != 0));
      dev.log('magnetometer: ${mag.x}, ${mag.y}, ${mag.z}', name: _log);
      LocalDbService.sendMessageToSavePort('magnetometer', <String, dynamic>{
        'x': mag.x,
        'y': mag.y,
        'z': mag.z,
      });
    } catch (e) {
      dev.log('Error occurred: $e', name: _log);
    }

    dev.log('onCancel', name: _log);
    onCancel();
  }
}
