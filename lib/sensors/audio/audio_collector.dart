import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

import '../../collertor/collector.dart';
import '../../model/file_manager.dart';

final class AudioCollector extends Collector {
  static const _logName = 'AudioCollector';

  AudioCollector._() : super();
  static final AudioCollector shared = AudioCollector._();
  factory AudioCollector() => shared;

  final record = AudioRecorder();
  StreamSubscription? _subscription;

  void processAudioBuffer(Float64List buffer) {
    double energy = calculateEnergy(buffer);
    double pitch = calculatePitch(buffer);
    dev.log('energy: $energy, pitch: $pitch', name: _logName);
  }

  double calculateEnergy(List<double> audioData) {
    double sum = 0.0;
    for (var sample in audioData) {
      sum += sample * sample;
    }

    //  데시벨(dB) 단위로 변환
    return 10 * log(sum / audioData.length) / ln10;
  }

  double calculatePitch(List<double> audioData) {
    // 주파수 계산
    final fft = FFT(audioData.length);
    final freq = fft.realFft(audioData);

    // 가장 큰 진폭과 인덱스 찾기
    final magnitudes = freq.discardConjugates().magnitudes();
    if (magnitudes.isEmpty) {
      throw Exception("No valid magnitudes found.");
    }

    final maxIndex = magnitudes.indexOf(magnitudes.reduce((max)));

    // FFT의 주파수 대역폭
    const sampleRate = 44100.0;
    final pitch = maxIndex * (sampleRate / (2 * magnitudes.length));
    return pitch;
  }

  void process() async {
    // final path = await FileManager.getPath();
    final filePath = p.join(
      'storage/emulated/0/Android/media/com.example.data_collector_catalog/files/',
      'audio',
    );
    final fileNames = await FileManager.findFileNames(filePath);
    // 내림차순 정렬
    fileNames.sort((l, r) {
      final lt = int.parse(l.split('.').first);
      final rt = int.parse(r.split('.').first);
      return rt.compareTo(lt);
    });
    final lastedName = fileNames.first;
    // final lasted = await FileManager.getFile(filePath, lastedName);
  }

  @override
  Future<bool> requestPermission() async {
    return await record.hasPermission();
  }

  @override
  void start() async {
    super.start();
    dev.log('Start collection..', name: _logName);

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
        dev.log('Create audio directory: $directoryPath', name: _logName);
      } catch (e) {
        dev.log('Error: $e', name: _logName);
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
    dev.log('Start recording with $fileName', name: _logName);

    // 1분 후에 녹음 종료
    await Future.delayed(Duration(minutes: 1));
    cancel();
    dev.log('End recording..', name: _logName);
  }

  @override
  void cancel() async {
    super.cancel();
    final path = await record.stop();
    dev.log('Save record in $path', name: _logName);
    // await record.cancel();
    _subscription?.cancel();
    _subscription = null;
  }

  // record.dispose(); deinit

  @override
  void onData(object) {
    dev.log('onData: $object', name: _logName);
  }
}
