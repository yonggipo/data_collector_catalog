import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:data_collector_catalog/models/collector_premission_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'catalog_app.dart';
import 'common/firebase_service.dart';
import 'models/collection_item.dart';
import 'models/collector.dart';
import 'common/device.dart';
import 'firebase_options.dart';

const _notificationChannelId = 'catalog_notification_channel_id';
const _foregroundServiceNotificationId = 888;

const _firebaseLog = 'firebase';
const _backgroundServiceLog = 'backgroundService';
const _initialCollectionLog = 'initialCollection';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final _ = Device().checkAndroidVersion();
  await _setupFirebase();
  await _setupBackgroundService();
  runApp(const CatalogApp());
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
      onStart: onStart,
      isForegroundMode: true,
      notificationChannelId: _notificationChannelId,
      initialNotificationTitle: 'title',
      initialNotificationContent: 'content',
      foregroundServiceNotificationId: _foregroundServiceNotificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );

  startCollectors();
  // service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // DartPluginRegistrant.ensureInitialized();
  dev.log('onStart', name: _backgroundServiceLog);
  // await Hive.initFlutter();
  // var box = await Hive.openBox("user");

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // OPTIONAL when use custom notification
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
}

Future<void> startCollectors() async {
  var items = CollectionItem.values;

  List<(CollectionItem, Collector)> collectors = [];
  for (var item in items) {
    final status = await item.permissionStatus;
    if (status != CollectorPermissionState.required) {
      final collector = item.collector;
      if (collector != null) {
        collectors.add((item, collector));
      }
    }
  }

  dev.log('Granted controller count: ${collectors.length}',
      name: _initialCollectionLog);

  for (var (item, collector) in collectors) {
    collector.start(item);
  }
}
