import 'dart:async';
import 'dart:developer' as dev;

import 'package:cron/cron.dart';
import 'package:data_collector_catalog/collertor/collection_item.dart';
import 'package:data_collector_catalog/collertor/sampling_interval.dart';
import 'package:flutter/foundation.dart';

abstract class Collector {
  static const _log = 'Collector';

  Collector() {
    onLoad();
  }

  final _isCollectingStreamController = StreamController<bool?>.broadcast();
  Stream<bool?> get isCollectingStream => _isCollectingStreamController.stream;

  final progressNotifier = ValueNotifier<double>(1.0);

  final _cron = Cron();
  Timer? _timer;
  var _progressValue = 1.0;
  Duration? _duration;

  bool _isCollecting = false;

  Future<bool?> onRequest() {
    return Future(() => null);
  }

  void onLoad() {}

  void start() {
    _isCollecting = true;
    _isCollectingStreamController.add(_isCollecting);
    _timer?.cancel();
    _timer = null;
  }

  void cancel() {
    _isCollecting = false;
    _isCollectingStreamController.add(_isCollecting);
    _progressValue = 0.0;
    if (_duration != null) {
      tracking(_duration!);
    }
    progressNotifier.value = _progressValue;
  }

  void onData(dynamic object) {}

  void onError(Object error) {
    dev.log('error: $error', name: _log);
    _isCollecting = false;
  }

  void upload(String filePath, dynamic file) {}
}

extension CollectorProgress on Collector {
  static const _log = 'CollectorProgress';

  void startWith(CollectionItem item) {
    _duration = item.samplingInterval.duration;

    final schedule = Schedule.parse('*/${_duration?.inMinutes} * * * *');
    dev.log('${item.name}\'s schedule: $schedule', name: _log);

    // 초기 시작
    start();
    dev.log('Start initial ${item.name} collection..', name: _log);

    // 이후 주기적으로 시작
    _cron.schedule(schedule, () {
      dev.log('Start ${item.name}\'s schedule..', name: _log);
      start();
    });
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
