import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/common/firebase_service.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';

import '../../models/collector.dart';

class LocationCollector extends Collector {
  LocationCollector._() : super();
  static final shared = LocationCollector._();
  factory LocationCollector() => shared;

  // ignore: unused_field
  static const _log = 'LocationCollector';

  final location = Location();

  @override
  Future<bool> onCheck() async {
    super.onCheck();
    return await location.serviceEnabled();
  }

  @override
  Future<bool> onRequest() async {
    super.onRequest();
    final isServiceActive = await location.requestService();
    dev.log('isServiceActive: $isServiceActive', name: _log);
    return isServiceActive;
  }

  @override
  void onStart() async {
    super.onStart();

    final position = await geo.Geolocator.getCurrentPosition(
        locationSettings:
            geo.AndroidSettings(accuracy: geo.LocationAccuracy.low));

    // Upload item to firebase
    FirebaseService.shared.upload(path: 'location', map: {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'altitude': position.altitude,
      'timestamp': DateTime.now().toIso8601String(),
    }).onError(onError);

    // Call to calculate the remaining time
    super.onCancel();
  }
}
