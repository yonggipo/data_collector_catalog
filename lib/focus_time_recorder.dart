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

  DateTime? _focusStartTime;
  Duration? _focusDuration;
  String _inputText =
      ''; // Stores the user input while the TextField is focused

  @override
  void initState() {
    super.initState();

    // Add a listener to the FocusNode to detect focus changes
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
      _focusStartTime = DateTime.now(); // Record the time when focus is gained
      _inputText = ''; // Reset the input text when the TextField is focused
    });
    print("TextField focused at: $_focusStartTime");
  }

  void _onFocusLost() {
    if (_focusStartTime != null) {
      setState(() {
        _focusDuration = DateTime.now()
            .difference(_focusStartTime!); // Calculate focus duration
        _focusStartTime = null; // Reset focus start time
      });
      print("Focus duration: ${_focusDuration?.inSeconds} seconds");
      print("Input text during focus: $_inputText");
    }
  }

  void _onTextChanged(String text) {
    setState(() {
      _inputText = text; // Update the input text as the user types
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
            onKeyEvent: (value) {
              // 중간에 입력이 멈춘 시간??
              if (value is KeyDownEvent) {
                dev.log('Event: ${value.toString()}');
                dev.log('Logical key label: ${value.logicalKey.keyLabel}');
                dev.log('Event character: ${value.character}');
              }

              // for detect backspace
              //  return event.logicalKey == LogicalKeyboardKey.keyQ
              if (value.logicalKey == LogicalKeyboardKey.backspace) {
                dev.log('Did backspace tapped!!');
              }
            },
            focusNode: _focusNode,
            child: TextField(
              controller: _controller,
              onChanged: _onTextChanged, // Track changes in the input text
              decoration: const InputDecoration(
                hintText: 'Focus on this textField and start typing...',
              ),
            ),
          ),

          // text: '안녕하세요'
          // keyBoardEvent: [
          //     {
          //
          //     }

          const SizedBox(height: 20),
          if (_focusDuration != null)
            Column(
              children: [
                Text('Focus lasted for: ${_focusDuration!.inSeconds} seconds'),
                Text('Input during focus: $_inputText'),
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
