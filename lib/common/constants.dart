class Constants {
  static final file = _File();
  static final stream = _Stream();

  static final String pretendard = 'Pretendard';

  static const lightEvent = 'com.kane.light.event';
  static const lightMethod = 'com.kane.light.method';

  static const notiEvent = 'com.kane.notification.event';
  static const notiMethod = 'com.kane.notification.method';

  static const calendarEvent = 'com.kane.calendar.event';
  static const bluetoothEvent = 'com.kane.bluetooth.event';

  static const applicationEvnet = 'com.kane.application.event';
  static const applicationMethod = 'com.kane.application.method';
}

class _Stream {
  final String audio = 'audio';
}

class _File {
  final String lux = 'lux_events.json';
  final String audioPath = 'audio';
}
