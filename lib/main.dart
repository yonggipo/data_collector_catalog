import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:cron/cron.dart';
import 'package:data_collector_catalog/collect_state_screen.dart';
import 'package:data_collector_catalog/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'keystroke/focus_time_recorder.dart';
import 'sampling_interval.dart';
import 'sensor_util.dart';
import 'sensors/keystroke_logger.dart';
import 'sensors/light_sensor_util.dart';
import 'sensors/microphone_util.dart';
import 'sensors/notification_util.dart';

// MARK: Main
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setupFirebase();
  runApp(const MyApp());
}

// MARK: - Firebase
Future<void> _setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .catchError((e) => dev.log('[✘ firebase] error: $e'));
}

// MARK: - Backgoround Service

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  Cron cronJob = Cron();

  const channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  final plugin = FlutterLocalNotificationsPlugin();
  if (Platform.isAndroid) {
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      isForegroundMode: true,
      notificationChannelId: 'notification_channel_id',
      initialNotificationTitle: 'title',
      initialNotificationContent: 'content',
      foregroundServiceNotificationId: 11223344,
    ),
    iosConfiguration: IosConfiguration(),
  );
  service.startService();

  // cronJob.schedule(Schedule.parse('0 */3 * * *'), () async {
  //   // var result = await HealthConnectFactory.isAvailable();
  //   await healthDataSender.healthDataCall(service);
  // });
}

@pragma('vm:entry-point')
void onBackgroundServiceStart(ServiceInstance service) {
  print('onBackgroundServiceStart');
}
