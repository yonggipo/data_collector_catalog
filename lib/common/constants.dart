class Constants {
  static final file = _File();
  static final stream = _Stream();

  static final String pretendard = 'Pretendard';

  static const lightEvent = 'com.kane.light_sensor_plugin.event';
  static const lightMethod = 'com.kane.light_sensor_plugin.method';

  static const notiEvent = 'com.kane.noti_detector_plugin.event';
  static const notiMethod = 'com.kane.noti_detector_plugin.method';
}

class _Stream {
  final String audio = 'audio';
}

class _File {
  final String lux = 'lux_events.json';

  final String audioPath = 'audio';
}
