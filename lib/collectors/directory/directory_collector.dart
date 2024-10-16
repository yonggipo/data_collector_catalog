// ignore: unused_import
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:data_collector_catalog/common/firebase_service.dart';
import 'package:watcher/watcher.dart';
import 'package:path/path.dart' as p;

import '../../models/collector.dart';

class DirectoryCollector extends Collector {
  DirectoryCollector._() : super();
  static final shared = DirectoryCollector._();
  factory DirectoryCollector() => shared;

  static const _log = 'DirectoryCollector';

  List<StreamSubscription>? _subscriptions;

  @override
  void onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);
    final directories = [
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/DCIM'),
      Directory('/storage/emulated/0/Documents'),
      Directory('/storage/emulated/0/Pictures'),
      Directory('/storage/emulated/0/Movies'),
      Directory('/storage/emulated/0/Music'),
      Directory('/storage/emulated/0/Pictures'),
    ];

    for (var directory in directories) {
      final guard = await directory.exists();
      if (!guard) continue;
    }

    //
    // https://stackoverflow.com/questions/62974799/how-to-grant-permission-to-access-external-storage-in-flutter

    // Don't use listSync(recursive:) the UI thread might get blocked
    // https://stackoverflow.com/questions/76497379/pathaccessexception-issue-in-android-11-and-above

    // final subDirectories = await directory.list().toList();
    // dev.log('subDirectories: $subDirectories', name: _log);

    final watchers =
        directories.map((directory) => DirectoryWatcher(directory.path));

    _subscriptions = watchers
        .map((watcher) => watcher.events.listen(onData, onError: onError))
        .toList();
  }

  @override
  void onData(object) {
    super.onData(object);
    switch (object.type) {
      case ChangeType.ADD:
        dev.log('File added: ${object.path}', name: _log);
        break;
      case ChangeType.REMOVE:
        dev.log('File removed: ${object.path}', name: _log);
        break;
      case ChangeType.MODIFY:
        dev.log('File modified: ${object.path}', name: _log);
        break;
    }

    // Upload item to firebase
    FirebaseService.shared.upload(path: 'media', map: {
      'path': object.path,
      'type': object.type.toString(),
      'extension': p.extension(object.path),
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  @override
  void onCancel() {
    super.onCancel();
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
