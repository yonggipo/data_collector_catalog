import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/common/firebase_service.dart';
import 'package:data_collector_catalog/models/collector.dart';
import 'package:phone_state/phone_state.dart';

class CallLogCollector extends Collector {
  CallLogCollector._() : super();
  static final shared = CallLogCollector._();
  factory CallLogCollector() => shared;

  static const _log = 'CallLogCollector';
  StreamSubscription? _subscription;

  @override
  void onStart() {
    super.onStart();
    dev.log('Start collection', name: _log);
    PhoneState.stream.listen(onData, onError: onError);
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onData(data) {
    super.onData(data);
    if (data is PhoneState) {
      final log = data;
      FirebaseService.shared.upload(path: 'call_log', map: {
        'state': log.status.name,
        'phoneNumber': log.number,
        'timestamp': DateTime.now().toIso8601String()
      }).onError(onError);
    }
  }
}
