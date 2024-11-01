import 'dart:async';

// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:isolate';
import 'dart:ui';

import 'package:cron/cron.dart';
import 'package:data_collector_catalog/common/local_db_service.dart';
import 'package:data_collector_catalog/models/sampling_interval.dart';
import 'package:flutter/foundation.dart';

import 'item.dart';

abstract class Collector {
  Item get item;
  String get messagePortName;
  SamplingInterval get samplingInterval;
  void onCancel() {}

  void onCollect() async {
    final hasPermission = await item.hasPermission;
    if (!hasPermission) {
      isOn = false;
      sendMessageToMainPort(false);
      sendMessageToMainPort('Permission is required');
      onCancel();
      return;
    }

    isOn = true;
    sendMessageToMainPort(true);
    sendMessageToMainPort('Waiting evnet..');
  }

  // Isolate variable
  final _cron = Cron();
  var isOn = false;

  // Main Isolate variable
  final _messagePort = ReceivePort();
  // ignore: unused_field
  StreamSubscription? messageSubscription;
  final progressNotifier = ValueNotifier<double>(1.0);
  final messageNotifier = ValueNotifier<dynamic>('Loading..');
  final collectingNotifier = ValueNotifier<bool>(false);
  Timer? _timer;
  double _progressValue = 0;

  Future<void> registerMessagePort() async {
    IsolateNameServer.registerPortWithName(
        _messagePort.sendPort, messagePortName);
    messageSubscription = _messagePort.listen(_onMessage);
  }

  void sendMessageToMainPort(dynamic message) {
    IsolateNameServer.lookupPortByName(messagePortName)?.send(message);
  }

  Future<void> _onMessage(dynamic message) async {
    if (message is String) {
      if (message == '_updateCountLabel') {
        _updateCountLabel();
      } else {
        messageNotifier.value = message;
      }
    }

    if (message is bool) message ? _resetTracker() : _trackReminderTime();

    if (message is Map<String, dynamic>) {
      final map = message;
      for (var k in map.keys) {
        await LocalDbService.save(k, map[k]);
      }
      _updateCountLabel();
    }
  }

  Future<void> _updateCountLabel() async {
    final path = item.paths.first;
    final count = await LocalDbService.count(path);
    messageNotifier.value = 'count: $count';
  }

  void _resetTracker() {
    collectingNotifier.value = true;
    _timer?.cancel();
    _timer = null;
  }

  void _trackReminderTime() {
    collectingNotifier.value = false;
    _progressValue = 0;
    if (samplingInterval != SamplingInterval.event) {
      _tracking(samplingInterval.duration);
    }
  }

  void _tracking(Duration duration) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final secondsInInterval = duration.inSeconds;
      final elapsed = timer.tick;
      var progress = elapsed / secondsInInterval;
      _progressValue = (progress >= 1.0) ? 1.0 : progress;
      progressNotifier.value = _progressValue;
    });
  }

  void start() {
    onCollect();
    // 이후 주기적으로 시작
    if (samplingInterval != SamplingInterval.event) {
      final min = samplingInterval.duration.inMinutes;
      final schedule = Schedule.parse('*/$min * * * *');
      _cron.schedule(schedule, () => onCollect());
    }
  }

  void updateUI() {
    sendMessageToMainPort('_updateCountLabel');
  }
}
