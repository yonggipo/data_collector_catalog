import 'package:wifi_iot/wifi_iot.dart';

import '../../common/firebase_service.dart';
import '../../models/collector.dart';

class NetworkCollector extends Collector {
  NetworkCollector._() : super();
  static final NetworkCollector shared = NetworkCollector._();
  factory NetworkCollector() => shared;

  @override
  void onStart() async {
    super.onStart();

    final String? ssid = await WiFiForIoTPlugin.getSSID();
    final String? bssid = await WiFiForIoTPlugin.getBSSID();
    final int? signalStrength =
        await WiFiForIoTPlugin.getCurrentSignalStrength();
    final int? frequency = await WiFiForIoTPlugin.getFrequency();

    FirebaseService.shared.upload(path: 'network', map: {
      'ssid': ssid,
      'bssid': bssid,
      'signalStrength': signalStrength,
      'frequency': frequency,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
