import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/models/item.dart';
import 'package:data_collector_catalog/models/sampling_interval.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import '../../models/collector.dart';

final class NotificationCollector extends Collector {
  NotificationCollector._() : super();
  static final NotificationCollector shared = NotificationCollector._();
  factory NotificationCollector() => shared;

  static const _log = 'NotificationCollector';
  StreamSubscription? _subscription;

  @override
  Item get item => Item.notification;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.event;

  @override
  void onCollect() async {
    super.onCollect();
    _subscription = NotificationListenerService.notificationsStream
        .listen(onData, onError: onError);
  }

  void onData(data) async {
    if (data is ServiceNotificationEvent) {
      final notification = data;
      sendMessageToMainPort(<String, dynamic>{
        'notification': <String, dynamic>{
          'id': notification.id,
          'hasRemoved': notification.hasRemoved,
          'packageName': notification.packageName,
          'title': notification.title,
          'content': notification.content,
        }
      });
      sendMessageToMainPort(true);
    }
  }

  FutureOr<void> onError(Object error, StackTrace stackTrace) async {
    dev.log('Error occurred: $error', name: _log);
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
