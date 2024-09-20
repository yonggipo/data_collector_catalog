import 'package:flutter/material.dart';
import 'dart:developer' as dev;

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
          TextField(
            focusNode: _focusNode,
            controller: _controller,
            onChanged: _onTextChanged, // Track changes in the input text
            decoration: const InputDecoration(
              hintText: 'Focus on this TextField and start typing...',
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
