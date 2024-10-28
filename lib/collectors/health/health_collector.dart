import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:pedometer/pedometer.dart';

import '../../common/firebase_service.dart';
import '../../models/collector.dart';

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
  void onCollectStart() {
    super.onCollectStart();
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

    // Upload item to firebase
    if (data is Activity) {
      final activity = data;
      FirebaseService.shared
          .upload(path: 'health/activity', map: activity.toJson())
          .onError(onError);
    } else if (data is StepCount) {
      final stepCount = data;
      final map = {'stepCount': stepCount.steps};
      FirebaseService.shared
          .upload(path: 'health/step_count', map: map)
          .onError(onError);
    } else if (data is PedestrianStatus) {
      final status = data;
      final map = {'status': status.status};
      FirebaseService.shared
          .upload(path: 'health/pedestrian_status', map: map)
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
