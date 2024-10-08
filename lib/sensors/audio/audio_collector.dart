import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

import '../../collertor/collector.dart';
import '../../collertor/sampling_interval.dart';
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
  final samplingInterval = SamplingInterval.event;

  @override
  Future<bool> requestPermission() async {
    return await record.hasPermission();
  }

  @override
  void start() async {
    super.start();
    dev.log('test', name: _logName);

    // if (await requestPermission()) {
    //   // final path = await FileManager.getPath();
    //   final directoryPath = p.join(
    //     'storage/emulated/0/Android/media/com.example.data_collector_catalog/files/',
    //     'audio',
    //   );
    //   final fullPath = p.join(
    //     directoryPath,
    //     '${DateTime.now().millisecondsSinceEpoch}.m4a',
    //   );

    //   final directory = Directory(directoryPath);

    //   // 디렉토리가 존재하지 않으면 생성
    //   if (!await directory.exists()) {
    //     try {
    //       await directory.create(recursive: true);
    //       dev.log('[micro] add audio folder: $directoryPath');
    //     } catch (e) {
    //       dev.log('[micro] audio folder error: $e');
    //       return;
    //     }
    //   } else {
    //     dev.log('audio folder already exist: $directoryPath');
    //   }

    //   const recordConfig =
    //       RecordConfig(encoder: AudioEncoder.aacLc); // pcm16bits stram 의 경우
    //   await record.start(recordConfig, path: fullPath);

    //   // final stream = await record.startStream(recordConfig);
    //   // _subscription = stream.listen(onData);
    //   dev.log('[micro] start recording.. in path: $fullPath)');

    //   // 1분 후에 녹음 종료
    //   await Future.delayed(Duration(minutes: 1));
    //   cancel();
    //   dev.log('[micro] end recording..');
    // }
  }

  @override
  void cancel() async {
    super.cancel();
    final path = await record.stop();
    dev.log('[micro] saved path: $path');
    // await record.cancel();
    record.dispose();
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onData(object) {
    dev.log('[micro] onData: $object');
  }
}
