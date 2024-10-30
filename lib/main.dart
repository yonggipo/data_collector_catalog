import 'dart:async';
import 'dart:developer' as dev;
import 'dart:isolate';

import 'package:cron/cron.dart';
import 'package:data_collector_catalog/background_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'collectors/sensor/Inertial_collector.dart';
import 'common/device.dart';
import 'common/firebase_service.dart';
import 'common/local_db_service.dart';
import 'firebase_options.dart';
import 'models/collection_item.dart';
import 'models/collector.dart';
import 'models/collector_premission_state.dart';
import 'models/sampling_interval.dart';
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

final List<Collector2> collectors = [InertialCollector()];
Future<void> onCollect() async {
  dev.log('${Isolate.current.hashCode} Start collecting in background service',
      name: _log);
  for (var e in collectors) {
    e.start();
  }
}
