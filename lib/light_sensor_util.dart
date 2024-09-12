import 'sensor_util.dart';

final class LightSensorUtil implements SensorUtil {
  static final LightSensorUtil shared = LightSensorUtil._();
  LightSensorUtil._();
  factory LightSensorUtil() => shared;
  
  @override
  void cancel() {
    // TODO: implement cancel
  }
  
  @override
  void listener(obj) {
    // TODO: implement listener
  }
  
  @override
  void onError(Object error) {
    // TODO: implement onError
  }
  
  @override
  void process() {
    // TODO: implement process
  }
  
  @override
  Future<bool> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }
}
