// ignore: unused_import
import 'dart:developer' as dev;

import 'package:data_collector_catalog/models/item.dart';
import 'package:data_collector_catalog/models/sampling_interval.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../../models/collector.dart';

class LocationCollector extends Collector {
  LocationCollector._() : super();
  static final shared = LocationCollector._();
  factory LocationCollector() => shared;

  // ignore: unused_field
  static const _log = 'LocationCollector';

  @override
  Item get item => Item.location;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.min15;

  @override
  void onCollect() async {
    final hasPermission = await item.hasPermission;
    if (!hasPermission) {
      sendMessageToMainPort(false);
      sendMessageToMainPort('Permission is required');
      return;
    }

    final isServiceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      sendMessageToMainPort(false);
      sendMessageToMainPort('Location service is required');
      return;
    }

    sendMessageToMainPort(true);
    final setting = geo.AndroidSettings(accuracy: geo.LocationAccuracy.medium);
    final position = await geo.Geolocator.getCurrentPosition(
      locationSettings: setting,
    );

    sendMessageToMainPort(<String, dynamic>{
      'location': <String, dynamic>{
        'latitude': position.latitude,
        'longitude': position.longitude,
        'altitude': position.altitude,
        'accuracy': position.accuracy,
        'speed': position.speed
      },
    });
    sendMessageToMainPort(false);
  }
}
