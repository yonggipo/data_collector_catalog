import 'dart:async';
import 'dart:developer' as dev;

import 'package:blue_info/blue_info.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

class BluetoothCollector extends Collector2 {
  BluetoothCollector._() : super();
  static final shared = BluetoothCollector._();
  factory BluetoothCollector() => shared;

  // ignore: unused_field
  static const _log = 'BluetoothCollector';
  StreamSubscription? _subscription;

  @override
  Item get item => Item.bluetooth;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.event;

  @override
  void collect() {
    sendMessageToPort(true);
    _subscription = BlueInfo.stream.listen(onData, onError: onError);
  }

  void onData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final blueInfo = data;
      sendMessageToPort(<String, dynamic>{'bluetooth': blueInfo});
      sendMessageToPort(true);
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
