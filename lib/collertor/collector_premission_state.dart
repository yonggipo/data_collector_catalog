import 'dart:ui';

enum CollectorPermissionState {
  required, // 권한 필요
  none, // 미필요
  granted, // 권한 허용됨
}

extension CollectorPermissionStateGetters on CollectorPermissionState {
  String get title {
    switch (this) {
      case CollectorPermissionState.required:
        return '대기중';
      case CollectorPermissionState.none:
        return '미필요';
      case CollectorPermissionState.granted:
        return '허용됨';
    }
  }

  Color get indicatorColor {
    switch (this) {
      case CollectorPermissionState.required:
        return Color(0xFFF87272);
      case CollectorPermissionState.none:
        return Color(0xFF8EDFAA);
      case CollectorPermissionState.granted:
        return Color(0xFF4C71F5);
    }
  }
}
