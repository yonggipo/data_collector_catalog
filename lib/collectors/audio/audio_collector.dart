import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:record/record.dart';

import '../../common/constants.dart';
import '../../common/firebase_service.dart';
import '../../common/local_db_service.dart';
import '../../models/collector.dart';

final class AudioCollector extends Collector {
  AudioCollector._() : super();
  static final shared = AudioCollector._();
  factory AudioCollector() => shared;

  static const _log = 'AudioCollector';

  final record = AudioRecorder();
  StreamSubscription? _subscription;

  @override
  Future<bool> onRequest() async {
    return await record.hasPermission();
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

  @override
  void onCollectStart() async {
    super.onCollectStart();
    dev.log('onStart', name: _log);
    final filePath = await getAudioFilePath();
    const recordConfig = RecordConfig(encoder: AudioEncoder.aacLc);
    await record.start(recordConfig, path: filePath);
    await Future.delayed(Duration(minutes: 1));
    final path = await record.stop() ?? 'error';
    final Map<String, dynamic> map = {'path': path};
    onData(map);
  }

  @override
  void onData(data) {
    super.onData(data);
    if (data is! Map) return;
    // LocalDbService._save(data, Constants.audio);
  }

  @override
  void onCancel() async {
    super.onCancel();

    _subscription?.cancel();
    _subscription = null;

    // As always, don't forget this one.
    // record.dispose();
  }
}
