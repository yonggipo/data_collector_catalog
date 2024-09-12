import 'dart:typed_data';
import 'dart:developer' as dev;

import 'package:flutter_audio_capture/flutter_audio_capture.dart';

final class MicrophoneUtil {
  static final MicrophoneUtil shared = MicrophoneUtil._();
  MicrophoneUtil._();
  factory MicrophoneUtil() => shared;

  FlutterAudioCapture plugin = FlutterAudioCapture();

  void listener(dynamic obj) {
    var buffer = Float64List.fromList(obj.cast<double>());
    
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
    await plugin.start(listener, onError, sampleRate: 16000, bufferSize: 3000);
  }

  void cancel() async {
    // Stop to capture audio stream buffer
    await plugin.stop();
  }
}
