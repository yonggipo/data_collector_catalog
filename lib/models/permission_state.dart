import 'dart:ui';

enum PermissionState {
  required, // 권한 필요
  none, // 미필요
  granted; // 권한 허용됨

  bool get isValid {
    return (this != PermissionState.required);
  }

  String get title {
    switch (this) {
      case PermissionState.required:
        return '대기중';
      case PermissionState.none:
        return '미필요';
      case PermissionState.granted:
        return '허용됨';
    }
  }

  Color get indicatorColor {
    switch (this) {
      case PermissionState.required:
        return Color(0xFFF87272);
      case PermissionState.none:
        return Color(0xFF8EDFAA);
      case PermissionState.granted:
        return Color(0xFF4C71F5);
    }
  }
}