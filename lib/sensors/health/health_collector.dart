import 'dart:async';
import 'dart:developer' as dev;

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
    dev.log('Start collection..', name: _log);

    _subscription =
        recognizer.activityStream.handleError(onError).listen(onData);
  }

  @override
  void onData(object) {
    super.onData(object);
    if (object is Activity) {
      Activity activity = object;
      dev.log(activity.toJson().toString(), name: _log);
    }
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
