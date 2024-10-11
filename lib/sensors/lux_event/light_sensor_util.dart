import 'dart:async';
import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../collertor/sampling_interval.dart';
import '../../collertor/collector.dart';
import 'light_sensor.dart';
import 'lux_event.dart';

final class LightSensorUtil extends Collector {
  LightSensorUtil._() : super();
  static final LightSensorUtil shared = LightSensorUtil._();
  factory LightSensorUtil() => shared;
  // Dio dio = Dio();
  @override
  final samplingInterval = SamplingInterval.event;
  StreamSubscription? _subscription;
  // ServiceInstance? service;
  List<LuxEvent> envents = [];

  @override
  void cancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  // @override
  // void onData(object) {
  //   dev.log('<light sensor> lux: $object');
  //   if (kReleaseMode) print('[✓] lux: $object');
  // }

  @override
  void onData(object) async {
    dev.log('<light sensor> lux: $object');
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
    dev.log('[✗] error: $error');
  }

  @override
  void start() async {
    final hasSensor = await LightSensor.hasSensor();
    if (hasSensor) {
      _subscription = LightSensor.luxStream().listen(onData);
    } else {
      if (kReleaseMode) print('[✓] Can not found Light Sensor');
      dev.log('Can not found Light Sensor');
    }
  }

  @override
  void upload(String filePath, file) {}

  @override
  void onLoad() {}

  @override
  Future<bool> onRequest() {
    throw UnimplementedError();
  }
}
