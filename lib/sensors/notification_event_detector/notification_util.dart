// import 'dart:async';
// import 'dart:developer' as dev;

// import 'package:data_collector_catalog/model/file_manager.dart';
// import 'package:data_collector_catalog/sensors/light_sensor_util/lux_event.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_notification_listener/flutter_notification_listener.dart';

// import '../../model/sampling_interval.dart';
// import '../../sensor_util.dart';

// final class NotificationUtil implements SensorUtil {
//   static final NotificationUtil shared = NotificationUtil._();
//   NotificationUtil._();
//   factory NotificationUtil() => shared;

//   // MARK: - Properties
//   // Dio dio = Dio();
//   List<NotificationEvent> envents = [];
//   StreamSubscription? _subscription;
//   ServiceInstance? service;
//   // Map<String, Map<String, dynamic>> map = {};
//   // final Map<String, Map<String, dynamic>> eventJson = {};
 
//   @override
//   SamplingInterval samplingInterval = SamplingInterval.event;

//   @override
//   void cancel() {
//     _subscription?.cancel();
//     _subscription = null;
//   }

//   @override
//   void onData(object) async {
//     dev.log('[✓ Noti]: events: ${object.toString()}');

//     // push to firebase
//     final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
//     // final event = LuxEvent(lux: object, timeStamp: timeStamp);
//     // await Firebase.initializeApp();
//     // final ref = FirebaseDatabase.instance.ref();
//     // await ref.child("lux").push().set(event.toJson()).catchError((e) {
//     // dev.log('[✗] error2: $e');
//     // });

//     // send to ui
//     // service?.invoke(
//     //   'update',
//     // );

//     // save to json file
//     // FileManager().toJsonFile(event.toJson Function() Function );
//     // luxJson.clear();
//     // luxValues.clear();
//     // map.clear();
//   }

//   @override
//   void onError(Object error) {
//     dev.log('[✗ Noti] error: $error');
//   }

//   /// request notification permission
//   @override
//   Future<bool> requestPermission() async {
//     await NotificationsListener.openPermissionSettings();
//     return NotificationsListener.hasPermission.then((hasP) {
//       return hasP ?? false;
//     });
//   }

//   @override
//   void start() async {
//     dev.log('start listening noti event');
//     // Listener init
//     NotificationsListener.initialize();
//     NotificationsListener.receivePort?.listen(onData, onError: onError);

//     var hasPermission = await NotificationsListener.hasPermission ?? false;
//     if (!hasPermission) {
//       NotificationsListener.openPermissionSettings();
//       return;
//     }

//     var isRunning = await NotificationsListener.isRunning ?? false;
//     if (!isRunning) {
//       await NotificationsListener.startService();
//     }
//   }

//   @override
//   Future<void> upload(String filePath, dynamic file) async {
//     // var formData = FormData.fromMap({
//     //   'Lux': await MultipartFile.fromFile(filePath,
//     //       filename: 'Lux.json', contentType: MediaType('application', 'json')),
//     //   'pin': pin, // Add the pin form field
//     // });
//     // var options = Options(headers: {'Content-Type': 'multipart/form-data'});
//     // var response =
//     //     await dio.post("$subUrl/app/upload", data: formData, options: options);
//     // if (response.statusCode == 200) {
//     //   dev.log('File uploaded successfully!');
//     //   file.deleteSync();
//     // } else {
//     //   dev.log('[✗ Noti] network: ${response.statusCode}');
//     // }
//   }
  
//   @override
//   void onLoad() {
//     // TODO: implement onLoad
//   }
// }
