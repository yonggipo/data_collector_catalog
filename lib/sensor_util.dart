import 'package:data_collector_catalog/sampling_interval.dart';

abstract class SensorUtil {
  SamplingInterval get samplingInterval;
  Future<bool> requestPermission();

  void start();
  void cancel();
  void onError(Object error);
  void onData(dynamic object);
}
