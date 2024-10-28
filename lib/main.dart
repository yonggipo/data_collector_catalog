import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

const _notificationChannelId = 'catalog_channel_id';
const _notificationChannelName = 'catalog_channel_name';
const _notificationId = 1312;

const _firebaseLog = 'firebase';
const _localNotiPluginLog = 'localNotiPlugin';
const _backgroundServiceLog = 'backgroundService';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final _ = Device().checkAndroidVersion();
  await Hive.initFlutter();
  await _setupFirebase();
  await _setupLocalNotificationPlugin();
  await _setupBackgroundService();

  final isUserIn = await LocalDbService.isUserIn();
  if (isUserIn) {
    runApp(const MaterialApp(
      home: PermissionStateScreen(),
    ));
  } else {
    runApp(const MaterialApp(
      home: UserInletScreen(),
    ));
  }
}

// Setup firebase
Future<void> _setupFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseService.shared.clear();
  } catch (e) {
    dev.log('error: $e', name: _firebaseLog);
  }
}

// Setup local notification plugin
Future<void> _setupLocalNotificationPlugin() async {
  try {
    const channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'This channel is used for android foreground service',
      importance: Importance.max,
    );

    final plugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS || Platform.isAndroid) {
      await plugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } catch (e) {
    dev.log('Error occurred: $e', name: _localNotiPluginLog);
  }
}

// Setup background service
Future<void> _setupBackgroundService() async {
  try {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
          autoStart: false,
          onStart: _onBackgroundServiceStart,
          isForegroundMode: true,
          initialNotificationTitle: 'title',
          initialNotificationContent: 'content',
          notificationChannelId: _notificationChannelId,
          foregroundServiceNotificationId: _notificationId,
          foregroundServiceTypes: [AndroidForegroundType.dataSync]),
      iosConfiguration: IosConfiguration(),
    );
    service.isRunning().then((isRunning) {
      dev.log('Is service running: $isRunning', name: _backgroundServiceLog);
    });
  } catch (e) {
    dev.log('Error occurred: $e', name: _backgroundServiceLog);
  }
}

// When the background service is ready and invoked, it runs
@pragma('vm:entry-point')
void _onBackgroundServiceStart(ServiceInstance service) async {
  dev.log('Start background service', name: _backgroundServiceLog);
  DartPluginRegistrant.ensureInitialized();
  service.on('stopService').listen((event) => service.stopSelf());
  service.on('stopService').listen((event) => service.stopSelf());

  if (service is AndroidServiceInstance) {
    service
        .on('setAsForeground')
        .listen((event) => service.setAsForegroundService());
    service
        .on('setAsBackground')
        .listen((event) => service.setAsBackgroundService());

    service.on('startCollect').listen((event) async {
      dev.log('Did \'startollecting\' has been called',
          name: _backgroundServiceLog);
      await _onCollect();
    });
  } else {
    dev.log('Is not android service instance', name: _backgroundServiceLog);
  }
}

// Collect collectible items
Future<void> _onCollect() async {
  dev.log('Start collecting', name: _backgroundServiceLog);

  final items = [
    // CollectionItem.calendar,
    CollectionItem.sensorEvnets
  ]; // CollectionItem.values;
  dev.log('Collectors: ${items.map((item) => item.name)}',
      name: _backgroundServiceLog);

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
