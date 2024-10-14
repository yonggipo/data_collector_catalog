import 'dart:async';
import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../collertor/collector.dart';
import 'light_sensor.dart';
import 'lux_event.dart';

final class LightCollector extends Collector {
  LightCollector._() : super();
  static final shared = LightCollector._();
  factory LightCollector() => shared;

  static const _log = 'Light';

  // Dio dio = Dio();

  StreamSubscription? _subscription;
  // ServiceInstance? service;
  List<LuxEvent> envents = [];

  @override
  void onStart() async {
    final hasSensor = await LightSensor.hasSensor();
    if (hasSensor) {
      _subscription = LightSensor.luxStream().listen(onData);
      _subscription?.onError(onError);
    }
  }

  @override
  void onData(object) async {
    dev.log('lux: $object', name: _log);
    final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    final event = LuxEvent(lux: object, timeStamp: timeStamp);

    await Firebase.initializeApp();
    final ref = FirebaseDatabase.instance.ref();
    await ref.child("lux").push().set(event.toJson()).catchError((e) {
      dev.log('[✗] error2: $e');
    });

    // service?.invoke(
    //   'update',
    // );

    // save to json file
    // FileManager().toJsonFile(event.toJson());
  }

  @override
  void onError(Object error) {
    dev.log('error: $error', name: _log);
  }

  @override
  void onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }
}
