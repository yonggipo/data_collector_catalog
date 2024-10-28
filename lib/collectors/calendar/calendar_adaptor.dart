import 'package:flutter/services.dart';

import '../../common/constants.dart';

class CalendarAdaptor {
  CalendarAdaptor._();

  static const eventChannel = EventChannel(Constants.calendarEvent);

  static Stream<void> stream() {
    return eventChannel.receiveBroadcastStream();
  }
}
