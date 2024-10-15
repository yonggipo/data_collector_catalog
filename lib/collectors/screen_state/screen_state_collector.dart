import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collectors/screen_state/screen_adaptor.dart';

import '../../models/collector.dart';

class ScreenStateCollector extends Collector {
  ScreenStateCollector._() : super();
  static final ScreenStateCollector shared = ScreenStateCollector._();
  factory ScreenStateCollector() => shared;

  static const _log = 'ScreenStateCollector';
  StreamSubscription? _subscription;

  @override
  void onStart() {
    super.onStart();
    dev.log('Start collection', name: _log);
    _subscription = ScreenAdaptor.stream.listen(
      onData,
      onError: onError,
    );
  }

  @override
  void onData(object) {
    super.onData(object);
    dev.log('onData: $object', name: _log);
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
