import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collectors/health/walking_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:pedometer/pedometer.dart';

import '../../collertor/collector.dart';
import 'activity_event.dart';
import 'walking_status.dart';

class HealthCollector extends Collector {
  HealthCollector._() : super();
  static final shared = HealthCollector._();
  factory HealthCollector() => shared;

  static const _log = 'Health';

  final _recognizer = FlutterActivityRecognition.instance;
  List<StreamSubscription> _subscriptions = [];

  @override
  Future<bool?> onRequest() async {
    final permission = await _recognizer.requestPermission();
    return (permission == ActivityPermission.GRANTED);
  }

  Future<bool> isGranted() async {
    final permission = await _recognizer.checkPermission();
    return (permission == ActivityPermission.GRANTED);
  }

  @override
  void onStart() {
    super.onStart();
    dev.log('Start collection', name: _log);
    final recSubscription =
        _recognizer.activityStream.handleError(onError).listen(onData);
    final pedSubscription = Pedometer.pedestrianStatusStream.listen(onData);
    pedSubscription.onError(onError);
    final stpSubscription = Pedometer.stepCountStream.listen(onData);
    stpSubscription.onError(onError);

    _subscriptions = [recSubscription, pedSubscription, stpSubscription];
  }

  @override
  void onData(object) async {
    super.onData(object);
    if (object is Activity) {
      Activity activity = object;
      dev.log(activity.toJson().toString(), name: _log);
      final item = ActivityEvent.fromMap(activity.toJson());

      // Upload item to firebase
      await Firebase.initializeApp();
      final ref = FirebaseDatabase.instance.ref();
      await ref
          .child("health")
          .child('activityEvent')
          .push()
          .set(item.toMap())
          .catchError((e) {
        dev.log('error: $e', name: _log);
      });
    } else if (object is StepCount) {
      StepCount stepCount = object;
      dev.log(stepCount.toString(), name: _log);

      final walking = WalkingEvent(
          stepCount: stepCount.steps, dateTime: stepCount.timeStamp);

      // Upload item to firebase
      await Firebase.initializeApp();
      final ref = FirebaseDatabase.instance.ref();
      await ref
          .child("health")
          .child('walkingEvnet')
          .push()
          .set(walking.toMap())
          .catchError((e) {
        dev.log('error: $e', name: _log);
      });
    } else if (object is PedestrianStatus) {
      PedestrianStatus pedestrianStatus = object;
      dev.log(pedestrianStatus.toString(), name: _log);
      final status = WalkingStatus(
          type: WalkingType.values
              .firstWhere((v) => v.toString() == pedestrianStatus.status),
          dateTime: pedestrianStatus.timeStamp);

      // Upload item to firebase
      await Firebase.initializeApp();
      final ref = FirebaseDatabase.instance.ref();
      await ref
          .child("health")
          .child('walkingStatus')
          .push()
          .set(status.toMap())
          .catchError((e) {
        dev.log('error: $e', name: _log);
      });
    }
  }

  @override
  void onCancel() {
    super.onCancel();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions = [];
  }
}
