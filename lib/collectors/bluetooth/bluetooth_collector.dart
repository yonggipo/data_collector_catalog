import 'dart:async';
import 'dart:developer' as dev;

import '../../common/constants.dart';
import '../../common/local_db_service.dart';
import '../../models/collector.dart';
import 'bluetooth_adaptor.dart';

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
    dev.log('onStart', name: _log);
    _subscription = BluetoothAdaptor.stream.listen(onData, onError: onError);
  }

  @override
  void onData(data) async {
    super.onData(data);
    if (data is! Map) return;
    LocalDbService.save(data, Constants.bluetooth);
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
