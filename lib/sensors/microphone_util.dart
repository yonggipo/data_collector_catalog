import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:data_collector_catalog/sensor_util.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';

import '../sampling_interval.dart';

final class MicrophoneUtil extends SensorUtil {
  static final MicrophoneUtil shared = MicrophoneUtil._();
  MicrophoneUtil._();
  factory MicrophoneUtil() => shared;

  FlutterAudioCapture plugin = FlutterAudioCapture();

  @override
  final samplingInterval = SamplingInterval.min15;

  // Callback function if flutter_audio_capture failure to register
  // audio capture stream subscription.
  @override
  void onError(Object e) {
    dev.log('error: $e');
  }

  @override
  void cancel() async {
    // Stop to capture audio stream buffer
    await plugin.stop();
  }

  @override
  void onData(object) {
    var buffer = Float64List.fromList(object.cast<double>());
    // dev.log('buffer: $buffer');
    processAudioBuffer(buffer, 16000);
  }

  @override
  void start() async {
    // Start to capture audio stream buffer
    // sampleRate: sample rate you want
    // bufferSize: buffer size you want (iOS only)
    await plugin.init();
    await requestPermission();
    await plugin.start(onData, onError, sampleRate: 16000, bufferSize: 3000);
    await Future.delayed(const Duration(seconds: 1));
    cancel();
  }

  // MARK: - private

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

    dev.log('Energy: $energy dB');
    dev.log('Pitch: $pitch Hz');
  }

  @override
  Future<bool> requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      return Permission.microphone.request().then((status) {
        dev.log(status.toString());
        return verifyStatus(status);
      });
    } else {
      return verifyStatus(status);
    }
  }

  bool verifyStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.denied ||
            PermissionStatus.restricted ||
            PermissionStatus.permanentlyDenied:
        return false;
      default:
        return true;
    }
  }
}
