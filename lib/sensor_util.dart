import 'model/sampling_interval.dart';

abstract class SensorUtil {
  SensorUtil() {
    onLoad();
  }

  SamplingInterval get samplingInterval;
  Future<bool> requestPermission();
  void onLoad();
  void start();
  void cancel();
  void onError(Object error);
  void onData(dynamic object);
  void upload(String filePath, dynamic file);
}
