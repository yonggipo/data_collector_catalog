enum Item {
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
  bluetooth;
  
  String get category {
    switch (this) {
      case Item.sensorEvnets: return '관성';
      case Item.location: return '위치'; 
      case Item.environment: return '환경';
      case Item.network: return '네트워크';
      case Item.microphone: return '오디오';
      case Item.health: return '건강';
      case Item.calendar: return '켈린더';
      case Item.light: return '빛';
      case Item.notification: return '알림';
      case Item.directory: return '경로(미디어)';
      case Item.application: return '어플리케이션';
      case Item.volume: return '볼륨';
      case Item.screenState: return '화면 상태';
      case Item.battery: return '배터리';
      case Item.callLog: return '전화 기록';
      case Item.bluetooth: return '블루투스';
    }
  }

  String get description {
    switch (this) {
      case Item.sensorEvnets: return '가속도, 각속도, 자기장';
      case Item.location: return '위도, 경도, 고도';
      case Item.environment: return '주변온도 습도, 압력';
      case Item.network: return 'ssid, bssid, 주파수, 신호 강도';
      case Item.microphone: return 'audio m4a';
      case Item.health: return '걸음수, 활동 상태 및 시간';
      case Item.calendar: return '일정';
      case Item.light: return '조도 lumen';
      case Item.notification: return '앱, 메세지, 시간, 클릭 여부';
      case Item.directory: return '디렉토리, 확장자';
      case Item.application: return '앱 카테고리, 이름, 사용시간';
      case Item.volume: return '벨소리 모드, 음량';
      case Item.screenState: return 'on, off, unlocked';
      case Item.battery: return '배터리 잔량, 상태';
      case Item.callLog: return '유형, 전화번호, 시간';
      case Item.bluetooth: return 'MAC주소, CoD, 신호 강도';
    }
  }

  List<String> get paths {
    switch (this) {
      case Item.sensorEvnets: return ['user_accelerometer', 'accelerometer', 'gyroscope', 'magnetometer'];
      case Item.location: return [];
      case Item.environment: return [];
      case Item.network: return [];
      case Item.microphone: return [];
      case Item.health: return [];
      case Item.calendar: return [];
      case Item.light: return [];
      case Item.notification: return [];
      case Item.directory: return [];
      case Item.application: return [];
      case Item.volume: return [];
      case Item.screenState: return [];
      case Item.battery: return [];
      case Item.callLog: return [];
      case Item.bluetooth: return [];
    }
  }
}
