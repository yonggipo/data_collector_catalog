import 'dart:developer' as dev;

import 'package:permission_handler/permission_handler.dart';

extension PermissionsGetter on List<Permission> {
  static const _log = 'PermissionListExt';

  Future<bool> get areGranted async {
    if (isEmpty) {
      return true;
    }

    for (var permission in this) {
      if (await permission.isGranted == false) {
        return false;
      }
    }

    return true;
  }

  Future<bool> requestRequired() async {
    if (isEmpty) {
      return true;
    }

    List<Permission> notGranted = [];

    for (var permission in this) {
      if (await permission.isGranted == false) {
        notGranted.add(permission);
      }
    }

    if (notGranted.isEmpty) {
      return true;
    }

    dev.log('notGranted count: ${notGranted.length}', name: _log);

    final statuses = await notGranted.request();
    for (var entry in statuses.entries) {
      dev.log('entry: ${entry.key}, entry status: ${entry.value}', name: _log);
    }

    final areGranted = statuses.values.every((status) => status.isGranted);
    return areGranted;
  }
}
