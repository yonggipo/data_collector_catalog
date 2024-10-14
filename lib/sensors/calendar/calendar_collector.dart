import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/collertor/collector.dart';
import 'package:data_collector_catalog/sensors/calendar/calendar_adaptor.dart';
import 'package:device_calendar/device_calendar.dart';

class CalendarCollector extends Collector {
  static const _log = 'calender';
  final _plugin = DeviceCalendarPlugin();
  StreamSubscription? _subscription;

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

    _subscription = CalendarAdaptor.signalStream().listen(onData);
    _subscription?.onError(onError);

    final calendars =
        await _plugin.retrieveCalendars().then((r) => r.data?.cast()) ?? [];

    for (int i = 0; i < calendars.length; i++) {
      if (!calendars[i] is Calendar) {
        break;
      }

      final calendar = calendars[i] as Calendar;
      dev.log("calendars name: ${calendar.name}", name: _log);
      dev.log("calendar ${calendar.id}", name: _log);
      final startDate = DateTime.now().add(const Duration(days: -30));
      final endDate = DateTime.now().add(const Duration(days: 365 * 1));
      final params =
          RetrieveEventsParams(startDate: startDate, endDate: endDate);
      final result = await _plugin.retrieveEvents(calendar.id, params);
      final events = result.data ?? [];

      for (var e in events) {
        dev.log('event: e', name: _log);
      }
    }
  }
}
