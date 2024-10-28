import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui';

import 'package:data_collector_catalog/collectors/calendar/calendar_collector.dart';
import 'package:data_collector_catalog/models/collection_item.dart';
import 'package:data_collector_catalog/models/collector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'common/device.dart';
import 'common/firebase_service.dart';
import 'common/local_db_service.dart';
import 'firebase_options.dart';
import 'models/collector_premission_state.dart';
import 'screens/permission_state_screen.dart';
import 'screens/user_inlet_screen.dart';

const _notificationChannelId = 'catalog_notification_channel_id';
const _foregroundServiceNotificationId = 888;

const _firebaseLog = 'firebase';
const _backgroundServiceLog = 'backgroundService';
const _initialCollectionLog = 'initialCollection';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final _ = Device().checkAndroidVersion();
  await Hive.initFlutter();
  await _setupFirebase();
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

Future<void> _setupFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseService.shared.clear();
  } catch (e) {
    dev.log('error: $e', name: _firebaseLog);
  }
}

Future<void> _setupBackgroundService() async {
  final service = FlutterBackgroundService();

  const channel = AndroidNotificationChannel(
    _notificationChannelId,
    'data_collector_catalog',
    description: 'This channel is used for android foreground service',
    importance: Importance.max,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: true,
      notificationChannelId: _notificationChannelId,
      initialNotificationTitle: 'title',
      initialNotificationContent: 'content',
      foregroundServiceNotificationId: _foregroundServiceNotificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // WidgetsFlutterBinding.ensureInitialized();
  // DartPluginRegistrant.ensureInitialized();

  // CalendarCollector().onStart();

  dev.log('onStart', name: _backgroundServiceLog);

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      // OPTIONAL for use custom notification
      flutterLocalNotificationsPlugin.show(
        _foregroundServiceNotificationId,
        'title',
        'body',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _notificationChannelId,
            'data_collector_catalog',
            icon: 'ic_bg_service_small',
            ongoing: true,
          ),
        ),
      );

      // if you don't using custom notification, uncomment this
      service.setForegroundNotificationInfo(
        title: "title",
        content: "content",
      );
    }
  }

  await startCollectors();
}

Future<void> startCollectors() async {
  final items = [
    // CollectionItem.calendar,
    CollectionItem.sensorEvnets
  ]; // CollectionItem.values;

  dev.log('''Start collecting: [${items.map((item) => item.name)}]
  ''', name: _backgroundServiceLog);

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
