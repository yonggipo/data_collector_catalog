// ignore: unused_import
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

class DirectoryCollector extends Collector {
  DirectoryCollector._() : super();
  static final shared = DirectoryCollector._();
  factory DirectoryCollector() => shared;

  static const _log = 'DirectoryCollector';
  List<StreamSubscription>? _subscriptions;

  @override
  Item get item => Item.directory;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.event;

  @override
  void collect() async {
    sendMessageToPort(true);

    // https://stackoverflow.com/questions/62974799/how-to-grant-permission-to-access-external-storage-in-flutter

    // Don't use listSync(recursive:) the UI thread might get blocked
    // https://stackoverflow.com/questions/76497379/pathaccessexception-issue-in-android-11-and-above

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

    final watchers =
        directories.map((directory) => DirectoryWatcher(directory.path));

    _subscriptions ??= watchers
        .map((watcher) => watcher.events.listen(onData, onError: onError))
        .toList();
  }

  void onData(data) {
    if (data is WatchEvent) {
      final evnet = data;
      sendMessageToPort(<String, dynamic>{
        'directory(media)': <String, dynamic>{
          'path': evnet.path,
          'type': evnet.toString(),
          'extension': p.extension(evnet.path),
        }
      });
    }
    sendMessageToPort(true);
  }

  FutureOr<void> onError(Object error, StackTrace stackTrace) async {
    dev.log('Error occurred: $error', name: _log);
  }

  void onCancel() {
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions = null;
  }
}
