import 'dart:async';
import 'dart:developer' as dev;

import 'package:calendar_watcher/calendar_watcher.dart';
import 'package:device_calendar/device_calendar.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';
import 'calendar_evnet.dart';

class CalendarCollector extends Collector {
  CalendarCollector._() : super();
  static final shared = CalendarCollector._();
  factory CalendarCollector() => shared;

  static const _log = 'CalendarCollector';
  final _plugin = DeviceCalendarPlugin();
  StreamSubscription? _subscription;

  @override
  Item get item => Item.calendar;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.event;

  @override
  void collect() {
    sendMessageToPort(true);
    _subscription = CalendarWatcher.stream.listen(onData, onError: onError);
  }

  void onData(data) async {
    dev.log('Calendar has been changed', name: _log);
    final events = await _fetchAllCalendarEvents();
    final maps = events.map((e) => e.toMap);
    sendMessageToPort(<String, dynamic>{
      'calendar': <String, dynamic>{'events': maps}
    });
    sendMessageToPort(true);
  }

  FutureOr<void> onError(Object error, StackTrace stackTrace) async {
    dev.log('Error occurred: $error', name: _log);
  }

  void onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<List<CalendarEvent>> _fetchAllCalendarEvents() async {
    final calendars = await _fetchCalendars();
    final futures = calendars.map(_fetchCalendarEvents);
    final eventLists = await Future.wait(futures);
    final events = eventLists.expand((e) => e).toList();
    return events.map((e) {
      return CalendarEvent(
          title: e.title,
          description: e.description,
          startTime: e.start,
          endTime: e.end);
    }).toList();
  }

  Future<List<Calendar>> _fetchCalendars() async {
    final calendars = await _plugin
            .retrieveCalendars()
            .then((r) => r.data?.cast<Calendar>()) ??
        [];
    return calendars.where((c) {
      dev.log("calendar name: ${c.name}, id: ${c.id}", name: _log);
      final name = c.name;
      return (name != null && _validateCalendarName(name));
    }).toList();
  }

  Future<List<Event>> _fetchCalendarEvents(Calendar calendar) async {
    dev.log('calender id ${calendar.id.toString()}', name: _log);
    final startDate = DateTime.now().add(const Duration(days: -30));
    final endDate = DateTime.now().add(const Duration(days: 30 * 2));
    final params = RetrieveEventsParams(startDate: startDate, endDate: endDate);
    final result = await _plugin.retrieveEvents(calendar.id, params);
    return result.data ?? [];
  }

  bool _validateCalendarName(String name) {
    final emailRegex = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$';
    return RegExp(emailRegex).hasMatch(name);
  }
}
