// ignore: unused_import
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collectors/call_log/call_log_collector.dart';
import 'package:data_collector_catalog/collectors/light/light_collector.dart';
import 'package:data_collector_catalog/collectors/network/network_collector.dart';
import 'package:data_collector_catalog/collectors/notification/notification_collector.dart';
import 'package:data_collector_catalog/collectors/screen_state/screen_state_collector.dart';
import 'package:data_collector_catalog/collectors/sensor/sensor_event_collector.dart';
import 'package:data_collector_catalog/collectors/volume/volume_collector.dart';
import 'package:data_collector_catalog/models/permission_list_ext.dart';
import 'package:data_collector_catalog/collectors/calendar/calendar_collector.dart';
import 'package:data_collector_catalog/collectors/health/health_collector.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/constants.dart';
import '../common/device.dart';
import '../collectors/audio/audio_collector.dart';
import 'collector.dart';
import 'sampling_interval.dart';
import 'collector_premission_state.dart';

enum CollectionItem {
  sensorEvnets,
  network,
  microphone,
  health,
  calendar,
  light,
  notification,
  volume,
  screenState,
  callLog,
}

extension CollectionItemGetters on CollectionItem {
  // ignore: unused_field
  static const _log = 'CollectionItemGetters';

  String get name {
    switch (this) {
      case CollectionItem.sensorEvnets:
        return '가속도, 각속도, 자기장';
      case CollectionItem.network:
        return '네트워크';
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
      case CollectionItem.volume:
        return '볼륨';
      case CollectionItem.screenState:
        return '화면 상태';
      case CollectionItem.callLog:
        return '전화 기록';
    }
  }

  String get description {
    switch (this) {
      case CollectionItem.sensorEvnets:
        return 'm/s², °/s, μT';
      case CollectionItem.network:
        return 'ssid, bssid, 주파수, 신호 강도';
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
      case CollectionItem.volume:
        return '벨소리 모드, 음량';
      case CollectionItem.screenState:
        return 'on, off, unlocked';
      case CollectionItem.callLog:
        return '유형, 전화번호, 시간';
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

  Collector? get collector {
    switch (this) {
      case CollectionItem.sensorEvnets:
        return SensorEventCollector();
      case CollectionItem.network:
        return NetworkCollector();
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
      case CollectionItem.volume:
        return VolumeCollector();
      case CollectionItem.screenState:
        return ScreenStateCollector();
      case CollectionItem.callLog:
        return CallLogCollector();
      default:
        return null;
    }
  }

  SamplingInterval get samplingInterval {
    if ((this == CollectionItem.sensorEvnets) ||
        (this == CollectionItem.network) ||
        (this == CollectionItem.microphone) ||
        (this == CollectionItem.light)) {
      return SamplingInterval.min15;
    } else if (this == CollectionItem.network) {
      return SamplingInterval.min5;
    } else {
      return SamplingInterval.event;
    }
  }

  List<Permission> get permissions {
    switch (this) {
      case CollectionItem.network:
        return [Permission.location];
      case CollectionItem.microphone:
        return Device.shared.isAboveAndroid9
            ? [Permission.microphone]
            : [Permission.microphone, Permission.storage];
      case CollectionItem.calendar:
        return [Permission.calendarFullAccess];
      case CollectionItem.callLog:
        return [Permission.phone];
      default:
        return [];
    }
  }

  bool get isNeedCustomPermission {
    return [
      CollectionItem.health,
      CollectionItem.notification,
      // CollectionItem.callLog,
    ].contains(this);
  }

  // Status of the required permissions in the collector
  Future<CollectorPermissionState> get permissionStatus async {
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
    if (isNeedCustomPermission) {
      return await collector?.onRequest() ?? false;
    } else {
      return await permissions.requestRequired();
    }
  }
}
