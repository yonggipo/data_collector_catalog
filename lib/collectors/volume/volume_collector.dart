import 'dart:async';
import 'dart:developer' as dev;

import 'package:real_volume/real_volume.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

final class VolumeCollector extends Collector2 {
  static const _log = 'VolumeCollector';

  VolumeCollector._() : super();
  static final shared = VolumeCollector._();
  factory VolumeCollector() => shared;

  List<StreamSubscription>? _subscriptions;

  @override
  Item get item => Item.volume;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.event;

  @override
  void collect() {
    sendMessageToPort(true);
    _subscriptions ??= [
      RealVolume.onRingerModeChanged.listen(onData, onError: onError),
      RealVolume.onVolumeChanged.listen(onData, onError: onError),
    ];
  }

  void onData(dynamic data) {
    if (data is RingerMode) {
      final ringerMode = data;
      sendMessageToPort(<String, dynamic>{
        'ringer_mode': <String, dynamic>{'mode': ringerMode.name}
      });
    } else if (data is VolumeObj) {
      final volume = data;
      sendMessageToPort(<String, dynamic>{
        'volume': <String, dynamic>{
          'level': volume.volumeLevel,
          'type': volume.streamType?.name
        }
      });
    }
    sendMessageToPort(true);
  }

  FutureOr<void> onError(Object error, StackTrace stackTrace) async {
    dev.log('Error occurred: $error', name: _log);
  }

  void onCancel() {
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
