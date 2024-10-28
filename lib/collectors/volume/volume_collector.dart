import 'dart:async';
import 'dart:developer' as dev;

import 'package:real_volume/real_volume.dart';

import '../../common/firebase_service.dart';
import '../../models/collector.dart';

final class VolumeCollector extends Collector {
  static const _log = 'VolumeCollector';

  VolumeCollector._() : super();
  static final shared = VolumeCollector._();
  factory VolumeCollector() => shared;

  List<StreamSubscription>? _subscriptions;

  @override
  void onCollectStart() async {
    super.onCollectStart();
    dev.log('Start collection', name: _log);
    _subscriptions ??= [
      RealVolume.onRingerModeChanged.listen(onData, onError: onError),
      RealVolume.onVolumeChanged.listen(onData, onError: onError),
    ];
  }

  @override
  void onData(data) {
    super.onData(data);
    dev.log('onData: $data', name: _log);

    // Upload item to firebase
    if (data is RingerMode) {
      final event = data;
      FirebaseService.shared.upload(
          path: 'volume/ringer_mode',
          map: {'mode': event.name}).onError(onError);
    } else if (data is VolumeObj) {
      final event = data;
      FirebaseService.shared.upload(path: 'volume/level', map: {
        'level': event.volumeLevel,
        'type': event.streamType?.name,
      }).onError(onError);
    }
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
