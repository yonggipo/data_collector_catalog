import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../common/constants.dart';

class BluetoothAdaptor {
  BluetoothAdaptor._();

  static const _eventChannel = EventChannel(Constants.bluetoothEvent);

  static Stream<Map>? _stream;
  static Stream<Map> get stream {
    if (!Platform.isAndroid) {
      throw Exception("Notifications API exclusively available on Android!");
    }

    _stream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => jsonDecode(event));
    return _stream!;
  }
}
