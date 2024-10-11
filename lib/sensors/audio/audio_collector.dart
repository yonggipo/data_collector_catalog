import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:record/record.dart';

import '../../collertor/collector.dart';

final class AudioCollector extends Collector {
  static const _log = 'AudioCollector';

  AudioCollector._() : super();
  static final AudioCollector shared = AudioCollector._();
  factory AudioCollector() => shared;

  final record = AudioRecorder();
  StreamSubscription? _subscription;

  @override
  Future<bool> requestPermission() async {
    return await record.hasPermission();
  }

  @override
  void start() async {
    super.start();
    dev.log('Start collection..', name: _log);

    // await requestPermission();

    final path =
        'storage/emulated/0/Android/media/com.example.data_collector_catalog/files/'; // await FileManager.getPath();
    final directoryPath = p.join(
      path,
      'audio',
    );

    final directory = Directory(directoryPath);

    // 디렉토리가 존재하지 않으면 생성
    if (!await directory.exists()) {
      try {
        await directory.create(recursive: true);
        dev.log('Create audio directory: $directoryPath', name: _log);
      } catch (e) {
        dev.log('Error: $e', name: _log);
        return;
      }
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final filePath = p.join(directoryPath, fileName);

    // stram - pcm16bits
    // record - aacLc
    const recordConfig = RecordConfig(encoder: AudioEncoder.aacLc);
    await record.start(recordConfig, path: filePath);

    // final stream = await record.startStream(recordConfig);
    // _subscription = stream.listen(onData);
    dev.log('Start recording with $fileName', name: _log);

    // 1분 후에 녹음 종료
    await Future.delayed(Duration(minutes: 1));
    cancel();
    dev.log('End recording..', name: _log);
  }

  @override
  void cancel() async {
    super.cancel();
    final path = await record.stop();
    dev.log('Save record in $path', name: _log);
    // await record.cancel();
    _subscription?.cancel();
    _subscription = null;
  }

  // record.dispose(); deinit

  @override
  void onData(object) {
    dev.log('onData: $object', name: _log);
  }
}
