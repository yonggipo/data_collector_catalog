import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui';

import 'package:cron/cron.dart';
import 'package:data_collector_catalog/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device.dart';
import 'catalog_app.dart';
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

// MARK: Main
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final _ = Device().checkAndroidVersion();
  await Permission.location.request();
  await Permission.notification.request();

  await _setupFirebase();
  // await _setupBackgroundService();
  runApp(const CatalogApp());
}

// MARK: - Firebase
Future<void> _setupFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    dev.log('[firebase] error: $e');
  }
}

Future<void> _setupBackgroundService() async {
  // final service = FlutterBackgroundService();
  Cron cronJob = Cron();

  const channel = AndroidNotificationChannel(
    'my_foreground',
    'channel_name',
    description: 'channel_description',
    importance: Importance.max,
  );

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_bg_service_small'),
    ),
  );

  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onBackgroundServiceStart,
//       isForegroundMode: true,
//       notificationChannelId: 'my_foreground',
//       initialNotificationTitle: 'initial_title',
//       initialNotificationContent: 'initial_content',
//       foregroundServiceTypes: [
//         AndroidForegroundType.location,
//         AndroidForegroundType.shortService
//       ],
//     ),
//     iosConfiguration: IosConfiguration(
//       onForeground: onBackgroundServiceStart,
//     ),
//   );

//   service.startService();

//   // cronJob.schedule(Schedule.parse('0 */3 * * *'), () async {
//   //   // var result = await HealthConnectFactory.isAvailable();
//   //   await healthDataSender.healthDataCall(service);
//   // });
}

// @pragma('vm:entry-point')
// void onBackgroundServiceStart(ServiceInstance service) {
//   DartPluginRegistrant.ensureInitialized();
//   final plugin = FlutterLocalNotificationsPlugin();
//   print('onBackgroundServiceStart');

//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });

//   Timer.periodic(const Duration(seconds: 1), (timer) async {
//     if (service is AndroidServiceInstance) {
//       if (await service.isForegroundService()) {
//         plugin.show(
//           888,
//           'COOL SERVICE',
//           'Awesome ${DateTime.now()}',
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'my_foreground',
//               'MY FOREGROUND SERVICE',
//               icon: 'ic_bg_service_small',
//               ongoing: true,
//             ),
//           ),
//         );
//       }

//       // if you don't using custom notification, uncomment this
//       service.setForegroundNotificationInfo(
//         title: "My App Service",
//         content: "Updated at ${DateTime.now()}",
//       );
//     }
//   });
// }
