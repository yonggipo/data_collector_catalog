import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:cron/cron.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'catalog_app.dart';
import 'common/device.dart';
import 'firebase_options.dart';

const _notificationChannelId = 'catalog_notification_channel_id';
const _foregroundServiceNotificationId = 888;
const _firebaseLogName = 'firebase';
// ignore: unused_element
const _backgroundServiceLogName = 'backgroundService';

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
  } catch (e) {
    dev.log('error: $e', name: _firebaseLogName);
  }
}

Future<void> _setupBackgroundService() async {
  final service = FlutterBackgroundService();
  Cron cron = Cron();

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

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // DartPluginRegistrant.ensureInitialized();
  dev.log('onStart', name: _backgroundServiceLogName);
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

// sensors = [
//   // LightSensorUtil(),
//   NotiEventDetectorUtil(),
//   MicrophoneUtil()
//   //MicrophoneUtil(),
//   // background type 변경
//   // KeystrokeLogger(),
// ];

// void startMonitoring() {
//   dev.log('start monitoring.. sensors: ${sensors.length}');
//   for (var sensor in sensors) {
//     sensor.start();
//     if (sensor.samplingInterval != SamplingInterval.event) {
//       Timer.periodic(sensor.samplingInterval.duration, (Timer timer) {
//         sensor.start();
//       });
//     }
//   }
// }
