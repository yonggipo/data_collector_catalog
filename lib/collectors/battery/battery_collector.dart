import 'dart:async';
import 'dart:developer' as dev;

import 'package:battery_plus/battery_plus.dart';

import '../../common/constants.dart';
import '../../common/local_db_service.dart';
import '../../models/collector.dart';

class BatteryCollector extends Collector {
  BatteryCollector._() : super();
  static final shared = BatteryCollector._();
  factory BatteryCollector() => shared;

  static const _log = 'BatteryCollector';
  final _battery = Battery();

  @override
  Future<void> onCollectStart() async {
    super.onCollectStart();
    dev.log('onStart', name: _log);
    final remaining = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    onData({'remaining': remaining, 'state': state.name});
  }

  @override
  void onData(data) {
    super.onData(data);
    if (data is! Map) return;
    // LocalDbService._save(data, Constants.battery);
  }
}
