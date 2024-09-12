import 'dart:developer' as dev;
import 'sampling_interval.dart';
import 'sensor_util.dart';

final class NotificationUtil implements SensorUtil {
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
  SamplingInterval samplingInterval = SamplingInterval.event;

  @override
  void start() {
    // TODO: implement start
  }
}
