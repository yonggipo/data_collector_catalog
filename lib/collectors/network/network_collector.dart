import 'dart:developer' as dev;

import 'package:wifi_iot/wifi_iot.dart';

import '../../common/firebase_service.dart';
import '../../models/collector.dart';

class NetworkCollector extends Collector {
  NetworkCollector._() : super();
  static final NetworkCollector shared = NetworkCollector._();
  factory NetworkCollector() => shared;

  static const _log = 'NetworkCollector';

  @override
  void onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);

    final String? ssid = await WiFiForIoTPlugin.getSSID();
    final String? bssid = await WiFiForIoTPlugin.getBSSID();
    final int? signalStrength =
        await WiFiForIoTPlugin.getCurrentSignalStrength();
    final int? frequency = await WiFiForIoTPlugin.getFrequency();

    // Upload item to firebase
    FirebaseService.shared.upload(path: 'network', map: {
      'ssid': ssid,
      'bssid': bssid,
      'signalStrength': signalStrength,
      'frequency': frequency,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Call to calculate the remaining time
    super.onCancel();
  }
}
