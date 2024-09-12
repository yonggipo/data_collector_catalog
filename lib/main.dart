import 'package:data_collector_catalog/light_sensor_util.dart';
import 'package:data_collector_catalog/microphone_util.dart';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';

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
  @override
  void initState() {
    super.initState();

    // MicrophoneUtil().startListener();
    LightSensorUtil.shared.start();
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
}
