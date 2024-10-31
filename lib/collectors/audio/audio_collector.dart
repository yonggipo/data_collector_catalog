import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:record/record.dart';

import '../../models/collector.dart';
import '../../models/item.dart';
import '../../models/sampling_interval.dart';

final class AudioCollector extends Collector {
  AudioCollector._() : super();
  static final shared = AudioCollector._();
  factory AudioCollector() => shared;

  static const _log = 'AudioCollector';

  final record = AudioRecorder();
  StreamSubscription? _subscription;

  @override
  Item get item => Item.microphone;

  @override
  String get messagePortName => _log;

  @override
  SamplingInterval get samplingInterval => SamplingInterval.min15;

  @override
  void collect() async {
    sendMessageToPort(true);
    final filePath = await getAudioFilePath();
    const recordConfig = RecordConfig(encoder: AudioEncoder.aacLc);
    await record.start(recordConfig, path: filePath);
    await Future.delayed(Duration(minutes: 1));
    final path = await record.stop() ?? 'error';
    sendMessageToPort(<String, dynamic>{
      'microphone': <String, dynamic>{'path': path}
    });
    sendMessageToPort(false);
  }

  Future<bool> hasPermission() {
    return record.hasPermission();
  }

  Future<bool> requestPermission() {
    return record.hasPermission();
  }

  static const _baseDir =
      'storage/emulated/0/Android/media/com.example.data_collector_catalog/files';
  static const _audioFolderName = 'audio';

  static Future<Directory> _getAudioDirectory() async {
    final directoryPath = p.join(_baseDir, _audioFolderName);
    final directory = Directory(directoryPath);

    if (!await directory.exists()) {
      await directory.create(recursive: true);
      dev.log('Created audio directory: $directoryPath', name: _log);
    }

    return directory;
  }

  static String _createFileName() {
    return '${DateTime.now().millisecondsSinceEpoch ~/ 1000}.m4a';
  }

  static Future<String> getAudioFilePath() async {
    final audioDir = await _getAudioDirectory();
    final fileName = _createFileName();
    return p.join(audioDir.path, fileName);
  }

  void onCancel() {
    _subscription?.cancel();
    _subscription = null;

    // As always, don't forget this one.
    // record.dispose();
  }
}
