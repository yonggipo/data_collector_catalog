import 'dart:async';
import 'dart:io';

// import 'package:app_usage/app_usage.dart';
// import 'package:appcheck/appcheck.dart';
import 'package:data_collector_catalog/models/collector.dart';

class ApplicationCollector extends Collector {
  ApplicationCollector._() : super();
  static final shared = ApplicationCollector._();
  factory ApplicationCollector() => shared;

  // static const _log = 'ApplicationCollector';
  // final appUsage = AppUsage();
  // final AppCheck appCheck = AppCheck();

  // StreamSubscription? _subscription;

  // @override
  // Future<void> onStart() async {
  //   super.onStart();
  //   final now = DateTime.now();
  //   final usages =
  //       await appUsage.getAppUsage(now.subtract(Duration(days: 30)), now);
  // }
}
