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
    dev.log('<notification util> notification: $object', time: DateTime.now());
    print(object);
    // [log] <notification util> notification: ServiceNotificationEvent(
    //         id: 1249065348
    //         can reply: false
    //         packageName: com.android.vending
    //         title: 카카오톡 KakaoTalk을(를) 설치할 수 없음
    //         content: 다시 시도해도 문제가 계속되면 일반적인 문제해결 방법을 참조하세요.
    //         hasRemoved: false
    //         haveExtraPicture: false
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
    dev.log('noti detection start');
    bool status = await NotificationListenerService.isPermissionGranted();
    dev.log('noti detection status: $status');

    if (!status) {
      if (await requestPermission()) {
        /// stream the incoming notification events
        NotificationListenerService.notificationsStream.listen(onData);
      }
    } else {
      /// stream the incoming notification events
      NotificationListenerService.notificationsStream.listen(onData);
    }
  }
}
