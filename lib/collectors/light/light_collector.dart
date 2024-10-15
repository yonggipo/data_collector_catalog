import 'dart:async';
import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/collector.dart';
import 'light_adaptor.dart';
import 'lux_event.dart';

final class LightCollector extends Collector {
  LightCollector._() : super();
  static final shared = LightCollector._();
  factory LightCollector() => shared;

  static const _log = 'Light';
  StreamSubscription? _subscription;
  List<LuxEvent> envents = [];

  @override
  void onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);
    final hasSensor = await LightAdaptor.hasSensor();
    if (hasSensor) {
      _subscription = LightAdaptor.luxStream().listen(onData);
      _subscription?.onError(onError);
    }
    
    await Future.delayed(Duration(seconds: 10));
    onCancel();
  }

  @override
  void onData(object) async {
    super.onData(object);
    dev.log('lux: $object', name: _log);
    final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    final event = LuxEvent(lux: object, timeStamp: timeStamp);

    await Firebase.initializeApp();
    final ref = FirebaseDatabase.instance.ref();
    await ref.child("lux").push().set(event.toJson()).catchError((e) {
      dev.log('error: $e', name: _log);
    });
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
