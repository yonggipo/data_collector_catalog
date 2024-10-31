import 'dart:async';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'dart:ui';

import 'package:cron/cron.dart';
import 'package:data_collector_catalog/common/local_db_service.dart';
import 'package:data_collector_catalog/models/collection_item.dart';
import 'package:data_collector_catalog/models/sampling_interval.dart';
import 'package:flutter/foundation.dart';

import 'item.dart';

abstract class Collector2 {
  Item get item;
  String get messagePortName;
  SamplingInterval get samplingInterval;
  void collect();

  final _messagePort = ReceivePort();
  // ignore: unused_field
  StreamSubscription? messageSubscription;
  final progressNotifier = ValueNotifier<double>(1.0);
  final valueNotifier = ValueNotifier<dynamic>('loading..');
  final collectingNotifier = ValueNotifier<bool>(false);
  final _cron = Cron();
  Timer? _timer;
  double _progressValue = 0;

  Future<void> registerMessagePort() async {
    IsolateNameServer.registerPortWithName(
        _messagePort.sendPort, messagePortName);
    messageSubscription = _messagePort.listen(_onMessage);
  }

  void sendMessageToPort(dynamic message) {
    IsolateNameServer.lookupPortByName(messagePortName)?.send(message);
  }

  Future<void> _onMessage(dynamic message) async {
    if (message is bool) message ? _resetTracker() : _trackReminderTime();
    // if (message is Map<String, dynamic>) valueNotifier.value = message;

    if (message is Map<String, dynamic>) {
      final map = message;
      var entries = <String>[];
      for (var k in map.keys) {
        await LocalDbService.save(k, map[k]);
        final count = await LocalDbService.count(k);
        entries.add('${k.substring(0, 3)}: $count');
      }
      valueNotifier.value = entries.join(', ');
    }
  }

  void _resetTracker() {
    collectingNotifier.value = true;
    _timer?.cancel();
    _timer = null;
  }

  void _trackReminderTime() {
    collectingNotifier.value = false;
    _progressValue = 0;
    _tracking(samplingInterval.duration);
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
    collect();
    // 이후 주기적으로 시작
    if (samplingInterval != SamplingInterval.event) {
      final min = samplingInterval.duration.inMinutes;
      final schedule = Schedule.parse('*/$min * * * *');
      _cron.schedule(schedule, () => collect());
    }
  }
}

abstract class Collector {
  static const _log = 'Collector';

  Future<void> registerMessagePort() async {
    final isCollectingPort = _isCollectingPort ?? ReceivePort();
    IsolateNameServer.registerPortWithName(
        isCollectingPort.sendPort, 'isCollecting');
    isCollectingPort.listen((message) {
      dev.log(
          '[${Isolate.current.hashCode}] Received message isCollecting port: $message',
          name: _log);
      final isStart = message;
      if (isStart) {
        _isCollecting = true;
        isCollectingNotifier.value = _isCollecting;
        _timer?.cancel();
        _timer = null;
      } else {
        _isCollecting = false;
        isCollectingNotifier.value = _isCollecting;
        _progressValue = 0.0;
        if (_duration != null) {
          tracking(_duration!);
        }
        progressNotifier.value = _progressValue;
      }
    });
  }

  ReceivePort? _isCollectingPort;
  final isCollectingNotifier = ValueNotifier<bool>(false);
  final progressNotifier = ValueNotifier<double>(1.0);

  final _cron = Cron();
  Timer? _timer;
  var _progressValue = 1.0;
  Duration? _duration;
  bool _isCollecting = false;

  Future<bool> onCheck() {
    return Future(() => false);
  }

  Future<bool> onRequest() {
    return Future(() => false);
  }

  void onCollectStart() {
    // _isCollecting = true;
    // dev.log('[${Isolate.current.debugName}] onCollectStart', name: _log);
    // isCollectingNotifier.value = _isCollecting;
    // _timer?.cancel();
    // _timer = null;
    dev.log('[${Isolate.current.hashCode}] Send true to isCollecting port',
        name: _log);
    IsolateNameServer.lookupPortByName('isCollecting')?.send(true);
  }

  void onCancel() {
    // 1061391593
    dev.log('[${Isolate.current.hashCode}] Send false to isCollecting port',
        name: _log);
    IsolateNameServer.lookupPortByName('isCollecting')?.send(false);
    // dev.log('[${Isolate.current.debugName}] onCancel', name: _log);
    // _isCollecting = false;
    // isCollectingNotifier.value = _isCollecting;
    // _progressValue = 0.0;
    // if (_duration != null) {
    //   tracking(_duration!);
    // }
    // progressNotifier.value = _progressValue;
  }

  void onData(dynamic data) {}

  FutureOr<void> onError(Object error, StackTrace stackTrace) async {
    dev.log('error: $error', name: _log);
    _isCollecting = false;
  }
}

extension CollectorProgress on Collector {
  static const _log = 'CollectorProgress';

  void start(CollectionItem item) {
    _duration = item.samplingInterval.duration;

    // 초기 시작
    onCollectStart();
    // 이후 주기적으로 시작
    if (item.samplingInterval != SamplingInterval.event) {
      final schedule = Schedule.parse('*/${_duration?.inMinutes} * * * *');
      _cron.schedule(schedule, () {
        onCollectStart();
        dev.log(
            'Start collecting ${item.name}\'s schedule: ${_duration?.inMinutes}',
            name: _log);
      });
    }
  }

  void tracking(Duration duration) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final secondsInInterval = duration.inSeconds;
      final elapsed = timer.tick;
      var progress = elapsed / secondsInInterval;
      // 611578885
      dev.log('[${Isolate.current.hashCode}] tracking progress: $progress',
          name: _log);

      if (progress >= 1.0) {
        _progressValue = 1.0;
      } else {
        _progressValue = progress;
      }
      progressNotifier.value = _progressValue;
    });
  }
}
