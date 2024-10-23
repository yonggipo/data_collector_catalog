import 'dart:async';
import 'dart:developer' as dev;

import '../../common/firebase_service.dart';
import '../../models/collector.dart';
import 'light_adaptor.dart';

final class LightCollector extends Collector {
  LightCollector._() : super();
  static final shared = LightCollector._();
  factory LightCollector() => shared;

  static const _log = 'Light';
  StreamSubscription? _subscription;

  @override
  void onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);
    final hasSensor = await LightAdaptor.hasSensor();
    if (hasSensor) {
      _subscription = LightAdaptor.luxStream().listen(onData);
      _subscription?.onError(onError);
    }

    await Future.delayed(Duration(seconds: 3));
    onCancel();
  }

  @override
  void onData(data) async {
    super.onData(data);
    dev.log('lux: $data', name: _log);
    // Upload item to firebase
    FirebaseService.shared
        .upload(path: 'light', map: {'lux': data}).onError(onError);
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
