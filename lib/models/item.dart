import 'package:app_usage/app_usage.dart';
import 'package:data_collector_catalog/models/permissions_getter.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../common/device.dart';

enum Item {
  sensorEvnets,
  location,
  environment,
  network,
  health,
  volume,
  screenState,
  battery,
  callLog,
  notification,
  directory,
  appUsage,
  bluetooth,
  calendar,
  microphone;
  
  String get category {
    switch (this) {
      case Item.sensorEvnets: return '관성';
      case Item.location: return '위치'; 
      case Item.environment: return '환경';
      case Item.network: return '네트워크';
      case Item.health: return '건강';
      case Item.volume: return '볼륨';
      case Item.screenState: return '화면 상태';
      case Item.battery: return '배터리';
      case Item.callLog: return '전화 기록';
      case Item.notification: return '알림';
      case Item.directory: return '경로(미디어)';
      case Item.appUsage: return '어플리케이션';
      case Item.bluetooth: return '블루투스';
      case Item.calendar: return '켈린더';
      case Item.microphone: return '오디오';
    }
  }

  String get description {
    switch (this) {
      case Item.sensorEvnets: return '가속도, 각속도, 자기장';
      case Item.location: return '위도, 경도, 고도';
      case Item.environment: return '주변온도 습도, 압력, 조도';
      case Item.network: return 'ssid, bssid, 주파수, 신호 강도';
      case Item.health: return '걸음수, 활동 상태 및 시간';
      case Item.volume: return '벨소리 모드, 음량';
      case Item.screenState: return 'on, off, unlocked';
      case Item.battery: return '배터리 잔량, 상태';
      case Item.callLog: return '유형, 전화번호, 시간';
      case Item.notification: return '앱, 메세지, 시간, 클릭 여부';
      case Item.directory: return '디렉토리, 확장자';
      case Item.appUsage: return '앱 카테고리, 이름';
      case Item.bluetooth: return 'MAC주소, CoD, 신호 강도';
      case Item.calendar: return '일정';
      case Item.microphone: return 'audio m4a';
    }
  }

  List<String> get paths {
    switch (this) {
      case Item.sensorEvnets: return ['user_accelerometer', 'accelerometer', 'gyroscope', 'magnetometer'];
      case Item.location: return ['location'];
      case Item.environment: return ['enviroment'];
      case Item.network: return ['wifi'];
      case Item.health: return ['physical_activity', 'step_count', 'pedestrian_status'];
      case Item.volume: return ['ringer_mode', 'volume'];
      case Item.screenState: return ['screen_state'];
      case Item.battery: return ['battery'];
      case Item.callLog: return ['call_log'];
      case Item.notification: return ['notification'];
      case Item.directory: return ['directory(media)'];
      case Item.appUsage: return ['app_usage'];
      case Item.bluetooth: return ['bluetooth'];
      case Item.calendar: return ['calendar'];
      case Item.microphone: return ['microphone'];
    }
  }

  // 위치 네트워크 건강 전화기록 알림 경로 어플리케이션 블루투스 캘린더 오디오 
  List<Permission> get permissions { 
    switch (this) {
      case Item.location: return [Permission.locationWhenInUse];
      case Item.network: return [Permission.locationWhenInUse];
      case Item.health: return [Permission.activityRecognition];
      case Item.callLog: return [Permission.phone];
      case Item.directory: return (Device.shared.andSdk! >= 33)
            ? [Permission.manageExternalStorage]
            : ((Device.shared.andSdk! >= 23) ? [Permission.storage] : []);
      case Item.bluetooth: return (Device.shared.andSdk! >= 31)
            ? [Permission.bluetoothScan, Permission.bluetoothConnect]
            : ((Device.shared.andSdk! <= 28) ? [] : []);
      case Item.calendar: return [Permission.calendarFullAccess];
      case Item.microphone: return Device.shared.isAboveAndroid9
            ? [Permission.microphone]
            : [Permission.microphone, Permission.storage];
      default:
        return [];
    }
  }

  Future<bool> get hasPermission async {
    if (this == Item.appUsage) {
      return AppUsage.hasPermission();
    } else if (this == Item.notification) {
      return NotificationListenerService.isPermissionGranted();
    } else {
      return permissions.areGranted;
    }
  }
}
