import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/models/collector.dart';
import 'package:phone_state/phone_state.dart';

class CallLogCollector extends Collector {
  CallLogCollector._() : super();
  static final shared = CallLogCollector._();
  factory CallLogCollector() => shared;

  static const _log = 'CallLogCollector';
  StreamSubscription? _subscriptions;

  @override
  void onStart() {
    super.onStart();
    dev.log('Start collection', name: _log);
    PhoneState.stream.listen(onData, onError: onError);
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.cancel();
    _subscriptions = null;
  }
}
