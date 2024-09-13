import 'package:data_collector_catalog/sampling_interval.dart';
import 'package:data_collector_catalog/sensor_util.dart';

final class KeystrokeLogger extends SensorUtil {
  @override
  void cancel() {
    // TODO: implement cancel
  }

  @override
  void onData(object) {
    // TODO: implement onData
  }

  @override
  void onError(Object error) {
    // TODO: implement onError
  }

  @override
  Future<bool> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }

  @override
  // TODO: implement samplingInterval
  SamplingInterval get samplingInterval => throw UnimplementedError();

  @override
  void start() {
    // TODO: implement start
  }
}
