import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:real_volume/real_volume.dart';

import '../../common/device.dart';
import '../../models/collector.dart';

final class VolumeCollector extends Collector {
  static const _log = 'VolumeCollector';

  VolumeCollector._() : super();
  static final shared = VolumeCollector._();
  factory VolumeCollector() => shared;

  List<StreamSubscription>? _subscriptions;

  @override
  Future<bool> onCheck() async {
    super.onCheck();
    if ((Platform.isAndroid) && (Device.shared.android!.version.sdkInt >= 6)) {
      return await RealVolume.isPermissionGranted() ?? false;
    } else {
      return false;
    }
  }

  @override
  Future<bool?> onRequest() async {
    super.onRequest();
    return await RealVolume.openDoNotDisturbSettings() ?? false;
  }

  @override
  void onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);
    _subscriptions ??= [
      RealVolume.onRingerModeChanged.listen(onData, onError: onError),
      RealVolume.onVolumeChanged.listen(onData, onError: onError),
    ];
  }

  @override
  void onData(object) {
    super.onData(object);
    dev.log('onData: $object', name: _log);
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions?.clear();
  }
}

