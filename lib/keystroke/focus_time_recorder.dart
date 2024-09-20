import 'package:data_collector_catalog/keystroke/keystroke_data.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';

final class FocusTimeRecorder extends StatefulWidget {
  const FocusTimeRecorder({super.key});

  @override
  State<FocusTimeRecorder> createState() => _FocusTimeRecorderState();
}

class _FocusTimeRecorderState extends State<FocusTimeRecorder> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  final List<KeystrokeLog> _logs = [];
  List<KeyboardEvent> _events = [];
  DateTime? _focusStartTime;
  Duration? _focusDuration;
  String _inputText = '';

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _onFocusGained();
      } else {
        _onFocusLost();
      }
    });
  }

  void _onFocusGained() {
    setState(() {
      _focusStartTime = DateTime.now();
      _inputText = '';
    });
    dev.log("TextField focused at: $_focusStartTime");
  }

  void _onFocusLost() {
    if (_focusStartTime != null) {
      setState(() {
        _focusDuration = DateTime.now().difference(_focusStartTime!);
        _logs.add(
          KeystrokeLog(
            text: _inputText,
            focusDuration: _focusDuration,
            keyboardEvents: _events,
          ),
        );
        _focusStartTime = null;
        _events = [];
      });
      dev.log("Focus duration: ${_focusDuration?.inSeconds} seconds");
      dev.log("Input text during focus: $_inputText");
      dev.log("Collected logs: ${_logs.toString()}");
    }
  }

  void _onTextChanged(String text) {
    setState(() {
      _inputText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KeyboardListener(
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                _events.add(
                  KeyboardEvent(
                    keyLabel: event.logicalKey.keyLabel,
                    character: event.character,
                    timeStamp: DateTime.now(),
                  ),
                );
              }
            },
            focusNode: _focusNode,
            child: TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              decoration: const InputDecoration(
                hintText: 'Focus on this textField and start typing...',
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_focusDuration != null)
            Column(
              children: [
                Text('Focus lasted for: ${_focusDuration!.inSeconds} seconds'),
                Text('Input during focus: $_inputText'),
              ],
            ),
          if (_focusDuration == null && _focusStartTime != null)
            const Text('TextField is focused...'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
