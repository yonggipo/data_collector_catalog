import 'dart:async';
import 'dart:developer' as dev;

import 'package:cron/cron.dart';
import 'package:data_collector_catalog/models/collection_item.dart';
import 'package:data_collector_catalog/models/sampling_interval.dart';
import 'package:flutter/foundation.dart';

abstract class Collector {
  static const _log = 'Collector';

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

  void onStart() {
    _isCollecting = true;
    isCollectingNotifier.value = _isCollecting;
    _timer?.cancel();
    _timer = null;
  }

  void onCancel() {
    _isCollecting = false;
    isCollectingNotifier.value = _isCollecting;
    _progressValue = 0.0;
    if (_duration != null) {
      tracking(_duration!);
    }
    progressNotifier.value = _progressValue;
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
    onStart();
    dev.log('Start initial ${item.name} collection..', name: _log);

    // 이후 주기적으로 시작
    if (item.samplingInterval != SamplingInterval.event) {
      final schedule = Schedule.parse('*/${_duration?.inMinutes} * * * *');
      _cron.schedule(schedule, () {
        onStart();
        dev.log('Start ${item.name}\'s schedule: $schedule', name: _log);
      });
    }
  }

  void tracking(Duration duration) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final secondsInInterval = duration.inSeconds;
      final elapsed = timer.tick;
      var progress = elapsed / secondsInInterval;
      if (progress >= 1.0) {
        _progressValue = 1.0;
      } else {
        _progressValue = progress;
      }
      progressNotifier.value = _progressValue;
    });
  }
}
