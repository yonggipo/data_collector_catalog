// ignore: unused_import
import 'dart:developer' as dev;

import 'package:wifi_iot/wifi_iot.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

class NetworkCollector extends Collector {
  NetworkCollector._() : super();
  static final NetworkCollector shared = NetworkCollector._();
  factory NetworkCollector() => shared;

  static const _log = 'NetworkCollector';

  @override
  Item get item => Item.network;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.min5;

  @override
  Future<void> collect() async {
    sendMessageToPort(true);

    final String? ssid = await WiFiForIoTPlugin.getSSID();
    final String? bssid = await WiFiForIoTPlugin.getBSSID();
    final int? signalStrength =
        await WiFiForIoTPlugin.getCurrentSignalStrength();
    final int? frequency = await WiFiForIoTPlugin.getFrequency();

    sendMessageToPort(<String, dynamic>{
      'network': <String, dynamic>{
        'ssid': ssid,
        'bssid': bssid,
        'signalStrength': signalStrength,
        'frequency': frequency,
      },
    });
    sendMessageToPort(false);
  }
}
