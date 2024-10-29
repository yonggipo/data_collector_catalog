import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/background_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'common/device.dart';
import 'common/firebase_service.dart';
import 'common/local_db_service.dart';
import 'firebase_options.dart';
import 'models/collection_item.dart';
import 'models/collector.dart';
import 'models/collector_premission_state.dart';
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

Future<void> onCollect() async {
  dev.log('Did \'startollecting\' has been called', name: _log);
  dev.log('Start collecting', name: _log);

  final items = [
    // CollectionItem.calendar,
    CollectionItem.sensorEvnets
  ]; // CollectionItem.values;
  dev.log('Collectors: ${items.map((item) => item.name)}', name: _log);

  final collectors = [];
  for (var item in items) {
    final status = await item.permissionStatus;
    if (status.isValid) collectors.add((item, item.collector));
  }

  for (var (item, collector) in collectors) {
    if (collector is Collector) {
      final casted = collector;
      casted.start(item);
    }
  }
}
