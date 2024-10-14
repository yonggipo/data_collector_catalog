import 'dart:developer' as dev;
import 'dart:math';
import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../model/file_manager.dart';

class AuidoAnalyzer {
  static const _log = 'AuidoAnalyzer';

  void processAudioBuffer(Float64List buffer) {
    double energy = calculateEnergy(buffer);
    double pitch = calculatePitch(buffer);
    dev.log('energy: $energy, pitch: $pitch', name: _log);
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
    // final lastedName = fileNames.first;
    // final lasted = await FileManager.getFile(filePath, lastedName);
  }
}
