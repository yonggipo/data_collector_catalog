import 'package:permission_handler/permission_handler.dart';

extension PermissionStatusGetters on PermissionStatus {
  bool get isP {
    switch (this) {
      case PermissionStatus.denied ||
            PermissionStatus.restricted ||
            PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.granted ||
            PermissionStatus.limited ||
            PermissionStatus.provisional:
        return true;
    }
  }
}
