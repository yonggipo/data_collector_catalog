import 'dart:async';
import 'dart:developer' as dev;
import 'package:notification_listener_service/notification_listener_service.dart';

import 'sampling_interval.dart';
import 'sensor_util.dart';

final class NotificationUtil implements SensorUtil {
  static final NotificationUtil shared = NotificationUtil._();
  NotificationUtil._();
  factory NotificationUtil() => shared;

  StreamSubscription? _subscription;

  @override
  SamplingInterval samplingInterval = SamplingInterval.event;

  @override
  void cancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onData(object) {
    dev.log('<notification util> notification: $object');
  }

  @override
  void onError(Object error) {
    // TODO: implement onError
  }

  /// request notification permission
  @override
  Future<bool> requestPermission() async {
    return NotificationListenerService.requestPermission();
  }

  @override
  void start() async {
    bool status = await NotificationListenerService.isPermissionGranted();
    if (!status) {
      if (await requestPermission()) {
        /// stream the incoming notification events
        NotificationListenerService.notificationsStream.listen(onData);
      }
    }
  }
}
