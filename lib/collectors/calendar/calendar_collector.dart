import 'dart:async';
import 'dart:developer' as dev;

import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../collertor/collector.dart';
import 'calendar_adaptor.dart';
import 'calendar_evnet.dart';

class CalendarCollector extends Collector {
  CalendarCollector._() : super();
  static final shared = CalendarCollector._();
  factory CalendarCollector() => shared;

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
    // 앱시작시, 그리고 일정 변경을 감지시 3달(-30 +60)에 해당하는 일정을 읽어와 전송
    await _uploadEvents();
    _subscription = CalendarAdaptor.signalStream().listen(onData);
    _subscription?.onError(onError);
  }

  Future<void> _uploadEvents() async {
    final evnets = await _fetchAllCalendarEvents();
    for (var event in evnets) {
      // Upload item to firebase
      await Firebase.initializeApp();
      final ref = FirebaseDatabase.instance.ref();
      await ref
          .child("calendar")
          .child('events')
          .push()
          .set(event.toMap())
          .catchError((e) {
        dev.log('error: $e', name: _log);
      });
    }
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

  @override
  void onData(object) async {
    super.onData(object);
    dev.log('Calendar has been changed', name: _log);
    await _uploadEvents();
  }

  @override
  void onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }
}
