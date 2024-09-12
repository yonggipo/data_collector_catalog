abstract class SensorUtil {
  Future<bool> requestPermission();
  void start();
  void cancel();
  void onError(Object error);
  void onData(dynamic object);
}
