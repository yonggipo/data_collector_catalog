import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:pedometer/pedometer.dart';

import '../../common/firebase_service.dart';
import '../../models/collector.dart';
import 'activity_event.dart';
import 'walking_event.dart';
import 'walking_status.dart';

class HealthCollector extends Collector {
  HealthCollector._() : super();
  static final shared = HealthCollector._();
  factory HealthCollector() => shared;

  static const _log = 'Health';

  final _recognizer = FlutterActivityRecognition.instance;
  List<StreamSubscription>? _subscriptions;

  @override
  Future<bool> onRequest() async {
    final permission = await _recognizer.requestPermission();
    return (permission == ActivityPermission.GRANTED);
  }

  @override
  Future<bool> onCheck() async {
    final permission = await _recognizer.checkPermission();
    return (permission == ActivityPermission.GRANTED);
  }

  @override
  void onStart() {
    super.onStart();
    dev.log('Start collection', name: _log);

    _subscriptions ??= [
      _recognizer.activityStream.listen(onData, onError: onError),
      Pedometer.pedestrianStatusStream.listen(onData, onError: onError),
      Pedometer.stepCountStream.listen(onData, onError: onError),
    ];
  }

  @override
  void onData(data) async {
    super.onData(data);
    if (data is Activity) {
      Activity activity = data;
      final item = ActivityEvent.fromMap(activity.toJson());

      // Upload item to firebase
      FirebaseService.shared
          .upload(path: 'health/activity', map: item.toMap())
          .onError(onError);
    } else if (data is StepCount) {
      StepCount stepCount = data;
      final walking = WalkingEvent(
          stepCount: stepCount.steps, dateTime: stepCount.timeStamp);

      // Upload item to firebase
      FirebaseService.shared
          .upload(path: 'health/walking', map: walking.toMap())
          .onError(onError);
    } else if (data is PedestrianStatus) {
      PedestrianStatus pedestrianStatus = data;
      dev.log(pedestrianStatus.toString(), name: _log);
      final status = WalkingStatus(
          type: WalkingType.values
              .firstWhere((v) => v.toString() == pedestrianStatus.status),
          dateTime: pedestrianStatus.timeStamp);

      // Upload item to firebase
      FirebaseService.shared
          .upload(path: 'health/walking_status', map: status.toMap())
          .onError(onError);
    }
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
