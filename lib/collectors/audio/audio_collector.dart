import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:record/record.dart';

import '../../common/firebase_service.dart';
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

  @override
  void onStart() async {
    super.onStart();
    dev.log('Start collection', name: _log);

    final path =
        'storage/emulated/0/Android/media/com.example.data_collector_catalog/files/'; // await FileManager.getPath();
    final directoryPath = p.join(
      path,
      'audio',
    );

    final directory = Directory(directoryPath);
    await directory.create(recursive: true);

    // 디렉토리가 존재하지 않으면 생성
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      dev.log('Create audio directory: $directoryPath', name: _log);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final filePath = p.join(directoryPath, fileName);
    dev.log('Start recording with $fileName', name: _log);

    // stram - pcm16bits
    // final stream = await record.startStream(recordConfig);
    // _subscription = stream.listen(onData);

    // record - aacLc
    const recordConfig = RecordConfig(encoder: AudioEncoder.aacLc);
    await record.start(recordConfig, path: filePath);
    // TODO 여기서 에러 1729470600030.m4a

    // 1분 후에 녹음 종료
    await Future.delayed(Duration(minutes: 1));
    onCancel();
    dev.log('End recording..', name: _log);
  }

  @override
  void onCancel() async {
    super.onCancel();
    final path = await record.stop();
    dev.log('Save record in $path', name: _log);

    FirebaseService.shared.upload(path: 'microphone', map: {
      'path': path,
      'timestamp': DateTime.now().toIso8601String()
    }).onError(onError);

    _subscription?.cancel();
    _subscription = null;

    // As always, don't forget this one.
    // record.dispose();
  }
}
