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
  void collect() async {
    sendMessageToPort(true);

    final setting = geo.AndroidSettings(accuracy: geo.LocationAccuracy.medium);
    final position = await geo.Geolocator.getCurrentPosition(
      locationSettings: setting,
    );

    sendMessageToPort(<String, dynamic>{
      'location': <String, dynamic>{
        'latitude': position.latitude,
        'longitude': position.longitude,
        'altitude': position.altitude,
        'accuracy': position.accuracy,
        'speed': position.speed
      },
    });
    sendMessageToPort(false);
  }
}
