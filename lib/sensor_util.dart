import 'sampling_interval.dart';

abstract class SensorUtil {
  SamplingInterval get samplingInterval;
  Future<bool> requestPermission();

  void start();
  void cancel();
  void onError(Object error);
  void onData(dynamic object);
  void upload(String filePath, dynamic file);
}
