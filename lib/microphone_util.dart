import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sampling_interval.dart';

final class MicrophoneUtil {
  static final MicrophoneUtil shared = MicrophoneUtil._();
  MicrophoneUtil._();
  factory MicrophoneUtil() => shared;

  FlutterAudioCapture plugin = FlutterAudioCapture();
  final samplingInterval = SamplingInterval.fifteenMinutes;

  void listener(dynamic obj) {
    var buffer = Float64List.fromList(obj.cast<double>());
    // dev.log('buffer: $buffer');
    processAudioBuffer(buffer, 16000);
  }

  // Callback function if flutter_audio_capture failure to register
  // audio capture stream subscription.
  void onError(Object e) {
    dev.log('error: $e');
  }

  void startListener() async {
    // Start to capture audio stream buffer
    // sampleRate: sample rate you want
    // bufferSize: buffer size you want (iOS only)
    await plugin.init();
    await requestMicrophonePermission();
    await plugin.start(listener, onError, sampleRate: 16000, bufferSize: 3000);
  }

  // 예시의 간단한 에너지 계산 함수
  double calculateEnergy(Float64List buffer) {
    double energy = 0.0;
    for (var sample in buffer) {
      energy += sample * sample;
    }
    return energy / buffer.length;
  }

  // 예시의 간단한 피치 계산 함수
  double calculatePitch(Float64List buffer, int sampleRate) {
    // 피치 계산을 위한 FFT 또는 유사한 알고리즘을 사용할 수 있습니다.
    // 여기서는 예시로 간단한 계산을 보여줍니다.
    double pitch = 0.0;
    // 실제 피치 계산 로직은 라이브러리를 사용하거나 직접 구현해야 합니다.
    return pitch;
  }

  void processAudioBuffer(Float64List buffer, int sampleRate) {
    double energy = calculateEnergy(buffer);
    double pitch = calculatePitch(buffer, sampleRate);

    print('Energy: $energy dB');
    print('Pitch: $pitch Hz');
  }

  void cancel() async {
    // Stop to capture audio stream buffer
    await plugin.stop();
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }
}
