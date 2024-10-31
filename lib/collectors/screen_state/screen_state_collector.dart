import 'dart:async';
import 'dart:developer' as dev;

import 'package:screen_state/screen_state.dart';

import '../../models/item.dart';
import '../../models/collector.dart';
import '../../models/sampling_interval.dart';

class ScreenStateCollector extends Collector2 {
  ScreenStateCollector._() : super();
  static final ScreenStateCollector shared = ScreenStateCollector._();
  factory ScreenStateCollector() => shared;

  static const _log = 'ScreenStateCollector';

  final _screen = Screen();
  StreamSubscription? _subscription;

  @override
  Item get item => Item.screenState;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.event;

  @override
  void collect() {
    sendMessageToPort(true);
    _subscription = _screen.screenStateStream.map((e) {
      switch (e.name) {
        case 'android.intent.action.USER_PRESENT':
          return 'SCREEN_UNLOCKED';
        case 'android.intent.action.SCREEN_ON':
          return 'SCREEN_ON';
        case 'android.intent.action.SCREEN_OFF':
          return 'SCREEN_OFF';
      }
    }).listen(onData, onError: onError);
  }

  void onData(data) {
    if (data is String?) {
      final screenState = data;
      sendMessageToPort(<String, dynamic>{
        'screen_state': <String, dynamic>{'state': screenState}
      });
    }
    sendMessageToPort(true);
  }

  FutureOr<void> onError(Object error, StackTrace stackTrace) async {
    dev.log('Error occurred: $error', name: _log);
  }

  void onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }
}
