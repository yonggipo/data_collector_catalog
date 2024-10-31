import 'dart:async';
import 'dart:developer' as dev;

import 'package:app_usage/app_usage.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

class AppUsageCollector extends Collector {
  AppUsageCollector._() : super();
  static final shared = AppUsageCollector._();
  factory AppUsageCollector() => shared;

  static const _log = 'AppUsageCollector';
  StreamSubscription? _subscription;

  @override
  Item get item => Item.appUsage;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.event;

  @override
  void collect() async {
    final hasPermission = await onCheck();
    dev.log('hasPermission: $hasPermission', name: _log);
    if (hasPermission) {
      sendMessageToPort(true);
      _subscription =
          AppUsage.stream.distinct().listen(onData, onError: onError);
    }
  }

  void onData(data) {
    dev.log('data: $data', name: _log);
    if (data is Map<String, dynamic>) {
      final appUsage = data;
      sendMessageToPort(<String, dynamic>{'app_usage': appUsage});
      sendMessageToPort(true);
    }
  }

  FutureOr<void> onError(Object error, StackTrace stackTrace) async {
    dev.log('Error occurred: $error', name: _log);
  }

  Future<bool> onCheck() async {
    return AppUsage.hasPermission();
  }

  Future<bool> onRequest() async {
    return AppUsage.requestPermission();
  }

  void onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }
}
