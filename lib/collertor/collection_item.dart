// ignore: unused_import
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collectors/lux_event/light_collector.dart';
import 'package:data_collector_catalog/collertor/permission_list_ext.dart';
import 'package:data_collector_catalog/collectors/calendar/calendar_collector.dart';
import 'package:data_collector_catalog/collectors/health/health_collector.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/constants.dart';
import '../common/device.dart';
import '../collectors/audio/audio_collector.dart';
import 'collector.dart';
import 'collector_state.dart';
import 'sampling_interval.dart';
import 'collector_premission_state.dart';

enum CollectionItem {
  acceleration,
  angularVelocity,
  magneticFieldStrength,

  microphone,
  health,
  calendar,
  light,
}

extension CollectionItemGetters on CollectionItem {
  // ignore: unused_field
  static const _log = 'CollectionItemGetters';

  String get name {
    switch (this) {
      case CollectionItem.acceleration:
        return '가속도';
      case CollectionItem.angularVelocity:
        return '각속도';
      case CollectionItem.magneticFieldStrength:
        return '자기장 강도';

      case CollectionItem.microphone:
        return '오디오';
      case CollectionItem.health:
        return '건강(걸음수, 활동 상태 및 시간)';
      case CollectionItem.calendar:
        return '켈린더';
      case CollectionItem.light:
        return '빛';
    }
  }

  String get unit {
    switch (this) {
      case CollectionItem.acceleration:
        return '조도 m/s²';
      case CollectionItem.angularVelocity:
        return '각속도 도/초(°/s)';
      case CollectionItem.magneticFieldStrength:
        return '자기장 세기 μT';
      case CollectionItem.microphone:
        return 'audio m4a';
      case CollectionItem.health:
        return '걸음수, 활동 상태 및 시간';
      case CollectionItem.calendar:
        return '일정';
      case CollectionItem.light:
        return '조도 lumen';
    }
  }

  Stream<Map<String, dynamic>?> get dataStream {
    switch (this) {
      case CollectionItem.microphone:
        return FlutterBackgroundService().on(Constants.stream.audio);
      default:
        return Stream.empty();
    }
  }

  Stream<CollectorState> get collectorStateStream {
    if (collector == null) {
      return Stream.value(CollectorState.waitingPermission);
    } else {
      return collector!.isCollectingStream.map((isCollecting) {
        if (isCollecting == null) {
          return CollectorState.waitingPermission;
        } else {
          return isCollecting
              ? CollectorState.collecting
              : CollectorState.waiting;
        }
      });
    }
  }

  Collector? get collector {
    switch (this) {
      case CollectionItem.microphone:
        return AudioCollector();
      case CollectionItem.health:
        return HealthCollector();
      case CollectionItem.calendar:
        return CalendarCollector();
      case CollectionItem.light:
        return LightCollector();
      default:
        return null;
    }
  }

  SamplingInterval get samplingInterval {
    switch (this) {
      case CollectionItem.health:
        return SamplingInterval.event;
      case CollectionItem.calendar:
        return SamplingInterval.event;
      case CollectionItem.light:
        return SamplingInterval.event;
      default:
        return SamplingInterval.min15;
    }
  }

  List<Permission> get permissions {
    switch (this) {
      case CollectionItem.microphone:
        final android9 = 28;
        final isAboveAndroid9 =
            ((Device.shared.androidVersion ?? 28) > android9);
        return isAboveAndroid9
            ? [Permission.microphone]
            : [Permission.microphone, Permission.storage];
      case CollectionItem.calendar:
        return [Permission.calendarFullAccess];
      default:
        return [];
    }
  }

  // Status of the required permissions in the collector
  Future<CollectorPermissionState> get permissionStatus async {
    switch (this) {
      case CollectionItem.health:
        if (collector is HealthCollector) {
          final health = collector as HealthCollector;
          final isGranted = await health.isGranted();
          return isGranted
              ? CollectorPermissionState.granted
              : CollectorPermissionState.required;
        } else {
          return CollectorPermissionState.required;
        }
      default:
        if (permissions.isEmpty) {
          return CollectorPermissionState.none;
        }

        final isGranted = await permissions.areGranted;
        return isGranted
            ? CollectorPermissionState.granted
            : CollectorPermissionState.required;
    }
  }
  
  Future<bool> requestRequired() async {
    switch (this) {
      case CollectionItem.health:
        final health = collector as HealthCollector;
        return await health.onRequest() ?? false;
      default:
        return await permissions.requestRequired();
    }
  }
}
