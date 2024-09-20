import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import 'keystroke/focus_time_recorder.dart';
import 'sampling_interval.dart';
import 'sensor_util.dart';
import 'sensors/keystroke_logger.dart';
import 'sensors/light_sensor_util.dart';
import 'sensors/microphone_util.dart';
import 'sensors/notification_util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State {
  List<SensorUtil> sensors = [];

  @override
  void initState() {
    super.initState();

    setupSensor();
    startMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Data Collector Catalog'),
        ),
        body: const FocusTimeRecorder(),
      ),
    );
  }

  // MARK: - private

  void setupSensor() {
    sensors = [
      MicrophoneUtil.shared,
      LightSensorUtil.shared,
      NotificationUtil.shared,
      KeystrokeLogger.shared,
    ];
  }

  void startMonitoring() {
    dev.log('start monitoring.. sensors: ${sensors.length}');
    for (var sensor in sensors) {
      sensor.start();
      if (sensor.samplingInterval != SamplingInterval.event) {
        Timer.periodic(sensor.samplingInterval.duration, (Timer timer) {
          sensor.start();
        });
      }
    }
  }
}
