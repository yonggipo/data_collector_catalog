// ignore: unused_import
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collectors/light/light_collector.dart';
import 'package:data_collector_catalog/collectors/notification/notification_collector.dart';
import 'package:data_collector_catalog/models/permission_list_ext.dart';
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
  notification,
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
      case CollectionItem.notification:
        return '알림';
    }
  }

  String get description {
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
      case CollectionItem.notification:
        return '앱, 메세지, 시간, 클릭 여부';
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
      case CollectionItem.notification:
        return NotificationCollector();
      default:
        return null;
    }
  }

  SamplingInterval get samplingInterval {
    switch (this) {
      case CollectionItem.microphone:
        return SamplingInterval.min15;
      case CollectionItem.health:
        return SamplingInterval.event;
      case CollectionItem.calendar:
        return SamplingInterval.event;
      case CollectionItem.light:
        return SamplingInterval.event;
      case CollectionItem.notification:
        return SamplingInterval.event;
      default:
        return SamplingInterval.min15;
    }
  }

  List<Permission> get permissions {
    switch (this) {
      case CollectionItem.microphone:
        return Device.shared.isAboveAndroid9
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
    final isNeedCustomPermission = [
      CollectionItem.health,
      CollectionItem.notification,
    ].contains(this);

    if (isNeedCustomPermission) {
      return (await collector?.onCheck() ?? false)
          ? CollectorPermissionState.granted
          : CollectorPermissionState.required;
    } else {
      if (permissions.isEmpty) {
        return CollectorPermissionState.none;
      }
      return (await permissions.areGranted)
          ? CollectorPermissionState.granted
          : CollectorPermissionState.required;
    }
  }

  Future<bool> requestRequired() async {
    final isNeedCustomPermission = [
      CollectionItem.health,
      CollectionItem.notification,
    ].contains(this);

    if (isNeedCustomPermission) {
      return await collector?.onRequest() ?? false;
    } else {
      return await permissions.requestRequired();
    }
  }
}
