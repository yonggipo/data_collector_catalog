import 'dart:async';
import 'dart:developer' as dev;
import 'dart:isolate';

import 'package:data_collector_catalog/collectors/app_usage/app_usage_collector.dart';
import 'package:data_collector_catalog/collectors/directory/directory_collector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'background_service.dart';
import 'collectors/battery/battery_collector.dart';
import 'collectors/call_log/call_log_collector.dart';
import 'collectors/enviroment/enviroment_collector.dart';
import 'collectors/health/health_collector.dart';
import 'collectors/inertial/Inertial_collector.dart';
import 'collectors/location/location_collector.dart';
import 'collectors/network/network_collector.dart';
import 'collectors/notification/notification_collector.dart';
import 'collectors/screen_state/screen_state_collector.dart';
import 'collectors/volume/volume_collector.dart';
import 'common/device.dart';
import 'common/firebase_service.dart';
import 'common/local_db_service.dart';
import 'firebase_options.dart';
import 'models/collector.dart';
import 'screens/permission_state_screen.dart';
import 'screens/user_inlet_screen.dart';

const _log = 'Initialize';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Device().checkAndroidVersion();

  try {
    await Hive.initFlutter();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseService.shared.clear();
    // Initialize notification plugin first
    await initializeNotificationPlugin();
    await initializeBackgroundService();
  } catch (e) {
    dev.log('error: $e', name: _log);
  }

  final isUserIn = await LocalDbService.isUserIn();
  final home = isUserIn ? PermissionStateScreen() : UserInletScreen();
  runApp(MaterialApp(home: home));
}

final List<Collector2> collectors = [
  InertialCollector(),
  LocationCollector(),
  EnviromentCollector(),
  NetworkCollector(),
  HealthCollector(),
  VolumeCollector(),
  ScreenStateCollector(),
  BatteryCollector(),
  CallLogCollector(),
  NotificationCollector(),
  DirectoryCollector(),
  AppUsageCollector(),
];

Future<void> onCollect() async {
  dev.log('${Isolate.current.hashCode} Start collecting in background service',
      name: _log);
  for (var e in collectors) {
    e.start();
  }
}
