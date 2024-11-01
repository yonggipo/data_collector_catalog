import 'dart:async';
import 'dart:developer' as dev;

import 'package:phone_state/phone_state.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

class CallLogCollector extends Collector {
  CallLogCollector._() : super();
  static final shared = CallLogCollector._();
  factory CallLogCollector() => shared;

  static const _log = 'CallLogCollector';
  StreamSubscription? _subscription;

  @override
  Item get item => Item.callLog;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.event;

  @override
  void onCollect() async {
    super.onCollect();
    _subscription = PhoneState.stream
        .where((e) => e.number != null)
        .listen(onData, onError: onError);
  }

  void onData(data) {
    if (data is PhoneState) {
      final log = data;
      sendMessageToMainPort(<String, dynamic>{
        'call_log': <String, dynamic>{
          'status': log.status.name,
          'phoneNumber': log.number
        }
      });
      sendMessageToMainPort(true);
    }
  }

  FutureOr<void> onError(Object error, StackTrace stackTrace) async {
    dev.log('Error occurred: $error', name: _log);
  }

  void onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }
}
