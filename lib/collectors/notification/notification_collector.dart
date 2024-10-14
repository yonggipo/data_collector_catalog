import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/common/firebase_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../models/collector.dart';
import 'notification_event.dart';
import 'notification_adaptor.dart';

final class NotificationCollector extends Collector {
  NotificationCollector._() : super();
  static final NotificationCollector shared = NotificationCollector._();
  factory NotificationCollector() => shared;

  static const _log = 'NotificationCollector';
  List<NotificationEvent> envents = [];
  StreamSubscription? _subscription;
  ServiceInstance? service;

  @override
  Future<bool> onCheck() async {
    return NotificationAdaptor.hasPermission();
  }

  @override
  Future<bool> onRequest() async {
    return NotificationAdaptor.requestPermission();
  }

  @override
  void onData(object) async {
    dev.log('notification: ${object.toString()}', name: _log);
    final event = NotificationEvent.fromMap(object);
    FirebaseService.shared.upload(path: 'notification', serializable: event);
  }

  @override
  void onStart() async {
    dev.log('Start collection', name: _log);
    _subscription = NotificationAdaptor.stream.listen(onData, onError: onError);
  }

  @override
  void onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }
}
