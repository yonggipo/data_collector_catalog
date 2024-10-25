// ignore: unused_import
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collectors/application/application_collector.dart';
import 'package:data_collector_catalog/collectors/battery/battery_collector.dart';
import 'package:data_collector_catalog/collectors/bluetooth/bluetooth_collector.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:data_collector_catalog/collectors/calendar/calendar_collector.dart';
import 'package:data_collector_catalog/collectors/call_log/call_log_collector.dart';
import 'package:data_collector_catalog/collectors/directory/directory_collector.dart';
import 'package:data_collector_catalog/collectors/enviroment/enviroment_collector.dart';
import 'package:data_collector_catalog/collectors/health/health_collector.dart';
import 'package:data_collector_catalog/collectors/light/light_collector.dart';
import 'package:data_collector_catalog/collectors/location/location_collector.dart';
import 'package:data_collector_catalog/collectors/network/network_collector.dart';
import 'package:data_collector_catalog/collectors/notification/notification_collector.dart';
import 'package:data_collector_catalog/collectors/screen_state/screen_state_collector.dart';
import 'package:data_collector_catalog/collectors/sensor/sensor_event_collector.dart';
import 'package:data_collector_catalog/collectors/volume/volume_collector.dart';
import 'package:data_collector_catalog/models/permission_list_ext.dart';

import '../collectors/audio/audio_collector.dart';
import '../common/constants.dart';
import '../common/device.dart';
import 'collector.dart';
import 'collector_premission_state.dart';
import 'sampling_interval.dart';

enum CollectionItem {
  sensorEvnets,
  location,
  environment,
  network,
  microphone,
  health,
  calendar,
  light,
  notification,
  directory,
  application,
  volume,
  screenState,
  battery,
  callLog,
  bluetooth,
}

extension CollectionItemGetters on CollectionItem {
  // ignore: unused_field
  static const _log = 'CollectionItemGetters';

  String get name {
    switch (this) {
      case CollectionItem.sensorEvnets:
        return '가속도, 각속도, 자기장';
      case CollectionItem.location:
        return '위치';
      case CollectionItem.environment:
        return '환경';
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
      case CollectionItem.directory:
        return '경로(미디어)';
      case CollectionItem.application:
        return '어플리케이션';
      case CollectionItem.volume:
        return '볼륨';
      case CollectionItem.screenState:
        return '화면 상태';
      case CollectionItem.battery:
        return '배터리';
      case CollectionItem.callLog:
        return '전화 기록';
      case CollectionItem.bluetooth:
        return '블루투스';
    }
  }

  String get description {
    switch (this) {
      case CollectionItem.sensorEvnets:
        return 'm/s², °/s, μT';
      case CollectionItem.location:
        return '위도, 경도, 고도';
      case CollectionItem.environment:
        return '주변온도 습도, 압력';
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
      case CollectionItem.directory:
        return '디렉토리, 확장자';
      case CollectionItem.application:
        return '앱 카테고리, 이름, 사용시간';
      case CollectionItem.volume:
        return '벨소리 모드, 음량';
      case CollectionItem.screenState:
        return 'on, off, unlocked';
      case CollectionItem.battery:
        return '배터리 잔량, 상태';
      case CollectionItem.callLog:
        return '유형, 전화번호, 시간';
      case CollectionItem.bluetooth:
        return 'MAC주소, CoD, 신호 강도';
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
      case CollectionItem.location:
        return LocationCollector();
      case CollectionItem.environment:
        return EnviromentCollector();
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
      case CollectionItem.directory:
        return DirectoryCollector();
      case CollectionItem.application:
        return ApplicationCollector();
      case CollectionItem.volume:
        return VolumeCollector();
      case CollectionItem.screenState:
        return ScreenStateCollector();
      case CollectionItem.battery:
        return BatteryCollector();
      case CollectionItem.callLog:
        return CallLogCollector();
      case CollectionItem.bluetooth:
        return BluetoothCollector();
      default:
        return null;
    }
  }

  SamplingInterval get samplingInterval {
    if (this == CollectionItem.battery) {
      return SamplingInterval.h4;
    } else if ((this == CollectionItem.sensorEvnets) ||
        (this == CollectionItem.location) ||
        (this == CollectionItem.environment) ||
        (this == CollectionItem.network) ||
        (this == CollectionItem.microphone) ||
        (this == CollectionItem.light)) {
      return SamplingInterval.min15;
    } else if ((this == CollectionItem.network) || false) {
      // (this == CollectionItem.bluetooth)
      return SamplingInterval.min5;
    } else {
      return SamplingInterval.event;
    }
  }

  List<Permission> get permissions {
    switch (this) {
      case CollectionItem.location:
        return [Permission.locationWhenInUse];
      case CollectionItem.network:
        return [Permission.locationWhenInUse];
      case CollectionItem.microphone:
        return Device.shared.isAboveAndroid9
            ? [Permission.microphone]
            : [Permission.microphone, Permission.storage];
      case CollectionItem.calendar:
        return [Permission.calendarFullAccess];
      case CollectionItem.callLog:
        return [Permission.phone];
      case CollectionItem.directory:
        return (Device.shared.andSdk! >= 33)
            ? [Permission.manageExternalStorage]
            : ((Device.shared.andSdk! >= 23) ? [Permission.storage] : []);
      case CollectionItem.bluetooth:
        return (Device.shared.andSdk! >= 31)
            ? [Permission.bluetoothScan, Permission.bluetoothConnect]
            : ((Device.shared.andSdk! <= 28) ? [] : []);
      default:
        return [];
    }
  }

  bool get isNeedCustomPermission {
    return [
      CollectionItem.location,
      CollectionItem.health,
      CollectionItem.notification,
      // CollectionItem.callLog,
      CollectionItem.application,
    ].contains(this);
  }

  // Status of the required permissions in the collector
  Future<CollectorPermissionState> get permissionStatus async {
    if (isNeedCustomPermission) {
      final customCheck = await collector?.onCheck() ?? false;
      if (!customCheck) {
        return CollectorPermissionState.required;
      }

      if (permissions.isEmpty) {
        return CollectorPermissionState.granted;
      }
    } else if (permissions.isEmpty) {
      return CollectorPermissionState.none;
    }

    return (await permissions.areGranted)
        ? CollectorPermissionState.granted
        : CollectorPermissionState.required;
  }

  Future<bool> requestRequired() async {
    final isCustomPermissionGranted = await collector?.onCheck() ?? false;
    if (isNeedCustomPermission && !isCustomPermissionGranted) {
      final customPermission = await collector?.onRequest() ?? false;

      if (!customPermission) {
        return false;
      }
    }

    if (permissions.isEmpty) {
      return true;
    } else {
      return await permissions.requestRequired();
    }
  }
}
