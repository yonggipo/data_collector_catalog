import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/keystroke/focus_time_recorder.dart';
import 'package:data_collector_catalog/model/file_manager.dart';
import 'package:data_collector_catalog/model/sampling_interval.dart';
// import 'package:data_collector_catalog/sensors/keystroke_logger.dart';
// import 'package:data_collector_catalog/sensors/lux_event/light_sensor_util.dart';
import 'package:data_collector_catalog/sensors/noti_event/noti_event_detector_util.dart';
import 'package:flutter/material.dart';

import 'sensor_util.dart';
import 'sensors/audio_event/microphone_util.dart';

// final cron = Cron();
// cron.schedule(Schedule.parse('*/4 * * * *'), () async {
//

//   await record.start(recordConfig, path: 'aFullPath/myFile.m4a');
//   dev.log("[kane-audio]: 오디오 녹음 시작 ${DateTime.now().toString()}");

//   await Future.delayed(Duration(minutes: 1));
//   dev.log("[kane-audio]: 오디오 녹음 종료 ${DateTime.now().toString()}");
//   dev.log("[kane-audio]: 3분 대기");
//   await Future.delayed(Duration(minutes: 3));
//   dev.log("[kane-audio]: 다음 사이클 시작");
// })

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
      // LightSensorUtil(),
      NotiEventDetectorUtil(),
      MicrophoneUtil()

      //MicrophoneUtil(),

      // background type 변경

      // KeystrokeLogger(),
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
