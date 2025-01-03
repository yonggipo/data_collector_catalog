import 'package:sensors_plus/sensors_plus.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

class InertialCollector extends Collector {
  InertialCollector._() : super();
  static final shared = InertialCollector._();
  factory InertialCollector() => shared;

  @override
  Item get item => Item.sensorEvnets;

  @override
  String get messagePortName => 'InertialCollector';

  @override
  SamplingInterval get samplingInterval => SamplingInterval.min15;

  @override
  Future<void> onCollect() async {
    super.onCollect();

    // 중력의 영향을 포함한 장치의 가속도 (m/s²)
    final userAcc = await userAccelerometerEventStream()
        .firstWhere((e) => (e.x != 0) || (e.y != 0) || (e.z != 0));
    // 장치의 가속도 (m/s²?)
    final acc = await accelerometerEventStream()
        .firstWhere((e) => (e.x != 0) || (e.y != 0) || (e.z != 0));
    // 장치의 회전
    final gyr = await gyroscopeEventStream()
        .firstWhere((e) => (e.x != 0) || (e.y != 0) || (e.z != 0));
    // 장치를 둘러싼 자기장
    final mag = await magnetometerEventStream()
        .firstWhere((e) => (e.x != 0) || (e.y != 0) || (e.z != 0));

    sendMessageToMainPort(<String, dynamic>{
      'user_accelerometer': <String, dynamic>{
        'x': userAcc.x,
        'z': userAcc.z,
        'y': userAcc.y
      },
      'accelerometer': <String, dynamic>{'x': acc.x, 'z': acc.z, 'y': acc.y},
      'gyroscope': <String, dynamic>{'x': gyr.x, 'z': gyr.z, 'y': gyr.y},
      'magnetometer': <String, dynamic>{'x': mag.x, 'z': mag.z, 'y': mag.y}
    });
    sendMessageToMainPort(false);
  }
}
