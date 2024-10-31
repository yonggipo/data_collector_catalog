// Setup local notification plugin
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

const _notificationChannelId = 'catalog_channel_id';
const _notificationChannelName = 'catalog_channel_name';
const _notificationId = 1312;
const _notificationPluginLog = 'notificationPlugin';
const _backgroundServiceLog = 'backgroundService';

Future<void> initializeNotificationPlugin() async {
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
    dev.log('Error occurred: $e', name: _notificationPluginLog);
  }
}

// Setup background service
Future<void> initializeBackgroundService() async {
  try {
    final service = FlutterBackgroundService();
    final isConfigured = await service.configure(
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
    dev.log('${Isolate.current.hashCode} Is service configured: $isConfigured',
        name: _backgroundServiceLog);
    service.isRunning().then((isRunning) {
      dev.log('${Isolate.current.hashCode} Is service running: $isRunning',
          name: _backgroundServiceLog);
    });
  } catch (e) {
    dev.log('Error occurred: $e', name: _backgroundServiceLog);
  }
}

// When the background service is ready and invoked, it runs
@pragma('vm:entry-point')
void _onBackgroundServiceStart(ServiceInstance service) async {
  dev.log('${Isolate.current.hashCode} Start background service',
      name: _backgroundServiceLog);
  // DartPluginRegistrant.ensureInitialized();
  service.on('stopService').listen((event) => service.stopSelf());

  if (service is AndroidServiceInstance) {
    service
        .on('setAsForeground')
        .listen((event) => service.setAsForegroundService());
    service
        .on('setAsBackground')
        .listen((event) => service.setAsBackgroundService());

    final isForeground = await service.isForegroundService();
    if (isForeground) {
      dev.log('[$Isolate.current.hashCode} Service is foreground mode',
          name: _backgroundServiceLog);
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Updated at ${DateTime.now()}",
      );
    }
  }

  onCollect();
}
