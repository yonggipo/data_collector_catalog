import 'package:data_collector_catalog/collertor/collector.dart';

import 'dart:developer' as dev;

class HealthCollector extends Collector {
  static const _log = 'HealthCollector';

  @override
  Future<bool?> onRequest() async {
    return null;
  }

  // Future<bool?> isGranted() {}

  void onStart() async {}
}
