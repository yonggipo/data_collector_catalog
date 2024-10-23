import 'dart:async';
import 'dart:developer' as dev;

import 'package:battery_plus/battery_plus.dart';
import '../../common/firebase_service.dart';
import '../../models/collector.dart';

class BatteryCollector extends Collector {
  BatteryCollector._() : super();
  static final shared = BatteryCollector._();
  factory BatteryCollector() => shared;

  // ignore: unused_field
  static const _log = 'BatteryCollector';

  final _battery = Battery();
  // StreamSubscription? _subscription;

  @override
  Future<void> onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);

    final remaining = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    onData({'remaining': remaining, 'state': state.name});

    // _subscription = _battery.onBatteryStateChanged.listen(onData, onError: onError);
  }

  @override
  void onData(data) {
    super.onData(data);

    dev.log('onData: $data', name: _log);
    FirebaseService.shared.upload(path: 'battery', map: data);
  }

  void cancelListener() {
    // _subscription?.cancel();
    // _subscription = null;
  }
}
