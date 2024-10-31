// ignore: unused_import
import 'dart:developer' as dev;

import 'package:battery_plus/battery_plus.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

class BatteryCollector extends Collector {
  BatteryCollector._() : super();
  static final shared = BatteryCollector._();
  factory BatteryCollector() => shared;

  static const _log = 'BatteryCollector';
  final _battery = Battery();

  @override
  Item get item => Item.battery;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.h4;

  @override
  void collect() async {
    sendMessageToPort(true);
    final remaining = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    sendMessageToPort(<String, dynamic>{
      'battery': <String, dynamic>{'remaining': remaining, 'state': state.name}
    });
    sendMessageToPort(false);
  }
}
