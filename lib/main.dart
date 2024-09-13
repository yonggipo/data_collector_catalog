import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/sensors/notification_util.dart';
import 'package:flutter/material.dart';

import 'sensors/light_sensor_util.dart';
import 'sensors/microphone_util.dart';
import 'sensors/sampling_interval.dart';
import 'sensors/sensor_util.dart';

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
      ),
    );
  }

  // MARK: - private

  void setupSensor() {
    sensors = [
      MicrophoneUtil.shared,
      LightSensorUtil.shared,
      NotificationUtil.shared,
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
