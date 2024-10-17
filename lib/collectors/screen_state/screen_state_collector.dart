import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collectors/screen_state/screen_adaptor.dart';
import 'package:data_collector_catalog/collectors/screen_state/screen_state_event.dart';
import 'package:data_collector_catalog/common/firebase_service.dart';

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
  void onData(data) {
    super.onData(data);
    // dev.log('onData: $data', name: _log);

    // Upload item to firebase
    if (data is ScreenStateEvent) {
      final event = data;
      FirebaseService.shared
          .upload(path: 'screen_state', map: event.toMap())
          .onError(onError);
    }
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
