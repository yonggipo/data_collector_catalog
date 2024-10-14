import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_background_service/flutter_background_service.dart';

import '../../collertor/sampling_interval.dart';
import '../../collertor/collector.dart';
import 'noti_event.dart';
import 'noti_event_detector.dart';

final class NotiEventDetectorUtil extends Collector {
  NotiEventDetectorUtil._() : super();
  static final NotiEventDetectorUtil shared = NotiEventDetectorUtil._();
  factory NotiEventDetectorUtil() => shared;
  // Dio dio = Dio();
  List<NotiEvent> envents = [];
  StreamSubscription? _subscription;
  ServiceInstance? service;

  @override
  SamplingInterval samplingInterval = SamplingInterval.event;

  @override
  void onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onData(object) async {
    dev.log('[Noti]: event: ${object.toString()}');

    // push to firebase
    final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    // final event = LuxEvent(lux: object, timeStamp: timeStamp);
    // await Firebase.initializeApp();
    // final ref = FirebaseDatabase.instance.ref();
    // await ref.child("lux").push().set(event.toJson()).catchError((e) {
    // dev.log('[✗] error2: $e');
    // });

    // send to ui
    // service?.invoke(
    //   'update',
    // );

    // save to json file
    // FileManager().toJsonFile(event.toJson Function() Function );
    // luxJson.clear();
    // luxValues.clear();
    // map.clear();
  }

  @override
  void onError(Object error) {
    dev.log('[Noti] error: $error');
  }

  @override
  Future<bool> onRequest() async {
    if (await NotiEventDetector.hasP()) {
      return true;
    } else {
      return NotiEventDetector.requestP();
    }
  }

  @override
  void onStart() async {
    dev.log('start listening noti event');

    final hasP = await onRequest();
    if (hasP) {
      _subscription =
          NotiEventDetector.notiStream.listen(onData, onError: onError);
    } else {
      dev.log('[noti] hasP: false');
    }
  }

  @override
  Future<void> upload(String filePath, dynamic file) async {
    // var formData = FormData.fromMap({
    //   'Lux': await MultipartFile.fromFile(filePath,
    //       filename: 'Lux.json', contentType: MediaType('application', 'json')),
    //   'pin': pin, // Add the pin form field
    // });
    // var options = Options(headers: {'Content-Type': 'multipart/form-data'});
    // var response =
    //     await dio.post("$subUrl/app/upload", data: formData, options: options);
    // if (response.statusCode == 200) {
    //   dev.log('File uploaded successfully!');
    //   file.deleteSync();
    // } else {
    //   dev.log('[✗ Noti] network: ${response.statusCode}');
    // }
  }

  @override
  void onLoad() {
    // TODO: implement onLoad
  }
}
