import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/common/firebase_service.dart';
import 'package:data_collector_catalog/common/local_db_service.dart';
import 'package:geolocator/geolocator.dart' as geo;
// import 'package:location/location.dart';

import '../../models/collector.dart';

class LocationCollector extends Collector {
  LocationCollector._() : super();
  static final shared = LocationCollector._();
  factory LocationCollector() => shared;

  // ignore: unused_field
  static const _log = 'LocationCollector';

  @override
  void onCollectStart() async {
    super.onCollectStart();
    dev.log('Start collection', name: _log);

    final setting = geo.AndroidSettings(accuracy: geo.LocationAccuracy.medium);
    final position =
        await geo.Geolocator.getCurrentPosition(locationSettings: setting);

    LocalDbService.sendMessageToSavePort('location', {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'altitude': position.altitude,
      'accuracy': position.accuracy,
      'speed': position.speed
    });

    // Call to calculate the remaining time
    super.onCancel();
  }
}
