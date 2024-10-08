import 'dart:developer' as dev;

abstract class Collector {
  static const logName = 'Collector';

  Collector() {
    onLoad();
  }

  bool isCollecting = false;

  Future<bool?> requestPermission() {
    return Future(() => null);
  }

  void onLoad() {}

  void start() {
    isCollecting = true;
  }

  void cancel() {
    isCollecting = false;
  }

  void onData(dynamic object) {}

  void onError(Object error) {
    dev.log('error: $error', name: logName);
    isCollecting = false;
  }

  void upload(String filePath, dynamic file) {}
}
