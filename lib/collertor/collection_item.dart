// ignore: unused_import
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collertor/permission_list_ext.dart';
import 'package:data_collector_catalog/sensors/health/health_collector.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/constants.dart';
import '../common/device.dart';
import '../sensors/audio/audio_collector.dart';
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
    }
  }

  String get unit {
    switch (this) {
      case CollectionItem.acceleration:
        return 'm/s²';
      case CollectionItem.angularVelocity:
        return '도/초(°/s)';
      case CollectionItem.magneticFieldStrength:
        return 'μT';
      case CollectionItem.microphone:
        return 'm4a';
      case CollectionItem.health:
        return 'count, status, date';
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
      default:
        return null;
    }
  }

  Type get collectorType {
    switch (this) {
      case CollectionItem.microphone:
        return AudioCollector;
      case CollectionItem.health:
        return HealthCollector;
      default:
        return Collector;
    }
  }

  SamplingInterval get samplingInterval {
    switch (this) {
      case CollectionItem.health:
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
            ? [
                Permission.microphone, // RECORD_AUDIO
              ]
            : [
                Permission.microphone, // RECORD_AUDIO
                Permission.storage // WRITE_EXTERNAL_STORAGE
              ];
      default:
        return [];
    }
  }

  Future<CollectorPermissionState> get permissionStatus async {
    bool isGranted;

    switch (this) {
      case CollectionItem.health:
        if (collector is HealthCollector) {
          final health = collector as HealthCollector;
          isGranted = await health.isGranted();
        } else {
          return CollectorPermissionState.required;
        }
      default:
        if (permissions.isEmpty) {
          return CollectorPermissionState.none;
        }

        isGranted = await permissions.areGranted;
    }

    return isGranted
        ? CollectorPermissionState.granted
        : CollectorPermissionState.required;
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
