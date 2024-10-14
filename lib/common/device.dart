import 'dart:developer' as dev;
import 'package:device_info_plus/device_info_plus.dart';

class Device {
  Device._();
  static final Device shared = Device._();
  factory Device() => shared;

  static const _logName = 'Device';

  int? androidVersion;

  bool get isAboveAndroid9 {
    final int android9 = 28;
    return (androidVersion ?? 23) > android9;
  }

  Future<void> checkAndroidVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    androidVersion = androidInfo.version.sdkInt;
    dev.log('Android version: $androidVersion', name: _logName);
  }
}
