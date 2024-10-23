import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collectors/bluetooth/bluetooth_adaptor.dart';

import '../../common/firebase_service.dart';
import '../../models/collector.dart';

class BluetoothCollector extends Collector {
  BluetoothCollector._() : super();
  static final shared = BluetoothCollector._();
  factory BluetoothCollector() => shared;

  // ignore: unused_field
  static const _log = 'BluetoothCollector';
  StreamSubscription? _subscription;

  @override
  void onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);
    _subscription = BluetoothAdaptor.stream.listen(onData, onError: onError);
  }

  @override
  void onData(data) async {
    super.onData(data);
    dev.log('onData: $data', name: _log);
    FirebaseService.shared.upload(path: 'bluetooth', map: data);
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
