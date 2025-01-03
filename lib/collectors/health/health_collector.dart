import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:pedometer/pedometer.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

class HealthCollector extends Collector {
  HealthCollector._() : super();
  static final shared = HealthCollector._();
  factory HealthCollector() => shared;

  static const _log = 'HealthCollector';

  final _recognizer = FlutterActivityRecognition.instance;
  List<StreamSubscription>? _subscriptions;

  @override
  Item get item => Item.health;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.event;

  @override
  void onCollect() async {
    super.onCollect();

    _subscriptions ??= [
      _recognizer.activityStream.listen(onData, onError: onError),
      Pedometer.pedestrianStatusStream.listen(onData, onError: onError),
      Pedometer.stepCountStream.listen(onData, onError: onError),
    ];
  }

  void onData(dynamic data) {
    if (data is Activity) {
      final activity = data;
      sendMessageToMainPort(
          <String, dynamic>{'physical_activity': activity.toJson()});
      sendMessageToMainPort(true);
    } else if (data is StepCount) {
      final stepCount = data;
      sendMessageToMainPort(<String, dynamic>{
        'step_count': <String, dynamic>{'step': stepCount.steps}
      });
      sendMessageToMainPort(true);
    } else if (data is PedestrianStatus) {
      final status = data;
      sendMessageToMainPort(<String, dynamic>{
        'pedestrian_status': <String, dynamic>{'status': status.status}
      });
      sendMessageToMainPort(true);
    }
  }

  FutureOr<void> onError(Object error, StackTrace stackTrace) async {
    dev.log('Error occurred: $error', name: _log);
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
