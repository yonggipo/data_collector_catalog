import 'dart:developer' as dev;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class Device {
  Device._();
  static final Device shared = Device._();
  factory Device() => shared;

  static const _logName = 'Device';
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  int? andSdk;

  bool get isAboveAndroid9 {
    final int android9 = 28;
    return (andSdk ?? 23) > android9;
  }

  Future<void> checkAndroidVersion() async {
    final androidInfo = await _plugin.androidInfo;
    andSdk = androidInfo.version.sdkInt;
    dev.log('Android version: $andSdk', name: _logName);
  }

  final ValueNotifier<AndroidDeviceInfo?> _andInfo = ValueNotifier(null);
  final ValueNotifier<IosDeviceInfo?> _iosInfo = ValueNotifier(null);
  final ValueNotifier<BaseDeviceInfo?> _deviceInfo = ValueNotifier(null);

  AndroidDeviceInfo? get android => _andInfo.value;
  IosDeviceInfo? get ios => _iosInfo.value;
  BaseDeviceInfo? get device => _deviceInfo.value;

  void initInfo() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo andInfo = await _plugin.androidInfo;
      _andInfo.value = andInfo;
    } else {
      IosDeviceInfo iosInfo = await _plugin.iosInfo;
      _iosInfo.value = iosInfo;
    }
    BaseDeviceInfo deviceInfo = await _plugin.deviceInfo;
    _deviceInfo.value = deviceInfo;
  }
}
