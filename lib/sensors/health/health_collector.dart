import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/sensors/health/health_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';

import '../../collertor/collector.dart';

class HealthCollector extends Collector {
  HealthCollector._() : super();
  static final shared = HealthCollector._();
  factory HealthCollector() => shared;

  static const _log = 'Health';

  final recognizer = FlutterActivityRecognition.instance;
  StreamSubscription? _subscription;

  @override
  Future<bool?> onRequest() async {
    final permission = await recognizer.requestPermission();
    return (permission == ActivityPermission.GRANTED);
  }

  Future<bool> isGranted() async {
    final permission = await recognizer.checkPermission();
    return (permission == ActivityPermission.GRANTED);
  }

  @override
  void onStart() {
    super.onStart();
    dev.log('Start collection', name: _log);

    _subscription =
        recognizer.activityStream.handleError(onError).listen(onData);
  }

  @override
  void onData(object) async {
    super.onData(object);
    if (object is Activity) {
      Activity activity = object;
      dev.log(activity.toJson().toString(), name: _log);
      final item = HealthItem.fromMap(activity.toJson());

      // Upload item to firebase
      await Firebase.initializeApp();
      final ref = FirebaseDatabase.instance.ref();
      await ref
          .child("health")
          .child('activity')
          .push()
          .set(item.toMap())
          .catchError((e) {
        dev.log('error: $e', name: _log);
      });
    }
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
