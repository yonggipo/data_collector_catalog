import 'dart:async';
import 'dart:developer' as dev;

import 'package:data_collector_catalog/common/firebase_service.dart';
import 'package:data_collector_catalog/models/collector.dart';

import 'application_adaptor.dart';

class ApplicationCollector extends Collector {
  ApplicationCollector._() : super();
  static final shared = ApplicationCollector._();
  factory ApplicationCollector() => shared;

  static const _log = 'ApplicationCollector';
  StreamSubscription? _subscription;

  @override
  Future<bool> onCheck() async {
    super.onCheck();
    return ApplicationAdaptor.hasPermission();
  }

  @override
  Future<bool> onRequest() async {
    super.onRequest();
    return ApplicationAdaptor.requestPermission();
  }

  @override
  void onStart() {
    super.onStart();

    dev.log('onStart', name: _log);
    _subscription =
        ApplicationAdaptor.stream.distinct().listen(onData, onError: onError);
  }

  @override
  void onData(data) {
    super.onData(data);
    FirebaseService.shared.upload(path: 'application', map: data);
  }

  @override
  void onCancel() {
    super.onCancel();

    _subscription?.cancel();
    _subscription = null;
  }
}
