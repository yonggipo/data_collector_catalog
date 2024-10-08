import 'dart:developer' as dev;

import 'package:permission_handler/permission_handler.dart';

import '../device.dart';
import 'sampling_interval.dart';
import 'collector_premission_state.dart';

enum CollectionItem {
  acceleration,
  angularVelocity,
  magneticFieldStrength,

  microphone,
}

extension CollectionItemGetters on CollectionItem {
  static const _logName = 'CollectionItemGetters';

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
    }
  }

  Stream<Map<String, dynamic>?> get dataStream {
    return Stream.empty();
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
    }
  }

  SamplingInterval get samplingInterval {
    switch (this) {
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
            ? ([
                Permission.microphone, // RECORD_AUDIO
              ])
            : ([
                Permission.microphone, // RECORD_AUDIO
                Permission.storage // WRITE_EXTERNAL_STORAGE
              ]);
      default:
        return [];
    }
  }

  Future<CollectorPermissionState> get permissionStatus async {
    if (permissions.isEmpty) return CollectorPermissionState.none;

    if (await permissionsGranted) {
      return CollectorPermissionState.granted;
    } else {
      return CollectorPermissionState.required;
    }
  }

  Future<bool> get permissionsGranted async {
    if (permissions.isEmpty) {
      return true;
    }

    for (var permission in permissions) {
      if (await permission.isGranted == false) {
        return false;
      }
    }

    return true;
  }

  Future<bool> requestRequiredPermissions() async {
    if (permissions.isEmpty) {
      return true;
    }

    List<Permission> notGrantedPermissions = [];

    for (var permission in permissions) {
      if (await permission.isGranted == false) {
        notGrantedPermissions.add(permission);
      }
    }

    if (notGrantedPermissions.isEmpty) {
      return true;
    }

    dev.log('notGranted count: ${notGrantedPermissions.length}',
        name: _logName);

    Map<Permission, PermissionStatus> statuses =
        await notGrantedPermissions.request();

    for (var entry in statuses.entries) {
      dev.log('entry: ${entry.key}, entry status: ${entry.value}',
          name: _logName);
    }
    return statuses.values.every((status) => status.isGranted);
  }
}
