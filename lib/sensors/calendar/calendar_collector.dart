import 'dart:developer' as dev;

import 'package:data_collector_catalog/collertor/collector.dart';
import 'package:device_calendar/device_calendar.dart';

class CalendarCollector extends Collector {
  final _plugin = DeviceCalendarPlugin();

  @override
  Future<bool> onRequest() async {
    var isGranted = await _plugin.requestPermissions();
    return isGranted.data ?? false;
  }

  Future<bool> isGranted() async {
    var isGranted = await _plugin.hasPermissions();
    return isGranted.data ?? false;
  }

  @override
  void onStart() async {
    super.onStart();

    final calendars =
        await _plugin.retrieveCalendars().then((r) => r.data?.cast()) ?? [];

    for (int i = 0; i < calendars.length; i++) {
      dev.log("calendars name: ${calendars[i].toString()}");
    }
  }
}
