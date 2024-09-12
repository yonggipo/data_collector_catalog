abstract class SensorUtil {
  Future<bool> requestPermission();
  void process();
  void cancel();
  void onError(Object error);
  void listener(dynamic obj);
}